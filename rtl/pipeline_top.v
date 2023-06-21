`timescale 1ns/1ns

module pipeline_top (
    //imem interface
    output [31:0] o_imem_addr,
    input [31:0] i_imem_instr,

    // dmem interface
    input [31:0] i_dmem_rdata,
    output [31:0] o_dmem_wdata,
    output [31:0] o_dmem_addr,
    output [1:0] o_dmem_wr_type,
    output [2:0] o_dmem_rd_type,
    output o_dmem_wr_en, o_dmem_rd_en,

    input clk, rst
    );

    //-----------------------------------FETCH Stage--------------------------------
    reg   [31:0]   PC;
    wire  [31:0]   InstrF;
    wire FlushE, FlushD, StallD, StallF;

    reg [31:0]  PCNext,PCPlus4;
    wire br_taken;
    wire [31:0] ALUResultE;
    always @(*) begin       //Adder
        PCPlus4 <= PC + 32'd4;
    end
    
    always @(*) begin       //Mux
        PCNext <= br_taken ? {ALUResultE[31:2],2'b00} : PCPlus4;
    end
    
    always @(posedge clk) begin     //PC register
        if(rst)
            PC <= 32'd0;
        else if(!StallF)
            PC <= PCNext;
    end

    assign o_imem_addr = PC;
    assign InstrF = i_imem_instr;
    //instr_mem IM(.A(PC), .RD(InstrF)); //Instruction memory

    //-----------------------------------DECODE Stage-------------------------------
    reg [31:0] PCD,InstrD;
    wire [6:0] opcode;
    wire [2:0] func3;
    wire func7_5;
    wire [4:0] A1,A2,A3; 
    wire [31:0] ImmExtD,RD2_D, RD1_D;
    //Control Flags
    wire   ALUSrc2, ALUSrc1, RegWrite, Dwr_en, Drd_en;
    wire [1:0] ResultSrc,MemWrite;
    wire [2:0] MemRead,br_type;
    wire [3:0] ALUControl;

    always @(posedge clk) begin    
        if(FlushD)begin
            PCD <= 0;
            InstrD <= 0;
        end 
        else if(!StallD) begin
            PCD <= PC;
            InstrD <= InstrF;
        end
    end
    reg [31:0] ResultW,InstrW;
    reg RegWriteW;
    reg [4:0] waddr;
    always @(*) begin
        waddr <= InstrW[11:7];
    end
    DecodeUnit DU(  .Instr(InstrD),
                    .opcode(opcode),
                    .func3(func3),
                    .func7_5(func7_5),
                    .A1(A1),.A2(A2),.A3(A3));

    extend EX(.ImmExt(ImmExtD), .Instr(InstrD));

    register_file RF(   .RD1(RD1_D), .RD2(RD2_D), 
                        .WD3(ResultW), 
                        .A1(A1), .A2(A2), .A3(waddr), 
                        .WE3(RegWriteW), .clk(clk),.rst(rst));

    ControlUnit CU( .opcode(opcode), 
                    .func3(func3), 
                    .func7_5(func7_5), 
                    .ResultSrc(ResultSrc), .MemWrite(MemWrite), 
                    .ALUSrc2(ALUSrc2), .ALUSrc1(ALUSrc1), .RegWrite(RegWrite), .Dmem_wr_en(Dwr_en), .Dmem_rd_en(Drd_en),
                    .ALUControl(ALUControl), 
                    .MemRead(MemRead), .br_type(br_type));

    
    //-----------------------------------EXECUTE Stage-----------------------------------
    reg [31:0] PCE,RD1_E,RD2_E,ImmExtE,InstrE,InstrM,ALUResultM;
    wire [1:0] ForA, ForB;
    //Control Flags
    reg ALUSrc2E, ALUSrc1E, RegWriteE, RegWriteM, Dwr_enE, Drd_enE;
    reg [1:0] ResultSrcE,MemWriteE;
    reg [2:0] MemReadE,br_typeE;
    reg [3:0] ALUControlE;

    always @(posedge clk) begin
        if(FlushE)begin
            PCE <= 0;
            RD1_E <= 0;
            RD2_E <= 0;
            ImmExtE <= 0;
            InstrE <= 0;
            //Control:-
            ALUSrc1E <= 0;
            ALUSrc2E <= 0;
            RegWriteE <= 0;
            ResultSrcE <= 0;
            MemWriteE <= 0;
            MemReadE <= 0;
            br_typeE <= 0;
            ALUControlE <= 0;
            Dwr_enE <= 0;
            Drd_enE <= 0;
        end
        else begin
            PCE <= PCD;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            ImmExtE <= ImmExtD;
            InstrE <= InstrD;
            //Control:-
            ALUSrc1E <= ALUSrc1;
            ALUSrc2E <= ALUSrc2;
            RegWriteE <= RegWrite;
            ResultSrcE <= ResultSrc;
            MemWriteE <= MemWrite;
            MemReadE <= MemRead;
            br_typeE <= br_type;
            ALUControlE <= ALUControl;
            Dwr_enE <= Dwr_en;
            Drd_enE <= Drd_en;
        end     
    end

    reg [31:0] InA,InB;
    always @(*) begin   //Forwarding MUX @ source A
        case (ForA)
            2'b00: InA <= RD1_E;
            2'b01: InA <= ResultW;
            2'b10: InA <= ALUResultM;
            default: InA <= RD1_E;
        endcase
    end
    always @(*) begin   //Forwarding MUX @ source B
        case (ForB)
            2'b00: InB <= RD2_E;
            2'b01: InB <= ResultW;
            2'b10: InB <= ALUResultM;
            default: InB <= RD2_E;
        endcase
    end

    reg [31:0]  SrcA, SrcB;
    always @(*) begin   //MUX
        SrcA <= ALUSrc1E ? PCE : InA;
    end
    
    always @(*) begin   //MUX
        SrcB <= ALUSrc2E ? ImmExtE : InB; 
    end

    ALU AL( .ALUControl(ALUControlE), 
            .SrcA(SrcA), .SrcB(SrcB), 
            .ALUResult(ALUResultE));

    Branch Br(br_typeE, InA, InB, br_taken);
    
    //-----------------------------------MEMORY Stage-------------------------------
    reg [31:0] PCM,MemData;
    //Control Flags
    reg [1:0] ResultSrcM,MemWriteM, Dwr_enM, Drd_enM;
    reg [2:0] MemReadM;

    always @(posedge clk) begin
        PCM <= PCE;
        ALUResultM <= ALUResultE;
        MemData <= InB;
        InstrM <= InstrE;
        //Control:-
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        MemReadM <= MemReadE;
        Dwr_enM <= Dwr_enE;
        Drd_enM <= Drd_enE;
    end
    wire [31:0] ReadDataM;

    assign ReadDataM = i_dmem_rdata;
    assign o_dmem_wdata = MemData;
    assign o_dmem_addr = ALUResultM;
    assign o_dmem_wr_type = MemWriteM;
    assign o_dmem_rd_type = MemReadM;
    assign o_dmem_wr_en = Dwr_enM;
    assign o_dmem_rd_en = Drd_enM;

    // Data_Memory DM ( .RD(ReadDataM),
    //                 .WD(MemData), .A(ALUResultM), 
    //                 .WE(MemWriteM), 
    //                 .RE(MemReadM),
    //                 .wr_en(Dwr_enM), .rd_en(Drd_enM),
    //                 .clk(clk), .rst(rst));
    
    //-----------------------------------WRITE BACK Stage--------------------------
    reg [31:0] PCW, ALUResultW, ReadDataW;
    reg [1:0] ResultSrcW;

    always @(posedge clk) begin
        PCW <= PCM;
        InstrW <= InstrM;
        ReadDataW <= ReadDataM;
        ALUResultW <= ALUResultM;
        //Control:-
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
    end

    reg [31:0] PCWplus4;
    always @(*) begin
        PCWplus4 <= PCW + 32'd4;
    end
    // Write back MUX
    always @(*) begin
        case (ResultSrcW)
            2'b00: ResultW <= ALUResultW;
            2'b01: ResultW <= ReadDataW;
            2'b10: ResultW <= PCWplus4;
            default: ResultW <= 32'd0;
        endcase
    end

    HazardUnit hz( .rst(rst) ,.RegWriteW(RegWriteW),.RegWriteM(RegWriteM), .br_taken(br_taken), .ResultSrcE(ResultSrcE),
                    .InstrE(InstrE),.InstrW(InstrW),.InstrM(InstrM), .InstrD(InstrD),
                    .ForA(ForA),.ForB(ForB),.FlushE(FlushE), .FlushD(FlushD), .StallD(StallD), .StallF(StallF));
    

endmodule
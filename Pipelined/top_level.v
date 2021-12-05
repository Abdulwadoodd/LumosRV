`timescale 1ns/1ns

module top_level (
    input clk, rst,
    output reg [31:0] PC,
    output [31:0] InstrF, RF1, RF2, RF3, RF4, RF5, RF6, RF7, RF8, RF9, RF10, RF11, RF12,
    output [31:0] DM0, DM4, DM8, DM12, DM16, DM20, DM24, DM28
    );
    wire FlushE, FlushD, StallD, StallF;
    
    //-----------------------------------FETCH Stage--------------------------------
    reg [31:0]  PCNext,PCPlus4;
    wire br_taken;
    wire [31:0] ALUResultE;
    always @(*) begin       //Mux
        PCNext <= br_taken ? ALUResultE : PCPlus4;
    end
    always @(*) begin       //Adder
        PCPlus4 <= PC + 32'd4;
    end
    always @(posedge clk) begin     //PC register
        if(rst)
            PC <= 32'd0;
        else if(!StallF)
            PC <= PCNext;
    end
    reg [31:0] Dum; 
    reg [5:0] IMaddr;
    always @(*) begin
        Dum <= PCNext>>2;
        IMaddr <= Dum[5:0];
    end
    instr_mem IM(.A(IMaddr), .clk(clk), .rst(rst), .RD(InstrF));      //Instruction memory

    //-----------------------------------DECODE Stage-------------------------------
    reg [31:0] PCD,InstrD;
    wire [6:0] opcode;
    wire [2:0] func3;
    wire func7_5;
    wire [4:0] A1,A2,A3; 
    wire [31:0] ImmExtD,RD2_D, RD1_D;
    //Control Flags
    wire   ALUSrc2, ALUSrc1,RegWrite;
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
    DecodeUnit DU(.Instr(InstrD),.opcode(opcode),.func3(func3),.func7_5(func7_5),.A1(A1),.A2(A2),.A3(A3));
    extend EX(.ImmExt(ImmExtD), .Instr(InstrD));
    register_file RF ( .RD1(RD1_D), .RD2(RD2_D), .RF1(RF1), .RF2(RF2), .RF3(RF3), .RF4(RF4), .RF5(RF5),
                    .RF6(RF6), .RF7(RF7),.RF8(RF8), .RF9(RF9), .RF10(RF10), .RF11(RF11), .RF12(RF12), 
                    .WD3(ResultW), .A1(A1), .A2(A2), .A3(waddr), 
                    .WE3(RegWriteW), .clk(clk),.rst(rst) );
    ControlUnit CU( .opcode(opcode), .func3(func3), .func7_5(func7_5), .ResultSrc(ResultSrc),
                    .MemWrite(MemWrite), .ALUSrc2(ALUSrc2), .ALUSrc1(ALUSrc1), .RegWrite(RegWrite), 
                    .ALUControl(ALUControl), .MemRead(MemRead), .br_type(br_type));

    
    //-----------------------------------EXECUTE Stage-----------------------------------
    reg [31:0] PCE,RD1_E,RD2_E,ImmExtE,InstrE,InstrM,ALUResultM;
    wire [1:0] ForA, ForB;
    //Control Flags
    reg ALUSrc2E, ALUSrc1E, RegWriteE,RegWriteM;
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

    ALU AL(ALUControlE, SrcA, SrcB, ALUResultE);
    Branch Br(br_typeE, InA, InB, br_taken);
    
    //-----------------------------------MEMORY Stage-------------------------------
    reg [31:0] PCM,MemData;
    //Control Flags
    reg [1:0] ResultSrcM,MemWriteM;
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
    end
    wire [31:0] ReadDataM;
    Data_Memory DM( .RD(ReadDataM),.DM0(DM0), .DM4(DM4), .DM8(DM8),.DM12(DM12), .DM16(DM16), .DM20(DM20), 
                    .DM24(DM24), .DM28(DM28), .WD(MemData), .A(ALUResultM), 
                    .WE(MemWriteM), .RE(MemReadM) , .clk(clk), .rst(rst));

    
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
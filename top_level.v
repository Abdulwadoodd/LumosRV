`timescale 1ns/1ns

module top_level (
    input clk, rst,
    //output [31:0] Reg_File,
    //output [3:0] ALUControl,
    output reg [31:0] PC,
    output [31:0] Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7, DM0, DM4, DM8
);
    // Control Flags
    //wire [1:0] ImmSrc;
    wire PCSrc, RegWrite, ALUSrc;
    wire [1:0] ResultSrc,MemWrite;
    wire [2:0] MemRead,br_taken;
    wire signed [3:0] ALUControl;
    //necessary wires and reg for top level Data Path
    wire [31:0] ReadData,WriteData;
    wire signed [31:0] SrcA;
    reg [31:0] ALUResult,Result;
    reg signed [31:0] SrcB;
    reg [31:0] PCTarget,PCNext,PCPlus4;
    
    always @(*) begin
        PCNext <= PCSrc ? PCTarget : PCPlus4;
    end

    always @(*) begin
        PCPlus4 <= PC + 32'd4;
    end

    always @(posedge clk) begin
        if(rst)
            PC <= 32'd0;
        else
            PC <= PCNext;
    end
    //address_generator a3( .PCTarget(PCTarget), .clk(clk), .rst(rst), .pc_src(PCSrc) , .pc(PC));
    wire [31:0] ImmExt;
    always @(*) begin
        PCTarget <= ImmExt + PC;
    end

    instr_mem a1(.A(PC), .RD(Instr));

    reg [6:0] opcode;
    reg [2:0] func3;
    reg func7_5;
    reg [4:0] A1,A2,A3; 

    always @(*) begin
        opcode <= Instr[6:0];
        func3 <= Instr[14:12];
        func7_5 <= Instr[30];
        A1 <= Instr[19:15];
        A2 <= Instr[24:20];
        A3 <= Instr[11:7];
    end

    
    
    extend a2(.ImmExt(ImmExt), .Instr(Instr));

    register_file a4 ( .RD1(SrcA), .RD2(WriteData), .RF1(RF1), .RF2(RF2), .RF3(RF3), .RF4(RF4), .RF5(RF5),
                       .RF6(RF6), .RF7(RF7), .WD3(Result), .A1(A1), .A2(A2), .A3(A3), 
                        .WE3(RegWrite), .clk(clk),.rst(rst) );

    always @(*) begin
        SrcB <= ALUSrc ? ImmExt : WriteData; 
    end
    
    // ALU
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA + SrcB;
            4'b0001: ALUResult = SrcA - SrcB;
            4'b0010: ALUResult = SrcA & SrcB;
            4'b0011: ALUResult = SrcA | SrcB;
            4'b0100: ALUResult = SrcB;
            4'b0101: ALUResult = SrcA < SrcB;
            4'b0110: ALUResult = SrcA ^ SrcB;
            4'b0111: ALUResult = SrcA >> SrcB;
            4'b1000: ALUResult = SrcA << SrcB;
            4'b1001: ALUResult = SrcA >>> SrcB;
            
            default: ALUResult = 32'd0;
        endcase
        //beq = (ALUResult == 0);
        //bne = (ALUResult != 0);
    end

    reg beq,bne,blt,bge,zero;
    
    //Branch Module
    always @(*) begin
        beq <= (SrcA == SrcB);
        bne <= (SrcA != SrcB);
        blt <= (SrcA < SrcB);
        bge <= (SrcA >= SrcB);
    end

    always@(*)begin
        case (br_taken)
            3'b001: zero = beq;
            3'b010: zero = bne;
            3'b011: zero = blt;
            3'b100: zero = bge;
            default: zero = 1'b0;
        endcase              
    end

    Data_Memory a5(.RD(ReadData),.DM0(DM0), .DM4(DM4), .DM8(DM8), .WD(WriteData), .A(ALUResult), .WE(MemWrite), .RE(MemRead) , .clk(clk), .rst(rst));

    always @(*) begin
        case (ResultSrc)
            2'b00: Result <= ALUResult;
            2'b01: Result <= ReadData;
            2'b10: Result <= PCPlus4;
            default: Result <= 32'd0;
        endcase
        //Result <= ResultSrc ? ReadData: ALUResult;
    end

    ControlUnit a6( .opcode(opcode), .func3(func3), .func7_5(func7_5), .zero(zero), .ResultSrc(ResultSrc), .MemWrite(MemWrite),
    .ALUSrc(ALUSrc), .RegWrite(RegWrite), .PCSrc(PCSrc), .ALUControl(ALUControl), .MemRead(MemRead), .br_taken(br_taken));

endmodule
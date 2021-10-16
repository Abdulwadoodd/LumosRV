`timescale 1ns/1ns

module top_level (
    input clk, rst,
    //output [31:0] Reg_File,
    output [31:0] PC,Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7, DM0, DM4, DM8
);
    
    // Control Flags
    //wire [1:0] ImmSrc;
    wire PCSrc, RegWrite, MemWrite,ALUSrc;
    wire [1:0] ResultSrc;
    wire [2:0] ALUControl;


    //necessary wires and reg for top level Data Path

    wire [31:0] ReadData,SrcA,WriteData;
    reg [31:0] SrcB,ALUResult,Result;
    reg beq,bne,zero;



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

    wire [31:0] ImmExt;
    
    extend a2(.ImmExt(ImmExt), .Instr(Instr));

    reg [31:0] PCTarget;
    
    address_generator a3( .PCTarget(PCTarget), .clk(clk), .rst(rst), .pc_src(PCSrc) , .pc(PC));

    always @(*) begin
        PCTarget <= ImmExt + PC;
    end


    register_file a4 ( .RD1(SrcA), .RD2(WriteData), .RF1(RF1), .RF2(RF2), .RF3(RF3), .RF4(RF4), .RF5(RF5),
                       .RF6(RF6), .RF7(RF7), .WD3(Result), .A1(A1), .A2(A2), .A3(A3), 
                        .WE3(RegWrite), .clk(clk),.rst(rst) );

    
    always @(*) begin
        SrcB <= ALUSrc ? ImmExt : WriteData; 
    end

    
    always @(*) begin
        case (ALUControl)
            3'b000: ALUResult = SrcA + SrcB;
            3'b001: ALUResult = SrcA - SrcB;
            3'b101: ALUResult = SrcA < SrcB;
            3'b011: ALUResult = SrcA || SrcB;
            3'b010: ALUResult = SrcA && SrcB;
            3'b110: ALUResult = SrcA ^^ SrcB;
            3'b111: ALUResult = SrcA >> SrcB;
            3'b100: ALUResult = SrcB;
            default: ALUResult = 32'd0;
        endcase
        beq = (ALUResult == 0);
        bne = (ALUResult != 0);

    end

    always@(*)begin
        zero <= func3 ? bne : beq;               
    end

    Data_Memory a5(.RD(ReadData),.DM0(DM0), .DM4(DM4), .DM8(DM8), .WD(WriteData), .A(ALUResult), .WE(MemWrite), .clk(clk), .rst(rst));

    always @(*) begin
        case (ResultSrc)
            2'b00: Result <= ALUResult;
            2'b01: Result <= ReadData;
            2'b10: Result <= PC + 4;
            default: Result <= 32'd0;
        endcase
        //Result <= ResultSrc ? ReadData: ALUResult;
    end


    ControlUnit a6( .opcode(opcode), .func3(func3), .func7_5(func7_5), .zero(zero), .ResultSrc(ResultSrc), .MemWrite(MemWrite),
    .ALUSrc(ALUSrc), .RegWrite(RegWrite), .PCSrc(PCSrc), .ALUControl(ALUControl));

endmodule
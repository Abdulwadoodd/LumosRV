`timescale 1ns/1ns

module top_level (
    input clk, rst,
    output reg [31:0] PC,
    output [31:0] Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7, RF8, RF9, RF10, RF11, RF12,
    output [31:0] DM0, DM4, DM8, DM12, DM16, DM20, DM24, DM28
    );
    // Control Flags
    wire  RegWrite, ALUSrc2, ALUSrc1;
    wire [1:0] ResultSrc,MemWrite;
    wire [2:0] MemRead,br_type;
    wire [3:0] ALUControl;
    //necessary wires and reg for top level Data Path
    wire [31:0] ReadData,RD2, RD1,ImmExt,ALUResult;
    reg [31:0] Result, SrcA, SrcB, PCNext,PCPlus4;
    wire br_taken;

    always @(*) begin
        PCNext <= br_taken ? ALUResult : PCPlus4;
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

    instr_mem IM(.A(PC), .RD(Instr));

    wire [6:0] opcode;
    wire [2:0] func3;
    wire func7_5;
    wire [4:0] A1,A2,A3; 

    //Decode Unit
    DecodeUnit DU(Instr,opcode,func3,func7_5, A1,A2,A3);

    extend EX(.ImmExt(ImmExt), .Instr(Instr));

    register_file RF ( .RD1(RD1), .RD2(RD2), .RF1(RF1), .RF2(RF2), .RF3(RF3), .RF4(RF4), .RF5(RF5),
                    .RF6(RF6), .RF7(RF7),.RF8(RF8), .RF9(RF9), .RF10(RF10), .RF11(RF11), .RF12(RF12), 
                    .WD3(Result), .A1(A1), .A2(A2), .A3(A3), 
                    .WE3(RegWrite), .clk(clk),.rst(rst) );

    always @(*) begin
        SrcA <= ALUSrc1 ? PC : RD1;
    end
    
    always @(*) begin
        SrcB <= ALUSrc2 ? ImmExt : RD2; 
    end
    
    // ALU
    ALU AL(ALUControl,SrcA, SrcB,ALUResult);

    //Branch Module
    Branch Br( br_type, RD1,RD2,br_taken);

    Data_Memory DM( .RD(ReadData),.DM0(DM0), .DM4(DM4), .DM8(DM8),.DM12(DM12), .DM16(DM16), .DM20(DM20), 
                    .DM24(DM24), .DM28(DM28), .WD(RD2), .A(ALUResult), 
                    .WE(MemWrite), .RE(MemRead) , .clk(clk), .rst(rst));

    always @(*) begin
        case (ResultSrc)
            2'b00: Result <= ALUResult;
            2'b01: Result <= ReadData;
            2'b10: Result <= PCPlus4;
            default: Result <= 32'd0;
        endcase
        //Result <= ResultSrc ? ReadData: ALUResult;
    end

    ControlUnit CU( .opcode(opcode), .func3(func3), .func7_5(func7_5), .ResultSrc(ResultSrc),
                    .MemWrite(MemWrite), .ALUSrc2(ALUSrc2), .ALUSrc1(ALUSrc1), .RegWrite(RegWrite), 
                    .ALUControl(ALUControl), .MemRead(MemRead), .br_type(br_type));

endmodule
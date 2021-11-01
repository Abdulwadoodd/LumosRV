`timescale 1ns/1ns

module DecodeUnit (
    input [31:0] Instr,
    output reg [6:0] opcode,
    output reg  [2:0] func3,
    output reg func7_5,
    output reg [4:0] A1,A2,A3 
);
    always @(*) begin
        opcode <= Instr[6:0];
        func3 <= Instr[14:12];
        func7_5 <= Instr[30];
        A1 <= Instr[19:15];
        A2 <= Instr[24:20];
        A3 <= Instr[11:7];
    end
endmodule
`timescale 1ns/1ns

module ALU (
    input [3:0] ALUControl,
    input [31:0] SrcA, SrcB,
    output reg [31:0] ALUResult
);
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = SrcA + SrcB;
            4'b0001: ALUResult = SrcA - SrcB;
            4'b0010: ALUResult = SrcA & SrcB;
            4'b0011: ALUResult = SrcA | SrcB;
            4'b0100: ALUResult = SrcB;
            4'b0101: ALUResult = $signed(SrcA) < $signed(SrcB);
            4'b0110: ALUResult = SrcA ^ SrcB;
            4'b0111: ALUResult = SrcA >> SrcB;
            4'b1000: ALUResult = SrcA << SrcB;
            4'b1001: ALUResult = $signed(SrcA) >>> $signed(SrcB);
            4'b1010: ALUResult = SrcA < SrcB;
            //4'b1011: ALUResult = $signed(SrcA) - $signed(SrcB);
            default: ALUResult = 32'd0;
        endcase
    end
    
endmodule
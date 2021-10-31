`timescale 1ns/1ns

module Branch (
    input [2:0] br_type,
    input [31:0] RD1,RD2,
    output reg br_taken
);
    always@(*)begin
        case (br_type)
            3'b000: br_taken = 1'b0;
            3'b001: br_taken = (RD1 == RD2);  //beq
            3'b010: br_taken = (RD1 != RD2);  //bne
            3'b011: br_taken = (RD1 < RD2);   //sltu
            3'b100: br_taken = (RD1 >= RD2);  //bgeu
            3'b101: br_taken = ($signed(RD1) < $signed(RD2));     //slt
            3'b110: br_taken = ($signed(RD1) >= $signed(RD2));    //bge
            3'b111: br_taken = 1'b1;     // JAL, JALR
            default: br_taken = 1'b0;
        endcase              
    end
    
endmodule
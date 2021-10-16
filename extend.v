`timescale 1ns/1ns

module extend (
    output reg [31:0] ImmExt,
    //input [1:0] ImmSrc,
    input [31:0] Instr
);

    always @(*) begin
        case(Instr[6:0])
            7'b0000011, 7'b0010011:  ImmExt <= {{20{Instr[31]}}, Instr[31:20]};
            7'b0100011:  ImmExt <= {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            7'b1100011:  ImmExt <= {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            7'b1101111:  ImmExt <= {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            7'b0110111:  ImmExt <= Instr[31:12] << 12;
            default:  ImmExt <= 32'b0; 
        endcase
    end
    
endmodule
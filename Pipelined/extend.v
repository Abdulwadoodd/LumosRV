`timescale 1ns/1ns

module extend (
    output reg [31:0] ImmExt,
    input [31:0] Instr
);

    always @(*) begin
        case(Instr[6:0])
            7'b0000011:  ImmExt <= {{20{Instr[31]}}, Instr[31:20]};     // Load type
            7'b0010011: begin               // I type without load
                            case (Instr[14:12])
                                //3'b011: ImmExt <= {{20{1'b0}}, Instr[31:20]};   //SLTIU
                                3'b001, 3'b101: ImmExt <= {{27{1'b0}}, Instr[24:20]};   //SLLI, SRLI, SRAI
                                default: ImmExt <= {{20{Instr[31]}}, Instr[31:20]};  //remaining I-type
                            endcase
                        end 
            7'b0100011:  ImmExt <= {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};   // S-type
            7'b1100011:  ImmExt <= {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; // B-type
            7'b1101111:  ImmExt <= {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; // JAL type
            7'b0110111, 7'b0010111 :  ImmExt <= Instr[31:12] << 12;  // U-type
            7'b1110011:  ImmExt <= {{27{1'b0}},Instr[19:15]};
            default:  ImmExt <= 32'b0; 
        endcase
    end
    
endmodule
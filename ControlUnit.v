`timescale 1ns/1ns

module ControlUnit (
    input [6:0] opcode,
    input [2:0] func3,
    input func7_5,
    output reg [1:0] ResultSrc,MemWrite,
    output reg  ALUSrc2, ALUSrc1, RegWrite,
    output reg [3:0] ALUControl,
    output reg [2:0] MemRead, br_type
);

    reg [1:0] ALUOp;

    always @(*) begin   
        casex ({opcode,func3})
            10'b0110011xxx: begin   // R-type
                                RegWrite = 1;
                                ALUSrc2 = 0;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                ALUOp = 2'b10;
                                MemRead = 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b1100011000: begin   //  BEQ
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b001;
                                ALUSrc1 = 1;
                            end 
            10'b1100011001: begin   //  BNE
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b010;
                                ALUSrc1 = 1;
                            end 
            10'b1100011100: begin   //  BLT 
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b101;
                                ALUSrc1 = 1;
                            end 
            10'b1100011110: begin   //  BLTU
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b011;
                                ALUSrc1 = 1;
                            end
            10'b1100011101: begin   //  BGE 
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b110;
                                ALUSrc1 = 1;
                            end 
            10'b1100011111: begin   //   BGEU
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b100;
                                ALUSrc1 = 1;
                            end
            10'b0010011xxx: begin       // I-type (addi)
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                ALUOp = 2'b10;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end
            
            10'b0010111xxx: begin       // U-Type (auipc)
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 1;
                            end
            10'b0110111xxx: begin       // U-Type (lui)
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                ALUOp = 2'b11;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end
            10'b1101111xxx: begin       // J-type (jal)
                                RegWrite =1;
                                ALUSrc2 = 1'b1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b10;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b111;
                                ALUSrc1 = 1;
                            end
            10'b1100111xxx: begin       // J-type (jalr)
                                RegWrite =1;
                                ALUSrc2 = 1'b1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b10;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b111;
                                ALUSrc1 = 0;
                            end
            10'b0100011000: begin   //sb
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b01;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                        end  
            10'b0100011001: begin   //sh
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b10;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end  
            10'b0100011010: begin   //sw
                                RegWrite = 0;
                                ALUSrc2 = 1;
                                MemWrite = 2'b11;
                                ResultSrc = 2'bxx;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b0000011010: begin // lw
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                ALUOp = 2'b00;
                                MemRead= 3'b000;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b0000011000: begin // lb
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                ALUOp = 2'b00;
                                MemRead= 3'b001;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b0000011001: begin // lh
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                ALUOp = 2'b00;
                                MemRead= 3'b010;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b0000011100: begin // lbu
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                ALUOp = 2'b00;
                                MemRead= 3'b011;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            10'b0000011101: begin // lhu
                                RegWrite = 1;
                                ALUSrc2 = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                ALUOp = 2'b00;
                                MemRead= 3'b100;
                                br_type = 3'b000;
                                ALUSrc1 = 0;
                            end 
            default:    begin       // default
                            RegWrite = 0;
                            ALUSrc2 = 0;
                            MemWrite = 2'b0;
                            ResultSrc = 2'b0;
                            ALUOp = 2'b00;
                            MemRead= 3'b000;
                            br_type = 3'b000;
                            ALUSrc1 = 0;
                        end 
        endcase
    end

    //ALU Decoder
    always @(*) begin
        casex ({ALUOp,func3,opcode[5],func7_5}) 
            7'b00xxxxx, 7'b1000000, 7'b1000001, 7'b1000010, 7'b100000x : ALUControl = 4'b0000;  //add
            7'b01xxxxx, 7'b1000011: ALUControl = 4'b0001;  //sub
            7'b10111xx: ALUControl = 4'b0010;    //AND
            7'b10110xx: ALUControl = 4'b0011;    //OR
            7'b11xxxxx: ALUControl = 4'b0100;    //no operation for U-type
            7'b10010xx: ALUControl = 4'b0101;    //SLT, SLTI
            7'b10100xx: ALUControl = 4'b0110;    //xor
            7'b10101x0: ALUControl = 4'b0111;    //SRL, SRLI
            7'b10001x0: ALUControl = 4'b1000;   //SLL, SLLI
            7'b10101x1: ALUControl = 4'b1001;   //SRA, SRAI
            7'b10011xx: ALUControl = 4'b1010;   //SLTU, SLTIU
            default: ALUControl = 4'b000;
        endcase
    end


 
endmodule
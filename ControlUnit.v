`timescale 1ns/1ns

module ControlUnit (
    input [6:0] opcode,
    input [2:0] func3,
    input func7_5, zero,
    output reg [1:0] ResultSrc,MemWrite,
    output reg  ALUSrc, RegWrite, PCSrc,
    //output reg [1:0] ImmSrc,
    output reg [2:0] ALUControl
);

    reg [1:0] ALUOp;
    reg Branch,Jump;
    always @(*) begin   
        casex ({opcode,func3})
            10'b0000011xxx: begin // lw
                                RegWrite = 1;
                                //ImmSrc = 2'b00;
                                ALUSrc = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b01;
                                Branch = 0;
                                ALUOp = 2'b00;
                                Jump = 0;
                            end 
            10'b0110011xxx: begin   // R-type
                                RegWrite = 1;
                                //ImmSrc = 2'bxx;
                                ALUSrc = 0;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                Branch = 0;
                                ALUOp = 2'b10;
                                Jump = 0;
                            end 
            10'b1100011xxx: begin   //  B-Type (beq, bne)
                                RegWrite = 0;
                                //ImmSrc = 2'b10;
                                ALUSrc = 0;
                                MemWrite = 2'b00;
                                ResultSrc = 2'bxx;
                                Branch = 1;
                                ALUOp = 2'b01;
                                Jump = 0;
                            end 
            10'b0010011xxx: begin       // I-type (addi)
                                RegWrite = 1;
                                //ImmSrc = 2'b00;
                                ALUSrc = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                Branch = 0;
                                ALUOp = 2'b10;
                                Jump = 0;
                            end
            
            10'b0110111xxx: begin       // U-Type
                                RegWrite = 1;
                                ALUSrc = 1;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b00;
                                Branch = 0;
                                ALUOp = 2'b11;
                                Jump = 0;
                            end
            10'b1101111xxx: begin       // J-type (jal)
                                RegWrite =1;
                                ALUSrc = 1'bx;
                                MemWrite = 2'b00;
                                ResultSrc = 2'b10;
                                Branch = 0;
                                ALUOp = 2'bxx;
                                Jump = 1;
                            end
            10'b0100011000: begin   //sb
                                RegWrite = 0;
                                //ImmSrc = 2'b01;
                                ALUSrc = 1;
                                MemWrite = 2'b01;
                                ResultSrc = 2'bxx;
                                Branch = 0;
                                ALUOp = 2'b00;
                                Jump = 0;
                        end  
            10'b0100011001: begin   //sh
                                RegWrite = 0;
                                //ImmSrc = 2'b01;
                                ALUSrc = 1;
                                MemWrite = 2'b10;
                                ResultSrc = 2'bxx;
                                Branch = 0;
                                ALUOp = 2'b00;
                                Jump = 0;
                            end  
            10'b0100011010: begin   //sw
                                RegWrite = 0;
                                //ImmSrc = 2'b01;
                                ALUSrc = 1;
                                MemWrite = 2'b11;
                                ResultSrc = 2'bxx;
                                Branch = 0;
                                ALUOp = 2'b00;
                                Jump = 0;
                            end 
            default:    begin       // default
                            RegWrite = 0;
                            //ImmSrc = 2'b00;
                            ALUSrc = 0;
                            MemWrite = 2'b0;
                            ResultSrc = 2'b0;
                            Branch = 0;
                            ALUOp = 2'b00;
                            Jump = 0;
                        end 
        endcase
    end

    //ALU Decoder
    always @(*) begin
        casex ({ALUOp,func3,opcode[5],func7_5})
            7'b00xxxxx: ALUControl = 3'b000; 
            7'b01xxxxx: ALUControl = 3'b001;
            7'b1000000, 7'b1000001, 7'b1000010, 7'b100000x : ALUControl = 3'b000;
            7'b1000011: ALUControl = 3'b001;
            7'b10010xx: ALUControl = 3'b101;
            7'b10110xx: ALUControl = 3'b011;
            7'b10111xx: ALUControl = 3'b010;
            7'b10100xx: ALUControl = 3'b110;//xor
            7'b10101xx: ALUControl = 3'b111;//srl
            7'b11xxxxx: ALUControl = 3'b100;
            default: ALUControl = 3'b000;
        endcase
    end

    reg check;

    always @(*) begin
        check = Branch & zero;
    end

    always @(*) begin
        PCSrc = check | Jump;
    end

 
endmodule
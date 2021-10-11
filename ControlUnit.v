`timescale 1ns/1ns

module ControlUnit (
    input [6:0] opcode,
    input [2:0] func3,
    input func7_5, zero,
    output reg ResultSrc, MemWrite, ALUSrc, RegWrite, PCSrc,
    output reg [1:0] ImmSrc,
    output reg [2:0] ALUControl
);

    reg [1:0] ALUOp;
    reg Branch;

    always @(*) begin
        
        casex (opcode)
            7'b0000011: begin // lw
                            RegWrite = 1;
                            ImmSrc = 2'b00;
                            ALUSrc = 1;
                            MemWrite = 0;
                            ResultSrc = 1;
                            Branch = 0;
                            ALUOp = 2'b00;
                        end 
            7'b0100011: begin   //sw
                            RegWrite = 0;
                            ImmSrc = 2'b01;
                            ALUSrc = 1;
                            MemWrite = 1;
                            ResultSrc = 1'bx;
                            Branch = 0;
                            ALUOp = 2'b00;
                        end 

            7'b0110011: begin   // R-type
                            RegWrite = 1;
                            ImmSrc = 2'bxx;
                            ALUSrc = 0;
                            MemWrite = 0;
                            ResultSrc = 0;
                            Branch = 0;
                            ALUOp = 2'b10;
                        end 
            7'b1100011: begin   // beq, bne
                            RegWrite = 0;
                            ImmSrc = 2'b10;
                            ALUSrc = 0;
                            MemWrite = 0;
                            ResultSrc = 1'bx;
                            Branch = 1;
                            ALUOp = 2'b01;
                        end 
            7'b0010011: begin       // addi
                            RegWrite = 1;
                            ImmSrc = 2'b00;
                            ALUSrc = 1;
                            MemWrite = 0;
                            ResultSrc = 0;
                            Branch = 0;
                            ALUOp = 2'b10;
                        end 
            default:    begin       // addi
                            RegWrite = 0;
                            ImmSrc = 2'b00;
                            ALUSrc = 0;
                            MemWrite = 0;
                            ResultSrc = 0;
                            Branch = 0;
                            ALUOp = 2'b00;
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

            
            default: ALUControl = 3'b000;
        endcase
    end

    always @(*) begin
        PCSrc = Branch & zero;
    end

    


    
endmodule
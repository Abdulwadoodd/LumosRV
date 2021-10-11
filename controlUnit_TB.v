`timescale 1ns/1ns

module controlUnit_TB();
    reg [6:0] opcode;
    reg [2:0] func3;
    reg func7_5, zero;
    wire ResultSrc, MemWrite, ALUSrc, RegWrite, PCSrc;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl;

    ControlUnit DUT( opcode, func3, func7_5, zero,
        ResultSrc, MemWrite, ALUSrc, RegWrite, PCSrc,
        ImmSrc, ALUControl);
    
    initial begin
        opcode = 7'b0000000;
        func3 = 3'b000;
        func7_5 = 0;
        zero=0;

        #30

        opcode = 7'b0000011;    //lw
        func3 = 3'b010;
        func7_5 = 0;
        zero=0;

        #30

        opcode = 7'b0100011;    //sw
        func3 = 3'b010;
        func7_5 = 0;
        zero=0;

        #30

        opcode = 7'b0010011;    //addi
        func3 = 3'b000;
        func7_5 = 1'bx;
        zero=0;

        #30

        opcode = 7'b1100011;     //beq
        func3 = 3'b000;
        func7_5 = 1'bx;
        zero=0;

        #30

        opcode = 7'b1100011;     //beq
        func3 = 3'b000;
        func7_5 = 1'bx;
        zero=1;

        #30

        opcode = 7'b0110011;     //sub
        func3 = 3'b000;
        func7_5 = 1'b1;
        zero=0;

        #30

        opcode = 7'b0110011;     //srl
        func3 = 3'b101;
        func7_5 = 1'bx;
        zero=0;

        #30

        opcode = 7'b0110011;     //xor
        func3 = 3'b100;
        func7_5 = 1'bx;
        zero=0;
    end

endmodule
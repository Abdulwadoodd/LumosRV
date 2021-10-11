`timescale 1ns/1ns

module extend_TB();

    wire [31:0] ImmExt;
    reg [1:0] ImmSrc;
    reg [31:0] Instr;

    extend DUT(ImmExt, ImmSrc, Instr);

    initial begin

        Instr = 32'h0;
        ImmSrc = 2'b0;
        
        #20
        Instr = 32'h202223;     // S-Type Instruction  sw
        ImmSrc = 2'b01;

        #20 
        Instr = 32'h1c00113;    //I-Type Instr  addi
        ImmSrc = 2'b00;

        #20
        Instr = 32'h402103;     // I-type  lw
        

        #20
        Instr = 32'h2208263;     // SB-Type instr beq
        ImmSrc = 2'b10;

        

    end



endmodule
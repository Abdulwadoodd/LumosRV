`timescale 1ns/1ns

module toplevel_TB();
    reg clk,rst;
    wire [31:0] PC,Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7,DM0,DM4,DM8;
    //wire [3:0] ALUControl;
    top_level DUT(clk, rst, PC,Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7, DM0, DM4, DM8);
    
    initial clk=0;
    always #5 clk = ~clk; 

    initial begin
        rst=1;
        #30
        rst=0;
    end

endmodule
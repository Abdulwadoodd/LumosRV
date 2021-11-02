`timescale 1ns/1ns

module toplevel_TB();
    reg clk,rst;
    wire [31:0] PC, Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7,RF8, RF9, RF10, RF11, RF12,DM0,DM4,DM8, DM12, DM16, DM20, DM24, DM28;
    
    top_level DUT(clk, rst, PC,Instr, RF1, RF2, RF3, RF4, RF5, RF6, RF7,RF8, RF9, RF10, RF11, RF12, DM0, DM4, DM8, DM12, DM16, DM20, DM24, DM28);
    
    initial clk=0;
    always #5 clk = ~clk; 

    initial begin
        rst=1;
        #30
        rst=0;
    end

endmodule
`timescale 1ns/1ns

module toplevel_TB();
    reg clk,rst,intr_excep;
    wire [31:0] PC, InstrF, RF1, RF2, RF3, RF4, RF5, RF6, RF7,RF8, RF9, RF10, RF11, RF12,DM0,DM4,DM8, DM12, DM16, DM20, DM24, DM28;
    
    top_level DUT(clk, rst, intr_excep, PC,InstrF, RF1, RF2, RF3, RF4, RF5, RF6, RF7, RF8, RF9, RF10, RF11, RF12, DM0, DM4, DM8, DM12, DM16, DM20, DM24, DM28);
    
    initial clk=0;
    always #5 clk = ~clk; 

    initial begin
        rst=1;
        intr_excep = 1'b0;
        #30
        rst=0;
        #150
        intr_excep = 1'b1;
        #6
        intr_excep = 1'b0;
    end

endmodule
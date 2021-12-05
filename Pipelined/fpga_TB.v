`timescale 1ns/1ns

module fpga_TB();
    reg clk, rst;
    wire [7:0] anode;
    wire [6:0] data;
    //wire[31:0] DM0, DM4, DM8;

    fpga DUT(clk, rst,anode,data);

    initial clk=0;
    always #5 clk = ~clk; 

    initial begin
        rst=1;
        #30
        rst=0;
    end
    
endmodule
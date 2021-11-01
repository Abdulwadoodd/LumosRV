`timescale 1ns/1ns

module Data_Mem_TB();
    wire [31:0] RD;

    reg [31:0] WD;
    reg [7:0] A;
    reg WE, clk,rst;

    Data_Memory DUT( RD, WD,  A, WE, clk, rst);
    
    initial clk=0;
    always #5 clk = ~clk;

    initial begin
        
        rst=1;
        WE = 0;
        A = 0;
        WD =0;
        #50
        rst =0;
        #20

        WE = 1;
        A = 8'h4;
        WD = 32'h69;
        #20
        WE = 0;
        A=0;
        #20
        WE=1;
        A = 8'h8;
        WD = 32'h70;
        #20
        WE = 0;
        A=8'h4;
        #20
        A = 8'h8;

    end  
    
endmodule
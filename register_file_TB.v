`timescale 1ns/1ns

module register_file_TB();
    wire [31:0] RD1,RD2;
    //wire [31:0] Reg_File [31:0];

    reg [31:0] WD3;
    reg [4:0] A1,A2,A3;
    reg WE3, clk,rst;

    register_file DUT( RD1, RD2, WD3, A1, A2, A3, WE3, clk,rst );
	
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        
        rst = 1;
        WE3 = 0;

        WD3 = 32'h24;
        A1= 5'h0;
        A2= 5'h0;
        A3= 5'h0;

        #20

        rst = 0;

        #20

        WE3 = 1;
        A3 = 5'h4;
        WD3 = 32'h71;

        #20
        
        WE3 = 0;
        A3 = 0;
        A1 = 5'h0;
        A2 = 0;
        #10

        WE3 = 1;
        A3 = 5'h8;
        WD3 = 32'h72;
        
        #20
        
        WE3=0;
        A1 = 5'h4;
        
        #20
        WE3=1;
        A3 = 5'h12;
        WD3 = 32'h69;
        #20
        A1 = 5'h4;
        A2 = 5'h8;
        WE3=0;
        WD3 = 32'h70;
        #20
        
        WE3=1;
        A3 = 5'h16;
        A1 = 5'h12;
        
        #20
        WE3=0;
        A2 = 5'h16;







    end

    
endmodule
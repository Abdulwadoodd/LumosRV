`timescale 1ns/1ns

module addr_gen_TB();
    wire [31:0] pc;

    reg clk, rst, pc_src;
    reg [31:0] PCTarget;

    address_generator DUT(PCTarget,clk, rst, pc_src , pc);
    initial clk=0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        pc_src = 0;
        PCTarget = 32'hA1;

        #20

        rst = 0;

        #100

        pc_src=1;
        
        #10

        pc_src=0;
        
        #50 
        pc_src =1;
        PCTarget = 32'd32;
        
        #10
        pc_src = 0;




    end
endmodule
`timescale 1ns/1ns

module address_generator ( input [31:0] PCTarget, input clk, rst, pc_src , output reg [31:0] pc);

	always @(posedge clk) begin
		if(rst)
			pc <= 32'h0;
		else if(!pc_src)
			pc <= pc + 4;
		else
			pc <= PCTarget;
	end
	
endmodule
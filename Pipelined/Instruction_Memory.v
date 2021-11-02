`timescale 1ns/1ns

module instr_mem (input [31:0] A,output reg [31:0] RD);
	
	reg [31:0] mem[0:1023];

	initial begin
		$readmemh ("code.mem",mem);
	end
	always @(*) begin
		RD <= mem[A/4];
	end
	
endmodule
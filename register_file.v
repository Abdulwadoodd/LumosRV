`timescale 1ns/1ns
module register_file( RD1, RD2, RF1, RF2, RF3, RF4, RF5, RF6, RF7,RF8, RF9, RF10, RF11, RF12, WD3, A1, A2, A3, WE3, clk,rst);
	
	output reg [31:0] RD1, RD2, RF1, RF2, RF3, RF4, RF5, RF6, RF7,RF8, RF9, RF10, RF11, RF12;			// Data to be provided from register to execute the instruction
	input [31:0] WD3;						// Data to be loaded in the register
	input [4:0] A1, A2, A3;	// Address (or number) of register to be Written or to be read
	input WE3, clk,rst;							// input clock, and WE3 flag input

    reg [31:0] Reg_File [31:0];				// Register file
	integer i;
	always @ (posedge clk)
	begin
		
		if(rst)begin
			for(i=0;i<32;i=i+1)
				Reg_File[i] <= 32'h0;
		end
	
		else if(WE3)begin						// Writing data to the register file
			Reg_File[A3] <= WD3; 
		end
		
	end
	always @(*) begin
		RD1 <= Reg_File[A1];
		RD2 <= Reg_File[A2];
		Reg_File[5'd0] = 32'd0;
		RF1 <= Reg_File[5'd1];
		RF2 <= Reg_File[5'd2];
		RF3 <= Reg_File[5'd3];
		RF4 <= Reg_File[5'd4];
		RF5 <= Reg_File[5'd5];
		RF6 <= Reg_File[5'd6];
		RF7 <= Reg_File[5'd7];
		RF8 <= Reg_File[5'd8];
		RF9 <= Reg_File[5'd9];
		RF10 <= Reg_File[5'd10];
		RF11 <= Reg_File[5'd11];
		RF12 <= Reg_File[5'd12];
	end

endmodule
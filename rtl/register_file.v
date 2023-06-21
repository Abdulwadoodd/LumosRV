
module register_file( 
	output reg [31:0] RD1, RD2, 
	
	input [31:0] WD3, 
	input [4:0] A1, A2, A3, 
	input WE3, clk, rst);
	
	//output reg [31:0] RD1, RD2;				// Data to be provided from register to execute the instruction
	//input [31:0] WD3;							// Data to be loaded in the register
	//input [4:0] A1, A2, A3;					// Address (or number) of register to be Written or to be read
	//input WE3, clk,rst;						// input clock, and WE3 flag input

    reg [31:0] Reg_File [31:0];					// Register file
	integer i;
	always @ (negedge clk)
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
		RD1 <= A1 ? Reg_File[A1] : 32'd0;
		RD2 <= A2 ? Reg_File[A2] : 32'd0;
	end

endmodule
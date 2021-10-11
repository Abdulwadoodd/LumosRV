module Data_Memory(output reg [31:0] RD, DM0,DM4,DM8,
					input [31:0] WD, input [31:0] A, input WE, input clk, input rst);
		
		reg [31:0] Mem [255:0];			// Data Memory
		integer i;
		always @ (posedge clk)
		begin	
			if(rst)begin
				for(i=0;i<256;i=i+1)
					Mem[i] <= 32'b0;
			end
			else if(WE) begin			// store type instruction : writing to the memory
				Mem[A] <= WD;
			end
		end
		// Load type instruction : reading from the memory
		always @(*) begin
			RD <= Mem[A];
			DM0 <= Mem[32'h0];
			DM4 <= Mem[32'h4];
			DM8 <= Mem[32'h8];
		end
		
		

endmodule

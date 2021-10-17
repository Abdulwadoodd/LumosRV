module Data_Memory(output reg [31:0] RD, DM0,DM4,DM8,
					input [31:0] WD, input [31:0] A, input [1:0] WE, input clk, input rst);
		
		reg [31:0] Mem [255:0];			// Data Memory
		integer i;
		reg [31:0] MemIn;
		always @(*) begin
			case (WE)
				2'b00: MemIn <= Mem[A];		//retain value
				2'b01: MemIn <= WD[7:0];	// sb
				2'b10: MemIn <= WD[15:0];	//sh
				2'b11: MemIn <= WD;			//sw
			endcase
		end

		always @ (posedge clk)
		begin	
			if(rst)begin
				for(i=0;i<256;i=i+1)
					Mem[i] <= 32'b0;
			end
			else 
				Mem[A] <= MemIn;
			// else if(WE) begin			// store type instruction : writing to the memory
			// 	Mem[A] <= WD;
			// end
		end
		// Load type instruction : reading from the memory
		always @(*) begin
			RD <= Mem[A];
			DM0 <= Mem[32'h0];
			DM4 <= Mem[32'h4];
			DM8 <= Mem[32'h8];
		end

endmodule

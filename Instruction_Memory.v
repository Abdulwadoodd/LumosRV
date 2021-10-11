`timescale 1ns/1ns

module instr_mem (input [31:0] A,output reg [31:0] RD);
	
	always@(A)
	begin
	
	case (A)
		32'h00: RD <= 32'h0;
		32'h04: RD <= 32'h2400093;
		32'h08: RD <= 32'h102023;
		32'h0c: RD <= 32'h1c00113;
		32'h10: RD <= 32'h202223;
		32'h14: RD <= 32'h2083;
		32'h18: RD <= 32'h402103;
		32'h1c: RD <= 32'h100193;
		32'h20: RD <= 32'h1f00313;
		32'h24: RD <= 32'h2208263;
		32'h28: RD <= 32'h40110233;
		32'h2c: RD <= 32'h6252b3;
		32'h30: RD <= 32'h518863;
		32'h34: RD <= 32'h40110133;
		32'h38: RD <= 32'hfe2096e3;
		32'h3c: RD <= 32'h208663;
		32'h40: RD <= 32'h402080b3;
		32'h44: RD <= 32'hfe2090e3;
		32'h48: RD <= 32'h102423;	
		
		default RD <= 32'h0;
	endcase
	
	
	end

endmodule
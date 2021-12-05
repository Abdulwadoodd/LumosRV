`timescale 1ns/1ns

module fpga (
    input clk, rst,
    output reg [7:0] anode,
    output reg [6:0] data
    //output [31:0] DM0, DM4, DM8
);
    //input clk, rst,
    wire[31:0] PC;
    wire [31:0] InstrF, RF1, RF2, RF3, RF4, RF5, RF6, RF7, RF8, RF9, RF10, RF11, RF12;
    wire [31:0]  DM0, DM4, DM8,DM12, DM16, DM20, DM24, DM28;
    

    top_level top(clk, rst, PC,
    InstrF, RF1, RF2, RF3, RF4, RF5, RF6, RF7, RF8, RF9, RF10, RF11, RF12,
    DM0, DM4, DM8, DM12, DM16, DM20, DM24, DM28 );

   wire new_clk;
   clkdiv clockdiv(.clock_in(clk),.clock_out(new_clk));

    //Shift registers for seven segment anodes
    always @(posedge new_clk) begin
        if(rst) begin		
            anode[7] <= 0;
            anode[6] <= 1;
            anode[5] <= 1;
            anode[4] <= 1;
            anode[3] <= 1;
            anode[2:0] <= 3'b111;
        end 
        else begin
            anode[7] <= anode[3];
            anode[6] <= anode[7];
            anode[5] <= anode[6] ;
            anode[4] <= anode[5];
            anode[3] <= anode[4];
        end
    end
    reg [2:0] sel;
    reg [3:0] out;
    always @(*) begin
        case (anode[7:3])
            5'b01111: sel = 3'b000;
            5'b10111: sel = 3'b001;
            5'b11011: sel = 3'b010;
            5'b11101: sel = 3'b011;
            5'b11110: sel = 3'b100;
            default:  sel = 3'b000;
        endcase
    end
    always @(*) begin
        case (sel)
            3'b000: out <= DM0[7:4];
            3'b001: out <= DM0[3:0];
            3'b010: out <= DM4[7:4];
            3'b011: out <= DM4[3:0];
            3'b100: out <= DM8[3:0];
            default: out <= 4'b0000;
        endcase
    end

    always @(*) begin			// BCD to 7-segment decoder
        case(out)
        4'b0000: data = 7'b0000001; // "0"     
        4'b0001: data = 7'b1001111; // "1" 
        4'b0010: data = 7'b0010010; // "2" 
        4'b0011: data = 7'b0000110; // "3" 
        4'b0100: data = 7'b1001100; // "4" 
        4'b0101: data = 7'b0100100; // "5" 
        4'b0110: data = 7'b0100000; // "6" 
        4'b0111: data = 7'b0001111; // "7" 
        4'b1000: data = 7'b0000000; // "8"     
        4'b1001: data = 7'b0000100; // "9"
	    4'b1010: data = 7'b0001000; // "A"     
        4'b1011: data = 7'b1100000; // "b"     
        4'b1100: data = 7'b0110001; // "C"     
        4'b1101: data = 7'b1000010; // "d"     
        4'b1110: data = 7'b0110000; // "E"     
        4'b1111: data = 7'b0111000; // "F"     
        default: data = 7'b0000001; // "0"
        endcase
    end
endmodule
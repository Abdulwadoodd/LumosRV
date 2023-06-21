`timescale 1ns/1ns

module HazardUnit (
    input rst,RegWriteW,RegWriteM,br_taken,
    input [1:0] ResultSrcE,
    input [31:0] InstrE,InstrW,InstrM,InstrD,
    output reg [1:0] ForA,ForB,
    output reg FlushE, FlushD, StallD, StallF
);
    reg [4:0] Rs1E, Rs2E, Rs1D, Rs2D, RdM, RdW, RdE;
    reg ResultSrcE_o;

    always @(*) begin
        // Data hazard
        Rs1E <= InstrE[19:15];
        Rs2E <= InstrE[24:20];
        RdM <= InstrM[11:7];
        RdW <= InstrW[11:7];
        //lw stall
        Rs1D <= InstrD[19:15];
        Rs2D <= InstrD[24:20];
        RdE <= InstrE[11:7];
        ResultSrcE_o <= ResultSrcE[0];
    end
    //-------------------------FORWARDING----------------
    always @(*) begin
        if ((Rs1E == RdM) & RegWriteM & (Rs1E != 0))  // Forward from Memory stage
            ForA = 2'b10;
        else if ((Rs1E == RdW) & RegWriteW & (Rs1E != 0))  // Forward from Writeback stage
            ForA = 2'b01;
        else 
            ForA = 2'b00;
    end
    always @(*) begin
        if ((Rs2E == RdM) & RegWriteM & (Rs2E != 0))  // Forward from Memory stage
            ForB = 2'b10;
        else if ((Rs2E == RdW) & RegWriteW & (Rs2E != 0))  // Forward from Writeback stage
            ForB = 2'b01;
        else 
            ForB = 2'b00;
    end

    //------------------------LW Stalling- && Control Hazard------------------
    reg lwStall; 
    always @(*) begin
        if(rst)begin
            StallF = 0;
            StallD = 0;
            FlushD = 0;
            FlushE = 0;
        end
        else begin
            lwStall = ResultSrcE_o & ((Rs1D == RdE) | (Rs2D == RdE));
            FlushE = lwStall | br_taken;
            FlushD = br_taken;
            StallD = lwStall;
            StallF = lwStall;
        end
    end

endmodule
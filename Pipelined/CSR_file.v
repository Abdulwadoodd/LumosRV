`timescale 1ns/1ns

module CSR_file (
    input [31:0] csr_rs1M, instrM,PCM,
    input clk, rst,intr_excep,
    output reg j_hand, intFD, intFE, intFM, intFW,
    output reg [31:0] CSR_RD, epc
);

    reg [31:0] CSR_file [10:0];
    // csrrw for write: csr = rs1, x0 = csr;  here x0=rd
    // csrrs for read and set:  rd = csr, csr = csr | x0 ; here x0 = rs1
    // csrrc for read and clear: rd = csr, csr= csr & x0 ; here x0 = rs1
    reg [31:0] mip,mie,mstatus, mepc,mtvec;
    always @(*) begin
        mip <= CSR_file[12'd0];
        mie <= CSR_file[12'd1];
        mstatus <= CSR_file[12'd3];
        // mcause <= CSR_file[12'd4];
        mtvec <= CSR_file[12'd5];
        mepc <= CSR_file[12'd6];
    end

    always @(*) begin
        mip[11] <= intr_excep;
        mtvec[31:2] <= 30'd8; 
    end

    reg [6:0] opcode;
    reg [11:0] addr;
    reg [2:0] func3;
    always @(*) begin
        opcode <= instrM[6:0];
        func3 <= instrM[14:12]; 
        addr <= instrM[31:20];
    end
    reg [31:0] CSR_IN;
    reg [1:0] wr_sel;
    always @(*) begin  
        case ({opcode,func3})
            10'b1110011001 ,10'b1110011101 : wr_sel <= 2'b01;   //csrrw
            10'b1110011010 ,10'b1110011110 : wr_sel <= 2'b10;   //csrrs
            10'b1110011011 ,10'b1110011111 : wr_sel <= 2'b11;   //csrrc
            default: wr_sel <= 2'b00;
        endcase
    end
    //MUX for selecting whether csrrw, csrrs, csrrc
    always @(*) begin
        case (wr_sel)
            2'b00: CSR_IN <= CSR_file[addr];
            2'b01: CSR_IN <= csr_rs1M;
            2'b10: CSR_IN <= csr_rs1M | CSR_file[addr];
            2'b11: CSR_IN <= csr_rs1M & CSR_file[addr];
            default: CSR_IN <= 32'd0;
        endcase
    end

    integer i;
    always @(posedge clk) begin
        if(rst)begin
            for(i=0;i<11;i=i+1)
					CSR_file[i] <= 32'b0;
            j_hand <= 0;
            intFD <= 0;
            intFE <= 0;
            intFM <= 0;
            intFW <= 0;
            epc <= 0;
        end
        if(!rst)begin
            CSR_file[addr] <= CSR_IN;
        end
        
    end
    always @(*) begin
        if((mip[11]==1'b1) & (mie[11]==1'b1) & (mstatus[3]==1'b1))begin
            mepc <= PCM;
            j_hand <= 1'b1;
            intFD <= 1'b1;
            intFE <= 1'b1;
            intFM <= 1'b1;
            intFW <= 1'b1;
            epc <= {{2{1'b0}},mtvec}>>2;
        end
        else begin
            j_hand <= 1'b0;
            intFD <= 1'b0;
            intFE <= 1'b0;
            intFM <= 1'b0;
            intFW <= 1'b0;
        end
    end
    always @(*) begin
        if(instrM==32'h0000073)begin
            epc <= mepc;
            j_hand <= 1'b1;
        end
    end

    always @(*) begin
        CSR_RD <= CSR_file[addr];
        //j_hand <= 1'b0;
    end



endmodule
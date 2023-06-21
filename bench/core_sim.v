`timescale 1ns/1ns

module core_sim(input clk, input rst);
    
    core_top DUT(
        .clk(clk), 
        .rst(rst)
    );
    
    reg [1023:0] firmware;
    initial begin
        if($value$plusargs("imem=%s",firmware)) begin
            $display("Loading Instruction Memory from %0s", firmware);
            $readmemh(firmware, DUT.mem_inst.dualport_mem);
        end
    end

    // ====================== For RISC-V architecture tests ========================== //

    wire sig_en  = (DUT.mem_inst.i_dmem_addr == 32'h8E000000) & (DUT.mem_inst.i_dmem_wr_type==2'b11);
    wire halt_en = (DUT.mem_inst.i_dmem_addr == 32'h8F000000) & (DUT.mem_inst.i_dmem_wr_type==2'b11);
    
    reg [1023:0] signature_file;

    integer write_sig=0;
    
    initial begin
        if($value$plusargs("signature=%s",signature_file)) begin
            $display("Writing signature to %0s", signature_file);
            write_sig=$fopen(signature_file,"w");
        end
    end
    
    always @ (posedge clk) begin 
        if(sig_en & (write_sig!=0))
            $fwrite(write_sig,"%h\n",DUT.mem_inst.i_dmem_wdata);
        else if(halt_en) begin
            $display("Test Complete");
            $fclose(write_sig);
            $finish;
        end
    end

endmodule
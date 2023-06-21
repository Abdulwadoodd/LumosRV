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
    `ifdef ACT
        wire sig_en  = (DUT.mem_inst.i_dmem_addr == 32'h8E000000) & (DUT.mem_inst.i_dmem_wr_type==2'b11);
        wire halt_en = (DUT.mem_inst.i_dmem_addr == 32'h8F000000) & (DUT.mem_inst.i_dmem_wr_type==2'b11);
        
        integer write_sig;
        
        initial begin
            write_sig = $fopen("DUT-core.signature", "w"); // Open file for writing
        
            if (write_sig == 0) begin
              $display("Error opening file for writing");
              $finish;
            end
        end
        
        // Write data to the file
        always @ (posedge clk) begin 
            if(sig_en) begin
                //$display("%h\n",DUT.mem_inst.i_dmem_wdata);
                $fwrite(write_sig,"%h\n",DUT.mem_inst.i_dmem_wdata);
            end
            else if(halt_en) begin
                $display("Test Complete");
                $fclose(write_sig);
                $finish;
            end
        end  
    `endif

endmodule
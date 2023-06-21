
module core_top (input clk, rst);

    wire [31:0] imem_addr, imem_instr, dmem_rdata, dmem_wdata, dmem_addr;
    wire [1:0] dmem_wr_type;
    wire [2:0] dmem_rd_type;
    wire dmem_wr_en, dmem_rd_en;

    pipeline_top pipe_inst(
        //imem interface
        .o_imem_addr(imem_addr),
        .i_imem_instr(imem_instr),

        // dmem interface
        .i_dmem_rdata(dmem_rdata),
        .o_dmem_wdata(dmem_wdata),
        .o_dmem_addr(dmem_addr),
        .o_dmem_wr_type(dmem_wr_type), .o_dmem_rd_type(dmem_rd_type),
        .o_dmem_wr_en(dmem_wr_en), .o_dmem_rd_en(dmem_rd_en),

        .clk(clk), .rst(rst)
    );
    
    main_memory mem_inst(
        //imem interface
        .i_imem_addr(imem_addr),
        .o_imem_instr(imem_instr),

        // dmem interface
        .o_dmem_rdata(dmem_rdata),
        .i_dmem_wdata(dmem_wdata),
        .i_dmem_addr(dmem_addr),
        .i_dmem_wr_type(dmem_wr_type), .i_dmem_rd_type(dmem_rd_type),
        .i_dmem_wr_en(dmem_wr_en), .i_dmem_rd_en(dmem_rd_en),

        .clk(clk), .rst(rst)
    );




endmodule
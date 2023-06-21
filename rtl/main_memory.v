
module main_memory(
    //imem interface
    input [31:0] i_imem_addr,
    output [31:0] o_imem_instr,

    // dmem interface
    output reg [31:0] o_dmem_rdata,
    input [31:0] i_dmem_wdata,
    input [31:0] i_dmem_addr,
    input [1:0] i_dmem_wr_type,
    input [2:0] i_dmem_rd_type,
    input i_dmem_wr_en, i_dmem_rd_en,

    input clk, rst
);
    localparam MEMSIZE = 32'h02000000 ;

    reg [31:0] dualport_mem [MEMSIZE:0];

    // Port  1: Instruction Memory
    assign o_imem_instr = dualport_mem[i_imem_addr>>2];

    // Port 2: Data Memory
    // Store unit 
    reg [31:0] dmem_wdata = 32'd0;

    always @(posedge clk) begin
        if(i_dmem_wr_en) begin
            case(i_dmem_wr_type)
                2'b01: begin        // sb
                    case(i_dmem_addr[1:0])
                        2'b00: dualport_mem[i_dmem_addr>>2][7:0] = i_dmem_wdata[7:0];
                        2'b01: dualport_mem[i_dmem_addr>>2][15:8] = i_dmem_wdata[7:0];
                        2'b10: dualport_mem[i_dmem_addr>>2][23:16] = i_dmem_wdata[7:0];
                        2'b11: dualport_mem[i_dmem_addr>>2][31:24] = i_dmem_wdata[7:0];
                    endcase
                end
                2'b10: begin        // sh
                    case(i_dmem_addr[1])
                        1'b0: dualport_mem[i_dmem_addr>>2][15:0] = i_dmem_wdata[15:0];
                        1'b1: dualport_mem[i_dmem_addr>>2][31:16] = i_dmem_wdata[15:0];
                    endcase
                end
                2'b11: dualport_mem[i_dmem_addr>>2] = i_dmem_wdata;   // sw

                default: dualport_mem[i_dmem_addr>>2] = 0;
            endcase
        end
    end
    
    // load unit
    reg [31:0] dmem_rdata;

    always @(*) begin
        if(i_dmem_rd_en) dmem_rdata = dualport_mem[i_dmem_addr>>2];
    end
    
    always @(*) begin
        case (i_dmem_rd_type)
            3'b000: o_dmem_rdata = dmem_rdata;	// lw
            3'b001: begin //lb
                case (i_dmem_addr[1:0])
                    2'b00: o_dmem_rdata = {{24{dmem_rdata[7]}},dmem_rdata[7:0]};
                    2'b01: o_dmem_rdata = {{24{dmem_rdata[7]}},dmem_rdata[15:8]};
                    2'b10: o_dmem_rdata = {{24{dmem_rdata[7]}},dmem_rdata[23:16]};
                    2'b11: o_dmem_rdata = {{24{dmem_rdata[7]}},dmem_rdata[31:24]};
                endcase 
            end 
            3'b010: begin // lh
                case (i_dmem_addr[1])
                    1'b0: o_dmem_rdata = {{16{dmem_rdata[15]}},dmem_rdata[15:0]};
                    1'b1: o_dmem_rdata = {{16{dmem_rdata[15]}},dmem_rdata[31:16]};
                endcase
            end
            3'b011: begin // lbu
                case (i_dmem_addr[1:0])
                    2'b00: o_dmem_rdata = {{24{1'b0}},dmem_rdata[7:0]};
                    2'b01: o_dmem_rdata = {{24{1'b0}},dmem_rdata[15:8]};
                    2'b10: o_dmem_rdata = {{24{1'b0}},dmem_rdata[23:16]};
                    2'b11: o_dmem_rdata = {{24{1'b0}},dmem_rdata[31:24]};
                endcase 
            end
            3'b100: begin // lhu
                case (i_dmem_addr[1])
                    1'b0: o_dmem_rdata = {{16{1'b0}},dmem_rdata[15:0]};
                    1'b1: o_dmem_rdata = {{16{1'b0}},dmem_rdata[31:16]};
                endcase
            end	
            default: o_dmem_rdata = 0; 
        endcase
    end

endmodule
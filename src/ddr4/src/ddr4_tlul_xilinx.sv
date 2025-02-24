/*
    Connecting the DDR4 wrapper to a TLUL interface through a TLUL-AXI bridge.
*/

module ddr4_tlul_xilinx (
    input logic clk_i,
    input logic rst_ni,

    input logic ddr4_clk_p,
    input logic ddr4_clk_n,

    input logic ddr4_reset,

    // Phy interface
    output               c0_ddr4_reset_n,
    output [0:0]         c0_ddr4_ck_t,
    output [0:0]         c0_ddr4_ck_c,
    output               c0_ddr4_act_n,
    output [16:0]        c0_ddr4_adr,
    output [1:0]         c0_ddr4_ba,
    output [0:0]         c0_ddr4_bg,
    output [0:0]         c0_ddr4_cke,
    output [0:0]         c0_ddr4_odt,
    output [0:0]         c0_ddr4_cs_n,
    inout  [1:0]         c0_ddr4_dm_dbi_n,
    inout  [15:0]        c0_ddr4_dq,
    inout  [1:0]         c0_ddr4_dqs_c,
    inout  [1:0]         c0_ddr4_dqs_t,

    //  tlul host
    input   tlul_pkg::tl_h2d_t     tl_i,
    output  tlul_pkg::tl_d2h_t     tl_o,

    output logic         init_calib_done_o,
    output logic         dram_clk_o
);

tlul2axi_pkg::slv_req_t axi_req;
tlul2axi_pkg::slv_rsp_t axi_rsp;

tlul2axi #(
    .AXI_ID_WIDTH   ( tlul2axi_pkg::AXI_ID_WIDTH),
    .AXI_ADDR_WIDTH ( tlul2axi_pkg::AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH ( tlul2axi_pkg::AXI_SLV_PORT_DATA_WIDTH),
    .AXI_USER_WIDTH ( tlul2axi_pkg::AXI_USER_WIDTH)
) u_tlul2axi (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .tl_i(tl_i),
    .tl_o(tl_o),

    .axi_rsp_i(axi_rsp),
    .axi_req_o(axi_req)
);

ddr4_wrapper_xilinx #(
    .axi_soc_aw_chan_t (tlul2axi_pkg::aw_chan_t),
    .axi_soc_w_chan_t  (tlul2axi_pkg::slv_w_chan_t),
    .axi_soc_b_chan_t  (tlul2axi_pkg::b_chan_t),
    .axi_soc_ar_chan_t (tlul2axi_pkg::ar_chan_t),
    .axi_soc_r_chan_t  (tlul2axi_pkg::slv_r_chan_t),
    .axi_soc_req_t     (tlul2axi_pkg::slv_req_t),
    .axi_soc_resp_t    (tlul2axi_pkg::slv_rsp_t)
)i_ddr4_wrapper_xilinx(
    .soc_clk_i(clk_i),
    .soc_resetn_i(rst_ni),

    .dram_clk_pi(ddr4_clk_p),
    .dram_clk_ni(ddr4_clk_n),
    .sys_rst_i(ddr4_reset),

    .init_calib_done_o(init_calib_done_o),
    .dram_clk_o(dram_clk_o),

    // AXI interface
    .soc_req_i(axi_req),
    .soc_rsp_o(axi_rsp),

    // Phy interface
    .*
);

endmodule
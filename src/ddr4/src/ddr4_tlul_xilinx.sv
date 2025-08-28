// Copyright (c) 2025 Maximilian Kirschner
// Licensed under the Solderpad Hardware License v2.1. See LICENSE file in the project root for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

/*
    Connecting the DDR4 wrapper to a TLUL interface through a TLUL-AXI bridge.
*/
`include "typedef.svh"

module ddr4_tlul_xilinx (
    input logic clk_i,
    input logic rst_ni,

    input logic ddr4_clk_p,
    input logic ddr4_clk_n,

    input logic ddr4_reset,

    // Phy interface
`ifdef TARGET_ZCU102
    `DDR4_INTF_ZCU102
`endif
  
`ifdef TARGET_VCU128
    `DDR4_INTF_VCU128
`endif

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
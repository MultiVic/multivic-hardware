// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Vicuna RISC-V core
 *
 * 32 bit RISC-V core supporting the RV32I + optionally EMC instruction sets.
 * Vicuna adds support for RVV to the Ibex core.
 * Instruction and data bus are 32 bit wide TileLink-UL (TL-UL).
 */
module rv_core_vicuna
  import vproc_pkg::*;
#(
  parameter int unsigned     MEM_W         = 32,  // memory bus width in bits
  parameter int unsigned     VMEM_W        = 32,  // vector memory interface width in bits
  parameter vreg_type        VREG_TYPE     = VREG_GENERIC,
  parameter mul_type         MUL_TYPE      = MUL_GENERIC,
  parameter bit              DbgTriggerEn     = 1'b0,
  parameter int unsigned     DbgHwBreakNum    = 1,
  parameter int unsigned     DmHaltAddr       = 32'h1A110800,
  parameter int unsigned     DmExceptionAddr  = 32'h1A110808,
  parameter ibex_xif_pkg::regfile_e RegFile        = ibex_xif_pkg::RegFileFPGA
)(
  input logic clk_i,
  input logic rst_ni,

  // Instruction memory interface
  output tlul_pkg::tl_h2d_t     corei_tl_h_o,
  input  tlul_pkg::tl_d2h_t     corei_tl_h_i,

  // Data memory interface
  output tlul_pkg::tl_h2d_t     cored_tl_h_o,
  input  tlul_pkg::tl_d2h_t     cored_tl_h_i,

  // Interrupts
  input  logic        irq_software_i,
  input  logic        irq_timer_i,
  input  logic        irq_external_i,
  input  logic [14:0] irq_fast_i,
  input  logic        irq_nm_i,

  // Debug interface
  input  logic        debug_req_i
);
  import tlul_pkg::*;

  localparam int unsigned NumRegions = 2;

  // Instruction interface (internal)
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic [6:0]  instr_rdata_intg;
  logic        instr_err;

  // Data interface (internal)
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic [3:0]  data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [6:0]  data_wdata_intg;
  logic [31:0] data_rdata;
  logic [6:0]  data_rdata_intg;
  logic        data_err;

  // Pipeline interfaces
  tl_h2d_t tl_i_ibex2fifo;
  tl_d2h_t tl_i_fifo2ibex;
  tl_h2d_t tl_d_ibex2fifo;
  tl_d2h_t tl_d_fifo2ibex;

  vproc_top #(
    .RegFile         ( RegFile ),
    .MEM_W           ( MEM_W),
    .VMEM_W          ( VMEM_W),
    .VREG_TYPE       ( VREG_TYPE ),
    .MUL_TYPE        ( MUL_TYPE ),
    .DbgTriggerEn    ( DbgTriggerEn ),
    .DbgHwBreakNum   ( DbgHwBreakNum ),
    .DmHaltAddr      ( DmHaltAddr ),
    .DmExceptionAddr ( DmExceptionAddr )
  ) vproc (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),

    .instr_req_o        (instr_req),
    .instr_gnt_i        (instr_gnt),
    .instr_rvalid_i     (instr_rvalid),
    .instr_addr_o       (instr_addr),
    .instr_rdata_i      (instr_rdata),
    .instr_rdata_intg_i (instr_rdata_intg),
    .instr_err_i        (instr_err),

    .data_req_o         (data_req),
    .data_gnt_i         (data_gnt),
    .data_rvalid_i      (data_rvalid),
    .data_we_o          (data_we),
    .data_be_o          (data_be),
    .data_addr_o        (data_addr),
    .data_wdata_o       (data_wdata),
    .data_wdata_intg_o  (data_wdata_intg),
    .data_rdata_i       (data_rdata),
    .data_rdata_intg_i  (data_rdata_intg),
    .data_err_i         (data_err),

    .irq_software_i     (irq_software_i),
    .irq_timer_i        (irq_timer_i),
    .irq_external_i     (irq_external_i),
    .irq_fast_i         (irq_fast_i),
    .irq_nm_i           (irq_nm_i),

    .debug_req_i        (debug_req_i)
  );

  /////////////////////////////////////
  // Convert ibex instruction bus to TL-UL
  // Address translation + TL-UL adapter + FIFO
  /////////////////////////////////////
  // TODO removed address translation no config registers necessary for vproc
  // logic [31:0] instr_addr_trans;
  // rv_core_addr_trans #(
  //   .AddrWidth(32),
  //   .NumRegions(NumRegions)
  // ) u_ibus_trans (
  //   .clk_i,
  //   .rst_ni(rst_ni),
  //   .region_cfg_i(ibus_region_cfg),
  //   .addr_i(instr_addr),
  //   .addr_o(instr_addr_trans)
  // );

  logic [6:0]  instr_wdata_intg;
  logic [top_pkg::TL_DW-1:0] unused_data;
  // tl_adapter_host_i_ibex only reads instruction. a_data is always 0
  assign {instr_wdata_intg, unused_data} = prim_secded_pkg::prim_secded_inv_39_32_enc('0);
  tlul_adapter_host #(
    .MAX_REQS(2),
    // if secure ibex is not set, data integrity is not generated
    // from ibex, therefore generate it in the gasket instead.
    .EnableDataIntgGen(1'b1)
  ) tl_adapter_host_i_ibex (
    .clk_i,
    .rst_ni,
    .req_i        (instr_req),
    .instr_type_i (prim_mubi_pkg::MuBi4True),
    .gnt_o        (instr_gnt),
    .addr_i       (instr_addr),
    .we_i         (1'b0),
    .wdata_i      (32'b0),
    .wdata_intg_i (instr_wdata_intg),
    .be_i         (4'hF),
    .valid_o      (instr_rvalid),
    .rdata_o      (instr_rdata),
    .rdata_intg_o (instr_rdata_intg),
    .err_o        (instr_err),
    .intg_err_o   (), // TODO error handling
    .tl_o         (tl_i_ibex2fifo),
    .tl_i         (tl_i_fifo2ibex)
  );

  tlul_fifo_sync #(
    .ReqPass(0),
    .RspPass(0),
    .ReqDepth(2),
    .RspDepth(2)
  ) fifo_i (
    .clk_i,
    .rst_ni,
    .tl_h_i      (tl_i_ibex2fifo),
    .tl_h_o      (tl_i_fifo2ibex),
    .tl_d_o      (corei_tl_h_o),
    .tl_d_i      (corei_tl_h_i),
    .spare_req_i (1'b0),
    .spare_req_o (),
    .spare_rsp_i (1'b0),
    .spare_rsp_o ());

  /////////////////////////////////////
  // Convert ibex data bus to TL-UL
  // Address translation + TL-UL adapter + FIFO
  /////////////////////////////////////
  // TODO removed address translation no config registers necessary for vproc
  // logic [31:0] data_addr_trans;
  // rv_core_addr_trans #(
  //   .AddrWidth(32),
  //   .NumRegions(NumRegions)
  // ) u_dbus_trans (
  //   .clk_i,
  //   .rst_ni(rst_ni),
  //   .region_cfg_i(dbus_region_cfg),
  //   .addr_i(data_addr),
  //   .addr_o(data_addr_trans)
  // );

  // SEC_CM: BUS.INTEGRITY
  tlul_adapter_host #(
    .MAX_REQS(2),
    .EnableDataIntgGen(1'b1)
  ) tl_adapter_host_d_ibex (
    .clk_i,
    .rst_ni,
    .req_i        (data_req),
    .instr_type_i (prim_mubi_pkg::MuBi4False),
    .gnt_o        (data_gnt),
    .addr_i       (data_addr),
    .we_i         (data_we),
    .wdata_i      (data_wdata),
    .wdata_intg_i (data_wdata_intg),
    .be_i         (data_be),
    .valid_o      (data_rvalid),
    .rdata_o      (data_rdata),
    .rdata_intg_o (data_rdata_intg),
    .err_o        (data_err),
    .intg_err_o   (), // TODO error handling
    .tl_o         (tl_d_ibex2fifo),
    .tl_i         (tl_d_fifo2ibex)
  );

  tlul_fifo_sync #(
    .ReqPass(0),
    .RspPass(0),
    .ReqDepth(2),
    .RspDepth(2)
  ) fifo_d (
    .clk_i,
    .rst_ni,
    .tl_h_i      (tl_d_ibex2fifo),
    .tl_h_o      (tl_d_fifo2ibex),
    .tl_d_o      (cored_tl_h_o),
    .tl_d_i      (cored_tl_h_i),
    .spare_req_i (1'b0),
    .spare_req_o (),
    .spare_rsp_i (1'b0),
    .spare_rsp_o ());
endmodule

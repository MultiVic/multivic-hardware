// Copyright (c) 2025 Maximilian Kirschner
// Licensed under the Solderpad Hardware License v2.1. See LICENSE file in the project root for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`define DDR4_INTF_ZCU102 \
  output          c0_ddr4_reset_n, \
  output [0:0]    c0_ddr4_ck_t, \
  output [0:0]    c0_ddr4_ck_c, \
  output          c0_ddr4_act_n, \
  output [16:0]   c0_ddr4_adr, \
  output [1:0]    c0_ddr4_ba, \
  output [0:0]    c0_ddr4_bg, \
  output [0:0]    c0_ddr4_cke, \
  output [0:0]    c0_ddr4_odt, \
  output [1:0]    c0_ddr4_cs_n, \
  inout  [18:0]    c0_ddr4_dm_dbi_n, \
  inout  [15:0]   c0_ddr4_dq, \
  inout  [1:0]    c0_ddr4_dqs_c, \
  inout  [1:0]    c0_ddr4_dqs_t,



`define DDR4_INTF_VCU128 \
  output          c0_ddr4_reset_n, \
  output [0:0]    c0_ddr4_ck_t, \
  output [0:0]    c0_ddr4_ck_c, \
  output          c0_ddr4_act_n, \
  output [16:0]   c0_ddr4_adr, \
  output [1:0]    c0_ddr4_ba, \
  output [0:0]    c0_ddr4_bg, \
  output [0:0]    c0_ddr4_cke, \
  output [0:0]    c0_ddr4_odt, \
  output [1:0]    c0_ddr4_cs_n, \
  inout  [8:0]    c0_ddr4_dm_dbi_n, \
  inout  [71:0]   c0_ddr4_dq, \
  inout  [8:0]    c0_ddr4_dqs_c, \
  inout  [8:0]    c0_ddr4_dqs_t,

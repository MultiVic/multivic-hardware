// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level that connects the demo system to the virtual devices.
module top_verilator (input logic clk_i, rst_ni);

  localparam ClockFrequency = 125_000_000;
  localparam BaudRate       = ClockFrequency/8;

  logic uart_sys_rx, uart_sys_tx;

  tlul_pkg::tl_h2d_t main_memory_req;
  tlul_pkg::tl_d2h_t main_memory_rsp;

  // Instantiating the Vicuna Demo System.
  system_multicore #(
    .ClockFrequency ( ClockFrequency      ),
    .BaudRate       ( BaudRate            ),
    .RegFile        ( ibex_pkg::RegFileFF ),
    .ManagementDataFile  ("/home/kirschner/work/vicuna-multicore-benchmarks/build/ram.vmem"),
    .ManagementInstrFile  ("/home/kirschner/work/vicuna-multicore-benchmarks/build/rom.vmem"),
    //.ManagementInstrFile ("/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/rom.vmem" ),
    //.ManagementDataFile ("/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/ram.vmem" ),
    .VectorInstrFile ("/home/kirschner/work/vicuna-multicore-benchmarks/vector_loader/build/rom.vmem" ),
    .VectorDataFile ("/home/kirschner/work/vicuna-multicore-benchmarks/vector_loader/build/ram.vmem" )
  ) u_verilator_multicore (
    // sys signals
    .clk_sys_i (clk_i),
    .rst_sys_ni(rst_ni),

    // main memory
    .dma_main_memory_req_o(main_memory_req),
    .dma_main_memory_rsp_i(main_memory_rsp),

    // uart
    .uart_rx_i (uart_sys_rx),
    .uart_tx_o(uart_sys_tx)

  );

  sram #(
      .MemSize(1024 * 1024 * 4) // 4 MiB
    ) main_memory_sram (
      .clk_i(clk_i),
      .rst_ni(rst_ni),

      .en_ifetch_i(prim_mubi_pkg::MuBi4False),

      .tl_a_req_i(main_memory_req),
      .tl_a_rsp_o(main_memory_rsp),
      .tl_b_req_i(),
      .tl_b_rsp_o()
  );

  // uart
  uartdpi #(
    .BAUD(BaudRate),
    .FREQ(ClockFrequency)
  ) u_uartdpi (
    .clk_i,
    .rst_ni,
    .active (1'b1       ),
    .tx_o   (uart_sys_rx),
    .rx_i   (uart_sys_tx)
  );

endmodule

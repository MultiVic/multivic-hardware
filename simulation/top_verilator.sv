// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level that connects the demo system to the virtual devices.
module top_verilator (input logic clk_i, rst_ni);

  localparam ClockFrequency = 125_000_000;
  localparam BaudRate       = ClockFrequency/8;

  logic uart_sys_rx, uart_sys_tx;

  // Instantiating the Vicuna Demo System.
  system_multicore #(
    .ClockFrequency ( ClockFrequency      ),
    .BaudRate       ( BaudRate            ),
    .RegFile        ( ibex_pkg::RegFileFF ),
    .ManagementCoreScratchpadData  ( "/home/krusekamp/vicuna-software/build/sram/ManagementCoreData.vmem"),
    .ManagementCoreScratchpadInstr ( "/home/krusekamp/vicuna-software/build/sram/ManagementCoreInstr.vmem" )
  ) u_verilator_multicore (
    // sys signals
    .clk_sys_i (clk_i),
    .rst_sys_ni(rst_ni),

    // uart
    .uart_rx_i (uart_sys_rx),
    .uart_tx_o(uart_sys_tx)

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

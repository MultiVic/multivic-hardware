// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level that connects the demo system to the virtual devices.
module top_verilator_vicuna (input logic clk_i, rst_ni);

  localparam ClockFrequency = 125_000_000;
  localparam BaudRate       = ClockFrequency/8;

  logic uart_sys_rx, uart_sys_tx;
  logic [15:0] gp_o;
  logic [7:0]  gp_i;

  logic jtag_trst;
  logic jtag_tck;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

  // Instantiating the Vicuna Demo System.
  vicuna_demo_system #(
    .GpiWidth       ( 8                   ),
    .GpoWidth       ( 16                  ),
    .PwmWidth       ( 12                  ),
    .ClockFrequency ( ClockFrequency      ),
    .BaudRate       ( BaudRate            ),
    .RegFile        ( ibex_pkg::RegFileFF ),
    .SRAMInitFile   ( "/home/kirschner/vicuna-software/build/ram.vmem"),
    .ROMInitFile    ( "/home/kirschner/vicuna-software/build/rom.vmem")
  ) u_vicuna_demo_system (
    //Input
    .clk_sys_i (clk_i),
    .rst_sys_ni(rst_ni),
    .uart_rx_i (uart_sys_rx),

    //Output
    .uart_tx_o(uart_sys_tx),

    // tie off JTAG
    .trst_ni(jtag_trst),
    .tms_i  (jtag_tms),
    .tck_i  (jtag_tck),
    .td_i   (jtag_tdi),
    .td_o   (jtag_tdo),

    // Remaining IO
    .gp_i      (gp_i),
    .gp_o      (gp_o),
    .pwm_o     ( ),
    .spi_rx_i  (0),
    .spi_tx_o  ( ),
    .spi_sck_o ( )
  );

  // Virtual UART
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

  gpiodpi #(
      .NAME("gpio0"),
      .N_GPIO(16)
  ) u_gpiodpi (
      .gpio_p2d(gp_i),
      .gpio_d2p(gp_o),
      .active(1'b1),
      .gpio_en_d2p(1'b1),
      .gpio_pull_en(1'b1),
      .gpio_pull_sel()
  );

jtagdpi #(
) u_jtagdpi (
    .clk_i,
    .rst_ni,

    .jtag_tck,
    .jtag_tms,
    .jtag_tdi,
    .jtag_tdo,
    .jtag_trst_n(jtag_trst),
    .jtag_srst_n()
);
endmodule

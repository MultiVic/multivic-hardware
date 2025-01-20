module top_zcu102 #(
    parameter ManagementCoreScratchpadInstr = "",
    parameter ManagementCoreScratchpadData = ""
)(
    input           clk_125_p,
    input           clk_125_n,

    input           cpu_reset,

    input           uart_rx,
    output          uart_tx,

    input           c0_sys_clk_n,
    input           c0_sys_clk_p,

    output          c0_ddr4_act_n,
    output [16:0]   c0_ddr4_adr,
    output [1:0]    c0_ddr4_ba,
    output [0:0]    c0_ddr4_bg,
    output [0:0]    c0_ddr4_cke,
    output [0:0]    c0_ddr4_odt,
    output [0:0]    c0_ddr4_cs_n,
    output [0:0]    c0_ddr4_ck_t,
    output [0:0]    c0_ddr4_ck_c,
    output          c0_ddr4_reset_n,
    inout  [1:0]    c0_ddr4_dm_dbi_n,
    inout  [15:0]   c0_ddr4_dq,
    inout  [1:0]    c0_ddr4_dqs_c,
    inout  [1:0]    c0_ddr4_dqs_t
);

// Generating the system clock and reset for the FPGA.
clkgen_xilusp clkgen(
    .IO_CLK_P(CLK_125_P),
    .IO_CLK_N(CLK_125_N),
    .IO_RST_N(!CPU_RESET),
    .clk_sys,
    .rst_sys_n
);

// Generate the clock and reset for the DDR4 compoinent
clkgen_xilusp clkgen_ddr4(
    .IO_CLK_P(c0_sys_clk_p),
    .IO_CLK_N(c0_sys_clk_n),
    .IO_RST_N(CPU_RESET),
    .clk_sys(clk_ddr4),
    .rst_sys_n(rst_ddr4)
);

system_multicore #(
    .ManagementCoreScratchpadInstr(ManagementCoreScratchpadInstr),
    .ManagementCoreScratchpadData(ManagementCoreScratchpadData)
) multicore (
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),

    .ddr4_clk_i(clk_ddr4),
    .ddr4_reset_i(rst_ddr4),

    .uart_rx_i(uart_rx),
    .uart_tx_o(uart_tx),

    // DDR4 Phy interface
    .*
);


endmodule
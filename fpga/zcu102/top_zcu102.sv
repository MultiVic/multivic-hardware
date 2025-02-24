module top_zcu102 #(
    parameter ManagementCoreScratchpadInstr = "/home/kirschner/work/vicuna-software/rom.vmem",
    parameter ManagementCoreScratchpadData = "/home/kirschner/work/vicuna-software/ram.vmem"
)(
    input           clk_125_p,
    input           clk_125_n,

    input           cpu_reset,

    input           uart_rx,
    output          uart_tx,

    input           c0_sys_clk_n,
    input           c0_sys_clk_p,
    
    output [7:0]    gpio_led,

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

logic clk_sys, rst_sys_n;
logic clk_ddr4, rst_ddr4;

tlul_pkg::tl_h2d_t dma_main_memory_req;
tlul_pkg::tl_d2h_t dma_main_memory_rsp;

assign rst_sys_n = !cpu_reset;
assign rst_ddr4  = cpu_reset;

// --- main memory ---
ddr4_tlul_xilinx main_memory(
    .clk_i(clk_sys),
    .rst_ni(rst_sys_n),
    
    .ddr4_clk_p(c0_sys_clk_p),
    .ddr4_clk_n(c0_sys_clk_n),
    .ddr4_reset(rst_ddr4),

    .tl_i(dma_main_memory_req),
    .tl_o(dma_main_memory_rsp),

    .init_calib_done_o(),
    .dram_clk_o(clk_sys),

    // Phy
    .*
);

// Generate the clock and reset for the DDR4 compoinent
/*
clkgen_xilusp #(
    .BYPASS_PLL(1)
) clkgen_ddr4(
    .IO_CLK_P(c0_sys_clk_p),
    .IO_CLK_N(c0_sys_clk_n),
    .IO_RST_N(cpu_reset),
    .clk_sys(clk_ddr4),
    .rst_sys_n(rst_ddr4)
);
*/

system_multicore #(
    .ManagementCoreScratchpadInstr(ManagementCoreScratchpadInstr),
    .ManagementCoreScratchpadData(ManagementCoreScratchpadData)
) multicore (
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),

    .ddr4_clk_i(clk_ddr4),
    .ddr4_rst_i(rst_ddr4),

    .uart_rx_i(uart_rx),
    .uart_tx_o(uart_tx),

    .dma_main_memory_req_o(dma_main_memory_req),
    .dma_main_memory_rsp_i(dma_main_memory_rsp)
);

// Blink LEDs with different clock frequencies to test clock signals
logic [31:0] counter_sys;
logic [31:0] counter_ddr4;

always @ (posedge clk_sys) begin
    counter_sys <= counter_sys + 1;
end

always @ (posedge clk_ddr4) begin
    counter_ddr4 <= counter_ddr4 + 1;
end

assign gpio_led[0] = counter_sys[25];
assign gpio_led[1] = counter_ddr4[25];

endmodule
module top_zcu102 #(
//    parameter ManagementCoreScratchpadInstr = "/home/kirschner/work/vicuna-software/rom.vmem",
//    parameter ManagementCoreScratchpadData = "/home/kirschner/work/vicuna-software/ram.vmem"
    parameter ManagementDataFile  ="/home/krusekamp/vicuna-multicore-benchmarks/build/ram.vmem",
    parameter ManagementInstrFile  ="/home/krusekamp/vicuna-multicore-benchmarks/build/rom.vmem",
    parameter VectorInstrFile ="/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/rom.vmem" ,
    parameter VectorDataFile ="/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/ram.vmem"

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

system_multicore #(
    //    .ManagementCoreScratchpadInstr(ManagementCoreScratchpadInstr),
//    .ManagementCoreScratchpadData(ManagementCoreScratchpadData)
    .ManagementDataFile  ("/home/krusekamp/vicuna-multicore-benchmarks/build/ram.vmem"),
    .ManagementInstrFile  ("/home/krusekamp/vicuna-multicore-benchmarks/build/rom.vmem"),
    .VectorInstrFile ("/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/rom.vmem" ),
    .VectorDataFile ("/home/krusekamp/vicuna-multicore-benchmarks/vector_loader/build/ram.vmem" )
) multicore (
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),

    .uart_rx_i(uart_rx),
    .uart_tx_o(uart_tx),

    .dma_main_memory_req_o(dma_main_memory_req),
    .dma_main_memory_rsp_i(dma_main_memory_rsp)
);

endmodule

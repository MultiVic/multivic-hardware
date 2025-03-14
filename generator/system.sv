
module system_multicore #(
    parameter int unsigned ClockFrequency   = 125_000_000,
    parameter int unsigned BaudRate         = 115_200,
    parameter ibex_pkg::regfile_e RegFile   = ibex_pkg::RegFileFPGA,
    parameter ibex_xif_pkg::regfile_e RegFileVicuna = ibex_xif_pkg::RegFileFPGA,
    parameter ManagementDataFile = "",
    parameter ManagementInstrFile = "",
    parameter VectorInstrFile = "",
    parameter VectorDataFile = ""
) (
    input logic clk_sys_i,
    input logic rst_sys_ni,

    input  logic uart_rx_i,
    output logic uart_tx_o
); 

// --- mhp performance counter for verilator ---
`ifdef VERILATOR

    export "DPI-C" function mhpmcounter_num;

    function automatic int unsigned mhpmcounter_num();
        return management_core_ibex.u_core.u_ibex_core.cs_registers_i.MHPMCounterNum;
    endfunction

    export "DPI-C" function mhpmcounter_get;

    function automatic longint unsigned mhpmcounter_get(int index);
        return management_core_ibex.u_core.u_ibex_core.cs_registers_i.mhpmcounter[index];
    endfunction
`endif

// --- Vicuna Multype definition
`ifdef VERILATOR
    localparam vproc_pkg::mul_type MulType = vproc_pkg::MUL_GENERIC;
    localparam vproc_pkg::vreg_type VRegType = vproc_pkg::VREG_GENERIC;
`else
    localparam vproc_pkg::mul_type MulType = vproc_pkg::MUL_XLNX_DSP48E1;
    localparam vproc_pkg::vreg_type VRegType = vproc_pkg::VREG_XLNX_RAM32M;
`endif

// --- tlul declaration ---
tlul_pkg::tl_h2d_t management_core_instr_req;
tlul_pkg::tl_d2h_t management_core_instr_rsp;
tlul_pkg::tl_h2d_t management_core_data_req;
tlul_pkg::tl_d2h_t management_core_data_rsp;

tlul_pkg::tl_h2d_t dma_host_port_req;
tlul_pkg::tl_d2h_t dma_host_port_rsp;
tlul_pkg::tl_h2d_t dma_register_port_req;
tlul_pkg::tl_d2h_t dma_register_port_rsp;

tlul_pkg::tl_h2d_t management_scratchpad_instr_req;
tlul_pkg::tl_d2h_t management_scratchpad_instr_rsp;
// Ports of the management data scratchpad connected to main crossbar
tlul_pkg::tl_h2d_t management_scratchpad_data_req;
tlul_pkg::tl_d2h_t management_scratchpad_data_rsp;
// Ports of the management data scratchpad connected to the management peripherals crossbar
tlul_pkg::tl_h2d_t management_scratchpad_data_req_b;
tlul_pkg::tl_d2h_t management_scratchpad_data_rsp_b;
[[[cog import SystemGenerator as g; g.generateDeclaration() ]]]
[[[end]]]
tlul_pkg::tl_h2d_t uart_req;
tlul_pkg::tl_d2h_t uart_rsp;

// --- crossbar ---
xbar_main #() u_xbar_main (
    .clk_main_i(clk_sys_i),
    .rst_main_ni(rst_sys_ni),

    .tl_dma_i(dma_host_port_req),
    .tl_dma_o(dma_host_port_rsp),

    .tl_management_scratchpad_instr_o (management_scratchpad_instr_req),
    .tl_management_scratchpad_instr_i (management_scratchpad_instr_rsp),
    .tl_management_scratchpad_data_o (management_scratchpad_data_req),
    .tl_management_scratchpad_data_i (management_scratchpad_data_rsp),

[[[cog import SystemGenerator as g; g.generateXbar() ]]]
[[[end]]]
    .scanmode_i()
);

xbar_management_peripherals #() u_xbar_management_peripherals(
    .clk_main_i(clk_sys_i),
    .rst_main_ni(rst_sys_ni),

    .tl_management_core_data_i(management_core_data_req),
    .tl_management_core_data_o(management_core_data_rsp),

    .tl_management_scratchpad_data_o(management_scratchpad_data_req_b),
    .tl_management_scratchpad_data_i(management_scratchpad_data_rsp_b),

    .tl_uart_o(uart_req),
    .tl_uart_i(uart_rsp),

    .tl_dma_register_port_o(dma_register_port_req),
    .tl_dma_register_port_i(dma_register_port_rsp),

    .scanmode_i()
);

// --- management core ---
rv_core_ibex #(
    .PMPEnable('b0),
    .MHPMCounterNum( 10),
    .RegFile(RegFile),
    .ICache('b0),
    .SecureIbex('b0)
) management_core_ibex (
    .alert_tx_o  (),
    .alert_rx_i  (),

    // Inter-module signals
    .rst_cpu_n_o(),
    .ram_cfg_i(),
    .hart_id_i(32'h0),
    .boot_addr_i(32'h0),
    .irq_software_i(),
    .irq_timer_i(),
    .irq_external_i(),
    .esc_tx_i(),
    .esc_rx_o(),
    .debug_req_i(),
    .crash_dump_o(),
    .lc_cpu_en_i(5),
    .pwrmgr_cpu_en_i(5),
    .pwrmgr_o(),
    .nmi_wdog_i(),
    .edn_o(),
    .edn_i(),
    .icache_otp_key_o(),
    .icache_otp_key_i(),
    .fpga_info_i(),
    .corei_tl_h_o(management_core_instr_req),
    .corei_tl_h_i(management_core_instr_rsp),
    .cored_tl_h_o(management_core_data_req),
    .cored_tl_h_i(management_core_data_rsp),
    .cfg_tl_d_i(),
    .cfg_tl_d_o(),
    .scanmode_i(),
    .scan_rst_ni('b1),

    // Clock and reset connections
    .clk_i (clk_sys_i),
    .rst_ni (rst_sys_ni),
    .rst_edn_ni('b1), // TODO: look wether those can be removed
    .rst_esc_ni('b1),
    .rst_otp_ni('b1)
);

dma #() u_dma(
    .clk_i(clk_sys_i),
    .rst_ni(rst_sys_ni),
    .scanmode_i(),

    // TODO connect dma interrupts in a meaningful way
    .intr_dma_done_o(),
    .intr_dma_chunk_done_o(),
    .intr_dma_error_o(),
    .lsio_trigger_i(1'b0),

    // TODO Remove alerts?
    .alert_rx_i(),
    .alert_tx_o(),

    // Device Port (Register Interface)
    .tl_d_i(dma_register_port_req),
    .tl_d_o(dma_register_port_rsp),

    // Host Port (Memory Interface, towards the crossbar)
    .host_tl_h_i(dma_host_port_rsp),
    .host_tl_h_o(dma_host_port_req),

    // CTN Port (Memory Interface, towards the Main Memory)
    .ctn_tl_d2h_i(),
    .ctn_tl_h2d_o(),

    // System Port, unused
    .sys_i(),
    .sys_o()
);

// --- scratchpad management ---
sram #(
    .MemSize    (64 * 1024), // 64 KiB
    .MemInitFile(ManagementInstrFile)
) management_scratchpad_instr (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .en_ifetch_i(prim_mubi_pkg::MuBi4True),

    .tl_a_req_i(management_scratchpad_instr_req),
    .tl_a_rsp_o(management_scratchpad_instr_rsp),
    .tl_b_req_i(management_core_instr_req),
    .tl_b_rsp_o(management_core_instr_rsp)
);

sram #(
    .MemSize     (64 * 1024), // 64 KiB
    .MemInitFile (ManagementDataFile)
) management_scratchpad_data (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),

    .tl_a_req_i(management_scratchpad_data_req),
    .tl_a_rsp_o(management_scratchpad_data_rsp),
    .tl_b_req_i(management_scratchpad_data_req_b),
    .tl_b_rsp_o(management_scratchpad_data_rsp_b)
);

// --- uart interface for management core ---
simple_uart #(
    .ClockFrequency (ClockFrequency),
    .BaudRate       (BaudRate)
) u_simple_uart (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .uart_rx_i(uart_rx_i),
    .uart_tx_o(uart_tx_o),

    .tl_i(uart_req),
    .tl_o(uart_rsp)
);

[[[cog import SystemGenerator as g; g.generateCores() ]]]
[[[end]]]
endmodule

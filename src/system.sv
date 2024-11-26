
module system_multicore #(
    parameter int unsigned ClockFrequency   = 125_000_000,
    parameter int unsigned BaudRate         = 115_200,
    parameter ibex_pkg::regfile_e RegFile   = ibex_pkg::RegFileFPGA,
    parameter ManagementCoreScratchpadData  = "",
    parameter ManagementCoreScratchpadInstr = ""
) (
    input logic clk_sys_i,
    input logic rst_sys_ni,

    input  logic uart_rx_i,
    output logic uart_tx_o
); 

// --- tlul declaration ---
tlul_pkg::tl_h2d_t management_core_instr_req;
tlul_pkg::tl_d2h_t management_core_instr_rsp;
tlul_pkg::tl_h2d_t management_core_data_req;
tlul_pkg::tl_d2h_t management_core_data_rsp;

tlul_pkg::tl_h2d_t management_scratchpad_instr_req;
tlul_pkg::tl_d2h_t management_scratchpad_instr_rsp;
tlul_pkg::tl_h2d_t management_scratchpad_data_req;
tlul_pkg::tl_d2h_t management_scratchpad_data_rsp;

tlul_pkg::tl_h2d_t vicuna0_scratchpad_instr_req;
tlul_pkg::tl_d2h_t vicuna0_scratchpad_instr_rsp;
tlul_pkg::tl_h2d_t vicuna0_scratchpad_data_req;
tlul_pkg::tl_d2h_t vicuna0_scratchpad_data_rsp;

tlul_pkg::tl_h2d_t vicuna1_scratchpad_instr_req;
tlul_pkg::tl_d2h_t vicuna1_scratchpad_instr_rsp;
tlul_pkg::tl_h2d_t vicuna1_scratchpad_data_req;
tlul_pkg::tl_d2h_t vicuna1_scratchpad_data_rsp;

tlul_pkg::tl_h2d_t uart_req;
tlul_pkg::tl_d2h_t uart_rsp;

xbar_main #() u_xbar_main (
    .clk_main_i(clk_sys_i),
    .rst_main_ni(rst_sys_ni),

    .tl_management_core_instr_i(management_core_instr_req),
    .tl_management_core_instr_o(management_core_instr_rsp),
    .tl_management_core_data_i(management_core_data_req),
    .tl_management_core_data_o(management_core_data_rsp),

    .tl_management_scratchpad_instr_o(management_scratchpad_instr_req),
    .tl_management_scratchpad_instr_i(management_scratchpad_instr_rsp),
    .tl_management_scratchpad_data_o(management_scratchpad_data_req),
    .tl_management_scratchpad_data_i(management_scratchpad_data_rsp),

    .tl_vicuna0_scratchpad_instr_o(vicuna0_scratchpad_instr_req),
    .tl_vicuna0_scratchpad_instr_i(vicuna0_scratchpad_instr_rsp),
    .tl_vicuna0_scratchpad_data_o(vicuna0_scratchpad_data_req),
    .tl_vicuna0_scratchpad_data_i(vicuna0_scratchpad_data_rsp),

    .tl_vicuna1_scratchpad_instr_o(vicuna1_scratchpad_instr_req),
    .tl_vicuna1_scratchpad_instr_i(vicuna1_scratchpad_instr_rsp),
    .tl_vicuna1_scratchpad_data_o(vicuna1_scratchpad_data_req),
    .tl_vicuna1_scratchpad_data_i(vicuna1_scratchpad_data_rsp),

    .tl_uart_o(uart_req),
    .tl_uart_i(uart_rsp),

    .scanmode_i()
);

  rv_core_ibex #(
    .AlertAsyncOn(),
    .RndCnstLfsrSeed(),
    .RndCnstLfsrPerm(),
    .RndCnstIbexKeyDefault(),
    .RndCnstIbexNonceDefault(),
    .PMPEnable(),
    .PMPGranularity(),
    .PMPNumRegions(),
    .MHPMCounterNum(),
    .MHPMCounterWidth(),
    .PMPRstCfg(),
    .PMPRstAddr(),
    .PMPRstMsecCfg(),
    .RV32E(),
    .RV32M(),
    .RV32B(),
    .RegFile(RegFile),
    .BranchTargetALU(),
    .WritebackStage(),
    .ICache(),
    .ICacheECC(),
    .ICacheScramble(),
    .BranchPredictor(),
    .DbgTriggerEn(),
    .DbgHwBreakNum(),
    .SecureIbex(),
    .DmHaltAddr(),
    .DmExceptionAddr(),
    .PipeLine()
  ) management_core_ibex (
      // [61]: fatal_sw_err
      // [62]: recov_sw_err
      // [63]: fatal_hw_err
      // [64]: recov_hw_err
      .alert_tx_o  (),
      .alert_rx_i  (),

      // Inter-module signals
      .rst_cpu_n_o(),
      .ram_cfg_i(),
      .hart_id_i(),
      .boot_addr_i(),
      .irq_software_i(),
      .irq_timer_i(),
      .irq_external_i(),
      .esc_tx_i(),
      .esc_rx_o(),
      .debug_req_i(),
      .crash_dump_o(),
      .lc_cpu_en_i(),
      .pwrmgr_cpu_en_i(),
      .pwrmgr_o(),
      .nmi_wdog_i(),
      .edn_o(),
      .edn_i(),
      .icache_otp_key_o(),
      .icache_otp_key_i(),
      .fpga_info_i(),
      .corei_tl_h_o(management_core_instr_req),
      .corei_tl_h_i(management_core_instr_rsp),
      .cored_tl_h_o(management_core_instr_req),
      .cored_tl_h_i(management_core_instr_rsp),
      .cfg_tl_d_i(),
      .cfg_tl_d_o(),
      .scanmode_i(),
      .scan_rst_ni(),

      // Clock and reset connections
      .clk_i (clk_sys_i),
      .clk_edn_i (),
      .clk_esc_i (),
      .clk_otp_i (),
      .rst_ni (rst_sys_ni),
      .rst_edn_ni ('b0),
      .rst_esc_ni ('b0),
      .rst_otp_ni ('b0)
  );

simple_uart #(
    .ClockFrequency (ClockFrequency),
    .BaudRate       (BaudRate)
) u_simple_uart (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .uart_rx_i(uart_rx_i),
    .uart_tx_o(uart_tx_o),
    .uart_irq_o(), // TODO connect to vicuna interrupt inputs

    .tl_i(uart_req),
    .tl_o(uart_rsp)
);
endmodule

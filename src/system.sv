module system #(
    parameter ManagementCoreScratchpadData = "",
    parameter ManagementCoreScratchpadInstr = ""
) (
    input logic clk_sys_i,
    input logic rst_sys_ni,

    input logic uart_rx_i,
    input logic uart_tx_o
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

tlul_pkg::tl_h2d_t uart_req;
tlul_pkg::tl_d2h_t uart_rsp;

xbar_main #() u_xbar_main (
    .clk_main_i(clk_sys_i),
    .rst_main_ni(srt_sys_ni),

    .tl_management_core_instr_req(management_core_instr_req),
    .tl_management_core_instr_rsp(management_core_instr_rsp),
    .tl_management_core_data_req(management_core_data_req),
    .tl_management_core_data_rsp(management_core_data_rsp),

    .tl_management_scratchpad_instr_req(management_scratchpad_instr_req),
    .tl_management_scratchpad_instr_rsp(management_scratchpad_instr_rsp),
    .tl_management_scratchpad_data_req(management_scratchpad_data_req),
    .tl_management_scratchpad_data_rsp(management_scratchpad_data_rsp),

    .tl_uart_req(uart_req),
    .tl_uart_rsp(uart_rsp),
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
    .RegFile(RvCoreIbexRegFile),
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
      .irq_software_i(rv_plic_msip),
      .irq_timer_i(rv_core_ibex_irq_timer),
      .irq_external_i(rv_plic_irq),
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
      .cored_tl_h_o(management_core_instr_rsp),
      .cored_tl_h_i(management_core_instr_rsp),
      .cfg_tl_d_i(),
      .cfg_tl_d_o(),
      .scanmode_i,
      .scan_rst_ni,

      // Clock and reset connections
      .clk_i (clk_sys_i),
      .clk_edn_i (),
      .clk_esc_i (),
      .clk_otp_i (),
      .rst_ni (rst_sys_ni),
      .rst_edn_ni (),
      .rst_esc_ni (),
      .rst_otp_ni ()
  );

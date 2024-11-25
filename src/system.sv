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

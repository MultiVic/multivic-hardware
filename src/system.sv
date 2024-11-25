module system #(
    parameter ManagementCoreScratchpadData = "",
    parameter ManagementCoreScratchpadInstr = ""
) (
    input logic clk_sys_i,
    input logic rst_sys_ni,

    input logic uart_rx_i,
    input logic uart_tx_o
); 

// management core data and instr
tlul_pkg::tl_h2d_t management_core_instr_req;
tlul_pkg::tl_d2h_t management_core_instr_rsp;
tlul_pkg::tl_h2d_t management_core_data_req;
tlul_pkg::tl_d2h_t management_core_data_rsp;


// management core sram
tlul_pkg::tl_h2d_t management_scratchpad_instr_req;
tlul_pkg::tl_d2h_t management_scratchpad_instr_rsp;
tlul_pkg::tl_h2d_t management_scratchpad_data_req;
tlul_pkg::tl_d2h_t management_scratchpad_data_rsp;

// management core uart
tlul_pkg::tl_h2d_t uart_req;
tlul_pkg::tl_d2h_t uart_rsp;

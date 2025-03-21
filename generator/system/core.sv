// --- CORE_NAME core
rv_core_vicuna #(
    .RegFile(RegFileVicuna),
    .MEM_W(32),
    .VMEM_W(32),
    .VREG_TYPE(VRegType),
    .MUL_TYPE(MulType)
) CORE_NAME_core (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // Instruction memory interface
    .corei_tl_h_o(CORE_NAME_core_instr_req),
    .corei_tl_h_i(CORE_NAME_core_instr_rsp),

    // Data memory interface
    .cored_tl_h_o(CORE_NAME_core_data_req),
    .cored_tl_h_i(CORE_NAME_core_data_rsp)
);

// --- scratchpad CORE_NAME ---
sram #(
    .MemSize     (64 * 1024), // 64 KiB
    .MemInitFile (VectorInstrFile)
) CORE_NAME_scratchpad_instr (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .en_ifetch_i(prim_mubi_pkg::MuBi4True),

    .tl_a_req_i(CORE_NAME_scratchpad_instr_req),
    .tl_a_rsp_o(CORE_NAME_scratchpad_instr_rsp),
    .tl_b_req_i(CORE_NAME_core_instr_req),
    .tl_b_rsp_o(CORE_NAME_core_instr_rsp)
);

sram #(
    .MemSize     (64 * 1024), // 64 KiB
    .MemInitFile (VectorDataFile)
) CORE_NAME_scratchpad_data (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),

    .tl_a_req_i(CORE_NAME_scratchpad_data_req),
    .tl_a_rsp_o(CORE_NAME_scratchpad_data_rsp),
    .tl_b_req_i(CORE_NAME_core_data_req),
    .tl_b_rsp_o(CORE_NAME_core_data_rsp)
);

##########
# Clocks #
##########

#########
# Reset #
#########
set_false_path -from [get_ports cpu_reset]

########
# UART #
########

# UART speed is at most 5 Mb/s
set_min_delay -from [get_ports uart_rx] 30.000
set_max_delay -from [get_ports uart_rx] 70.000
set_false_path -hold -from [get_ports uart_rx]

set_max_delay -to [get_ports uart_tx] 70.000
set_false_path -hold -to [get_ports uart_tx]

#############
# DDR4      #
#############
#set_output_delay -min 0.0 -clock [get_clocks c0_sys_clk_p] [get_ports c0_ddr4_reset_n]
#set_output_delay -max 5.0 -clock [get_clocks c0_sys_clk_p] [get_ports c0_ddr4_reset_n]
set_false_path -hold -through [get_pins main_memory/i_ddr4_wrapper_xilinx/c0_ddr4_reset_n]
set_max_delay -through [get_pins main_memory/i_ddr4_wrapper_xilinx/c0_ddr4_reset_n] 3.000

# Dram axi clock
# set MIG_TCK 3
# Aynch reset in
# set MIG_RST_I [get_pin multicore/main_memory/i_ddr4_wrapper_xilinx/u_ddr4_0/c0_ddr4_aresetn]
# set_false_path -hold -setup -through $MIG_RST_I
# Synch reset out
# set MIG_RST_O [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/u_ddr4_0/c0_ddr4_ui_clk_sync_rst]
# set_false_path -hold -through $MIG_RST_O
# set_max_delay -through $MIG_RST_O $MIG_TCK

########
# CDCs #
########
# Disable hold checks on CDCs
# set_property KEEP_HIERARCHY SOFT [get_cells -hier #     -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}]
# set_false_path -hold -through [get_pins -of_objects [get_cells -hier #     -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}] -filter {NAME=~*serial_i}]

# set_false_path -hold -through [get_pins -of_objects [get_cells -hier #     -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
# set_false_path -hold -through [get_pins -of_objects [get_cells -hier #     -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]

# set_max_delay -datapath #  -from [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] #   -to [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK

# set_max_delay -datapath #  -from [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] #   -to [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK


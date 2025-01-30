##########
# Clocks #
##########
# Main System Clock 125 MHz
create_clock -period 8.000 -name clk_125 -add [get_nets clk_125_p]

# Clock for the DDR4 subsystem 300 MHz
create_clock -period 3.333 -name c0_sys_clk -add [get_nets c0_sys_clk_p]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks clk_125] -group [get_clocks -include_generated_clocks c0_sys_clk]

########
# UART #
########

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0

set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -from [get_ports uart_rx]
set_false_path -hold -from [get_ports uart_rx]

set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -to [get_ports uart_tx]
set_false_path -hold -to [get_ports uart_tx]


#############
# Mig clock #
#############

# Dram axi clock
set MIG_TCK 3
# Aynch reset in
set MIG_RST_I [get_pin multicore/main_memory/i_ddr4_wrapper_xilinx/u_ddr4_0/c0_ddr4_aresetn]
set_false_path -hold -setup -through $MIG_RST_I
# Synch reset out
set MIG_RST_O [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/u_ddr4_0/c0_ddr4_ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

########
# CDCs #
########
# Disable hold checks on CDCs
set_property KEEP_HIERARCHY SOFT [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}] -filter {NAME=~*serial_i}]

set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]
    
set_max_delay -datapath \
 -from [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK

set_max_delay -datapath \
 -from [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins multicore/main_memory/i_ddr4_wrapper_xilinx/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK
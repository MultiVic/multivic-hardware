set ipName xlnx_mig_ddr4
create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $ipName

set_property -dict [list CONFIG.C0.DDR4_Clamshell {true} \
                    CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram} \
                    CONFIG.System_Clock {Differential} \
                    CONFIG.Reference_Clock {No_Buffer} \
                    CONFIG.C0.DDR4_InputClockPeriod {10000} \
                    CONFIG.C0.DDR4_CLKOUT0_DIVIDE {3} \
                    CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-075E} \
                    CONFIG.C0.DDR4_DataWidth {72} \
                    CONFIG.C0.DDR4_DataMask {NO_DM_NO_DBI} \
                    CONFIG.C0.DDR4_Ecc {true} \
                    CONFIG.C0.DDR4_AxiDataWidth {512} \
                    CONFIG.C0.DDR4_AxiAddressWidth {32} \
                    CONFIG.C0.DDR4_AxiIDWidth {8} \
                    CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
                    CONFIG.C0.BANK_GROUP_WIDTH {1} \
                    CONFIG.C0.CS_WIDTH {2} \
                    CONFIG.C0.DDR4_AxiSelection {true} \
                    ] [get_ips $ipName]
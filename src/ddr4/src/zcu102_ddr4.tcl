# Copyright (c) 2025 Maximilian Kirschner
# Licensed under the Solderpad Hardware License v2.1. See LICENSE file in the project root for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

set ipName xlnx_mig_ddr4
create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $ipName

set_property -dict [list CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram_062} \
                           CONFIG.C0.DDR4_TimePeriod {833} \
                           CONFIG.C0.DDR4_InputClockPeriod {3332} \
                           CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
                           CONFIG.C0.DDR4_MemoryPart {MT40A256M16LY-062E} \
                           CONFIG.C0.DDR4_DataWidth {16} \
                           CONFIG.C0.DDR4_CasWriteLatency {12} \
                           CONFIG.C0.DDR4_AxiDataWidth {128} \
                           CONFIG.C0.DDR4_AxiAddressWidth {29} \
                           CONFIG.C0.DDR4_AxiIDWidth {8} \
                           CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
                           CONFIG.System_Clock {Differential} \
                           CONFIG.Reference_Clock {No_Buffer} \
                           CONFIG.C0.BANK_GROUP_WIDTH {1} \
                           CONFIG.C0.DDR4_AxiSelection {true} \
                     ] [get_ips $ipName]
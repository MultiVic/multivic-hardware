# ----------- System Clock ----------- #

set_property IOSTANDARD LVDS_25 [get_ports clk_125_n]
set_property PACKAGE_PIN G21    [get_ports clk_125_p]
set_property PACKAGE_PIN F21    [get_ports clk_125_n]
set_property IOSTANDARD LVDS_25 [get_ports clk_125_p]

# --------------- Reset -------------- #

set_property PACKAGE_PIN AM13 [get_ports cpu_reset]
set_property IOSTANDARD LVCMOS33 [get_ports cpu_reset]

# --------------- UART --------------- #

set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { uart_tx }]
set_property -dict { PACKAGE_PIN E13    IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]

# --------------- GPIO --------------- #
set_property PACKAGE_PIN AG14     [get_ports gpio_led[0]]
set_property IOSTANDARD LVCMOS33  [get_ports gpio_led[0]]
set_property PACKAGE_PIN AF13     [get_ports gpio_led[1]]
set_property IOSTANDARD LVCMOS33  [get_ports gpio_led[1]]
set_property PACKAGE_PIN AE13     [get_ports gpio_led[2]]
set_property IOSTANDARD LVCMOS33  [get_ports gpio_led[2]]
set_property PACKAGE_PIN AJ14     [get_ports gpio_led[3]]
set_property IOSTANDARD LVCMOS33  [get_ports gpio_led[3]]
set_property PACKAGE_PIN AJ15     [get_ports gpio_led[4]]
set_property IOSTANDARD  LVCMOS33 [get_ports gpio_led[4]]
set_property PACKAGE_PIN AH13     [get_ports gpio_led[5]]
set_property IOSTANDARD  LVCMOS33 [get_ports gpio_led[5]]
set_property PACKAGE_PIN AH14     [get_ports gpio_led[6]]
set_property IOSTANDARD  LVCMOS33 [get_ports gpio_led[6]]
set_property PACKAGE_PIN AL12     [get_ports gpio_led[7]]
set_property IOSTANDARD  LVCMOS33 [get_ports gpio_led[7]]


# --------------- DDR4 --------------- #

set_property BOARD_PART_PIN {user_si570_sysclk_n} [get_ports c0_sys_clk_n]
set_property BOARD_PART_PIN {user_si570_sysclk_p} [get_ports c0_sys_clk_p]

module simple_uart #(
    parameter int unsigned ClockFrequency = 50_000_000,
    parameter int unsigned BaudRate       = 115_200,
    parameter int unsigned RxFifoDepth    = 128,
    parameter int unsigned TxFifoDepth    = 128
)(
    input clk_i,
    input rst_ni,

    // UART Interface
    input  uart_rx_i,
    output uart_tx_o,
    output uart_irq_o,

    // Bus Interface
    input  tlul_pkg::tl_h2d_t tl_i,
    output tlul_pkg::tl_d2h_t tl_o
);

localparam int unsigned SramWidth = 32;
localparam int unsigned SramAw = 2;

logic req;
logic [SramAw+1:0] addr;
logic re;
logic we;
logic [SramWidth/8-1:0] be;
logic [SramWidth-1:0] wdata;
logic [SramWidth-1:0] rdata;

tlul_adapter_reg #(
    .CmdIntgCheck     (1),
    .EnableRspIntgGen (1),
    .EnableDataIntgGen(1),
    .RegAw            (SramAw+2),
    .RegDw            (SramWidth),
    .AccessLatency    (1)
) i_tlul_adapter_reg (
    .clk_i,
    .rst_ni,
    .tl_i,
    .tl_o,
    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    //.intg_error_o(rom_integrity_error),
    .re_o        (re),
    .we_o        (we),
    .addr_o      (addr),
    .wdata_o     (wdata),
    .be_o        (be),
    .busy_i      (1'b0),
    .rdata_i     (rdata),
    .error_i     (1'b0)
    // As read enable and write enable are only set if there is no error,
    // there is no need to handle them extra.
);
assign req = re | we;
simple_uart_core #(
    .ClockFrequency (ClockFrequency),
    .BaudRate       (BaudRate),
    .RxFifoDepth    (RxFifoDepth),
    .TxFifoDepth    (TxFifoDepth),
    .DataWidth      (SramWidth),
    .RegAddr        (SramAw)
) u_simple_uart_core (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),

    .device_req_i   (req),
    .device_addr_i  (addr[SramAw+1:2]),
    .device_we_i    (we),
    .device_be_i    (be),
    .device_wdata_i (wdata),
    .device_rvalid_o(),
    .device_rdata_o (rdata),
    .uart_rx_i      (uart_rx_i),
    .uart_irq_o     (uart_irq_o),
    .uart_tx_o      (uart_tx_o)
);

endmodule

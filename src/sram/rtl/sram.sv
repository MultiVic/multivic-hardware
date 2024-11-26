module sram 
import prim_mubi_pkg::mubi4_t;
#(
    parameter int unsigned MemSize = 64 * 1024, // 64 KiB
    parameter MemInitFile = ""
)(
    input clk_i,
    input rst_ni,

    input   mubi4_t en_ifetch_i,
    // Bus Interface
    input  tlul_pkg::tl_h2d_t tl_a_req_i,
    output tlul_pkg::tl_d2h_t tl_a_rsp_o,

    input  tlul_pkg::tl_h2d_t tl_b_req_i,
    output tlul_pkg::tl_d2h_t tl_b_rsp_o
);

localparam int unsigned Width = 32;
localparam int unsigned Depth = MemSize / 4;
localparam int unsigned Aw = $clog2(Depth);

logic a_req;
logic a_we;
logic [Aw-1:0] a_addr;
logic [Width-1:0] a_wdata;
logic [Width-1:0] a_wmask;
logic [Width-1:0] a_rdata;
logic a_rvalid;

logic b_req;
logic b_we;
logic [Aw-1:0] b_addr;
logic [Width-1:0] b_wdata;
logic [Width-1:0] b_wmask;
logic [Width-1:0] b_rdata;
logic b_rvalid;

tlul_adapter_sram #(
    .SramAw             (Aw),
    .SramDw             (Width),
    .Outstanding        (2),
    .EnableRspIntgGen   (1),
    .EnableDataIntgGen  (1)
) u_tlul_adapter_sram_b (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),

    .tl_i               (tl_b_req_i),
    .tl_o               (tl_b_rsp_o),

    .en_ifetch_i        (en_ifetch_i),

    .req_o              (b_req),
    .gnt_i              (1'b1),
    .we_o               (b_we),
    .addr_o             (b_addr),
    .wdata_o            (b_wdata),
    .wmask_o            (b_wmask),
    .intg_error_o       (),
    .rdata_i            (b_rdata),
    .rvalid_i           (b_rvalid),
    .rerror_i           (2'b00),
    .rmw_in_progress_o  ()
);

tlul_adapter_sram #(
    .SramAw             (Aw),
    .SramDw             (Width),
    .Outstanding        (2),
    .EnableRspIntgGen   (1),
    .EnableDataIntgGen  (1)
) u_tlul_adapter_sram_data (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),

    .tl_i               (tl_a_req_i),
    .tl_o               (tl_a_rsp_o),

    .en_ifetch_i        (en_ifetch_i),

    .req_o              (a_req),
    .gnt_i              (1'b1),
    .we_o               (a_we),
    .addr_o             (a_addr),
    .wdata_o            (a_wdata),
    .wmask_o            (a_wmask),
    .intg_error_o       (),
    .rdata_i            (a_rdata),
    .rvalid_i           (a_rvalid),
    .rerror_i           (2'b00),
    .rmw_in_progress_o  ()
);

prim_ram_2p #(
    .Width        (32),
    .Depth        (Depth),
    .MemInitFile  (MemInitFile)
) u_ram_2p (
    .clk_a_i        (clk_i),
    .clk_b_i        (clk_i),

    .a_req_i      (a_req),
    .a_write_i    (a_we),
    .a_wmask_i    (a_wmask),
    .a_addr_i     (a_addr),
    .a_wdata_i    (a_wdata),
    .a_rdata_o    (a_rdata),

    .b_req_i      (b_req),
    .b_write_i    (b_we),
    .b_wmask_i    (b_wmask),
    .b_addr_i     (b_addr),
    .b_wdata_i    (b_wdata),
    .b_rdata_o    (b_rdata)
);

// Valid data from the SRAM appears 1 cycle after the sram_req.
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        b_rvalid <= 1'b0;
        a_rvalid <= 1'b0;
    end else begin
        b_rvalid <= b_req & ~b_we;
        a_rvalid <= a_req & ~a_we;
    end
end

endmodule

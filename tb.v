`timescale 1ns/1ps

module tb();

reg SYS_CLK = 0;
reg SDIN    = 0;

wire rx_MCLK, rx_LRCK, rx_SCLK;
wire tx_MCLK, tx_LRCK, tx_SCLK;
wire SDOUT;

top dut(
    .SYS_CLK(SYS_CLK),
    .SDIN(SDIN),
    .rx_MCLK(rx_MCLK),
    .tx_MCLK(tx_MCLK),
    .rx_SCLK(rx_SCLK),
    .tx_SCLK(tx_SCLK),
    .rx_LRCK(rx_LRCK),
    .tx_LRCK(tx_LRCK),
    .SDOUT(SDOUT)
);

always #4 SYS_CLK = ~SYS_CLK;

always begin
    repeat(10) @(posedge rx_MCLK);
    SDIN = $urandom();
end

endmodule
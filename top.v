module top(
    input SYS_CLK,
    input SDIN,
    output rx_MCLK, rx_LRCK, rx_SCLK,
    output tx_MCLK, tx_LRCK, tx_SCLK,
    output SDOUT
);

wire MCLK, LRCK, SCLK;

assign rx_MCLK = MCLK;
assign tx_MCLK = MCLK;

assign rx_LRCK = LRCK;
assign tx_LRCK = LRCK;

assign rx_SCLK = SCLK;
assign tx_SCLK = SCLK;


clk_wiz_0 i1(.SYS_CLK(SYS_CLK), .MCLK(MCLK));

I2S2_PLAYBACK ii1(.MCLK(MCLK), .SCLK(SCLK), .LRCK(LRCK), .SDIN(SDIN), .SDOUT(SDOUT));

endmodule
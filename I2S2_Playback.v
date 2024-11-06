module I2S2_PLAYBACK(
    input MCLK, // 22.591MHz
    output SCLK, // 8 Periods of MCLK
    output LRCK,  // 512 Periods of MCLK Right-Justified

    input SDIN,
    output reg SDOUT
);

localparam FIRST_PERIOD = 8'b0000011; // Start sampling after 1 period of SCLK
localparam SAMPLE_DONE  = 8'd200; // End of sample frame: (8 Periods of MCLK) * (25 Periods of SCLK) = 200
localparam SCLK_POSEDGE = 3'b011; // Positive Edge of SCLK is when COUNT[2:0] = 3'b011 (It is not 3'b100 as we have a delay)
localparam SCLK_NEGEDGE = 3'b111; // Negative Edge of SCLK is when COUNT[2:0] = 3'b111 (It is not 3'b000 as we have a delay)

////// Setting up SCLK and LRCK ///////
reg [8:0] COUNT = 9'd0;

always@(posedge MCLK)
    COUNT <= COUNT + 1;
    
assign LRCK = COUNT[8];
assign SCLK = COUNT[2];

////// Setting up RX //////
reg [23:0] RIGHT_RX = 0; // Data for Right Channel
reg [23:0] LEFT_RX = 0; // Data for Left Channel

wire RIGHT_RX_READY;
wire LEFT_RX_READY;

always@(posedge MCLK)begin
    if(COUNT[2:0] == SCLK_POSEDGE && COUNT[7:0] > FIRST_PERIOD && COUNT[7:0] <= SAMPLE_DONE)begin
        if(LRCK)begin
            RIGHT_RX <= {RIGHT_RX[22:0], SDIN};
            LEFT_RX  <= 0;
        end
        else begin
            LEFT_RX <= {LEFT_RX[22:0], SDIN};
            RIGHT_RX <= 0;
        end
    end
end

assign RIGHT_RX_READY = (COUNT[7:0] == SAMPLE_DONE && LRCK); // TRANSMIT RIGHT DATA FLAG
assign LEFT_RX_READY  = (COUNT[7:0] == SAMPLE_DONE && ~LRCK); // TRANSMIT LEFT DATA FLAG

/////// Storing Data for Playback ///////
reg [23:0] RIGHT_DATA = 0;
reg [23:0] LEFT_DATA = 0;

always@(posedge MCLK)begin
    if(RIGHT_RX_READY)
        RIGHT_DATA <= RIGHT_RX;
    else if(LEFT_RX_READY)
        LEFT_DATA <= LEFT_RX;
end

/////// Setting up TX For Playback////////
reg [4:0] DATA_COUNT = 0; // Count to read data from MSB to LSB

always@(posedge MCLK)begin
    if(DATA_COUNT == 24 || COUNT[7:0] > SAMPLE_DONE) // When sampling is done or data count reaches 24 bits, we reset the counter
        DATA_COUNT <= 0;
    else if(COUNT[2:0] == SCLK_NEGEDGE && COUNT[7:0] > FIRST_PERIOD && COUNT[7:0] <= SAMPLE_DONE)begin 
        DATA_COUNT <= DATA_COUNT + 1; // Count increases each negative edge to read next bit
        if(LRCK)
            SDOUT <= RIGHT_DATA[23-DATA_COUNT];
        else
            SDOUT <= LEFT_DATA[23-DATA_COUNT];
    end
end

endmodule

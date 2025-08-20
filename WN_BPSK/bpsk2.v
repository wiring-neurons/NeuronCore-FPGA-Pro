module bpsk2 (
    output carrier,        // 50kHz carrier
    output data,           // 10kHz data
    output modulated,      // BPSK signal
    output demodulated     // Demodulated data
);

// Internal 12 MHz clock
wire clk;
SB_HFOSC #(
    .CLKHF_DIV("0b11")    // Divide 48MHz by 4 = 12MHz
) hfosc_inst (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(clk)
);

// ========== PARAMETERS ==========
parameter CARRIER_DIV = 120;      // 12MHz / (120*2) = 50kHz
parameter BIT_PERIOD = 1200;      // 12MHz / 10kHz = 1200 cycles/bit
parameter DATA_PATTERN = 8'b10110010;

// ========== CARRIER GENERATION ==========
reg [6:0] c_cnt = 0;
reg car = 0;
always @(posedge clk) begin
    if (c_cnt == CARRIER_DIV-1) begin
        c_cnt <= 0;
        car <= ~car;
    end else
        c_cnt <= c_cnt + 1;
end
assign carrier = car;

// ========== DATA GENERATION ==========
reg [10:0] d_cnt = 0;
reg [2:0] bit_idx = 0;
reg d = 0;
always @(posedge clk) begin
    if (d_cnt == BIT_PERIOD-1) begin
        d_cnt <= 0;
        bit_idx <= (bit_idx == 7) ? 0 : bit_idx + 1;
        d <= DATA_PATTERN[7 - bit_idx];
    end else
        d_cnt <= d_cnt + 1;
end
assign data = d;

// ========== MODULATION ==========
reg mod = 0;
always @(posedge clk) begin
    if (c_cnt == 0) begin
        mod <= d ? ~car : car;
    end
end
assign modulated = mod;

// ========== DEMODULATION ==========
reg [10:0] m_cnt = 0;
reg [10:0] err_cnt = 0;
reg demod = 0;
always @(posedge clk) begin
    if (m_cnt == 0) err_cnt <= 0;
    if (mod != car) err_cnt <= err_cnt + 1;

    if (m_cnt == BIT_PERIOD-1) begin
        demod <= (err_cnt > BIT_PERIOD/2);
        m_cnt <= 0;
    end else
        m_cnt <= m_cnt + 1;
end
assign demodulated = demod;

endmodule



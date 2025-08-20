module fsk (
    input clk,                // 10 MHz system clock
    output reg data,          // current input bit
    output carrier_high,      // 5 kHz digital carrier (used when bit = 1)
    output carrier_low,       // 2 kHz digital carrier (used when bit = 0)
    output reg modulated,     // FSK modulated signal
    output reg demodulated    // demodulated bit using edge count
);

    parameter CLK_FREQ = 10_000_000;
    parameter BIT_RATE = 1000;

    parameter FREQ_MARK  = 4000;   // for bit 1
    parameter FREQ_SPACE = 1000;   // for bit 0

    reg [7:0] custom_data = 8'b10110011;
    reg [2:0] bit_index = 0;

    // Bit timer
    localparam BIT_PERIOD = CLK_FREQ / BIT_RATE;
    reg [31:0] bit_cnt = 0;

    always @(posedge clk) begin
        if (bit_cnt == BIT_PERIOD - 1) begin
            bit_cnt <= 0;
            data <= custom_data[7 - bit_index];
            bit_index <= (bit_index == 7) ? 0 : bit_index + 1;
        end else begin
            bit_cnt <= bit_cnt + 1;
        end
    end

    // === Carrier Signals ===
    reg carr_low = 0, carr_high = 0;
    reg [15:0] cnt_low = 0, cnt_high = 0;

    localparam LOW_HALF = CLK_FREQ / (2 * FREQ_SPACE); // 2.5k cycles for 2kHz
    localparam HIGH_HALF = CLK_FREQ / (2 * FREQ_MARK); // 1k cycles for 5kHz

    always @(posedge clk) begin
        // Low frequency carrier
        if (cnt_low == LOW_HALF - 1) begin
            cnt_low <= 0;
            carr_low <= ~carr_low;
        end else cnt_low <= cnt_low + 1;

        // High frequency carrier
        if (cnt_high == HIGH_HALF - 1) begin
            cnt_high <= 0;
            carr_high <= ~carr_high;
        end else cnt_high <= cnt_high + 1;
    end

    assign carrier_low = carr_low;
    assign carrier_high = carr_high;

    // === FSK Modulation ===
    always @(posedge clk) begin
        modulated <= data ? carr_high : carr_low;
    end

    // === Demodulation ===
    reg [2:0] shift = 0;
    reg [15:0] edge_count = 0;

    always @(posedge clk) begin
        shift <= {shift[1:0], modulated};
        if (shift[2] ^ shift[1]) edge_count <= edge_count + 1;

        if (bit_cnt == BIT_PERIOD - 1) begin
            demodulated <= (edge_count > 6); // >6 edges ~5kHz = logic 1
            edge_count <= 0;
        end
    end

endmodule



module dpsk (
    input wire clk,              // 12 MHz system clock
    output reg carrier_0,        // 0° carrier
    output reg carrier_180,      // 180° carrier
    output reg data_bit,         // original bitstream
    output reg encoded_bit,      // XNOR encoded bit
    output reg modulated,        // DPSK modulated output
    output reg demodulated,      // encoded stream at RX
    output reg decoded           // recovered original bitstream
);

    // === Parameters ===
    parameter CARRIER_DIV = 30000;   // 2 kHz carrier
    parameter BIT_DIV     = 150000;  // 80 Hz bit rate

    // === Carrier Generation (2 kHz square wave) ===
    reg [15:0] car_cnt = 0;
    always @(posedge clk) begin
        if (car_cnt == (CARRIER_DIV / 2 - 1)) begin
            car_cnt <= 0;
            carrier_0 <= ~carrier_0;
        end else begin
            car_cnt <= car_cnt + 1;
        end
        carrier_180 <= ~carrier_0;
    end

   // Message Signal Generation Block
reg [7:0] pattern = 8'b10110110;   // Original sequence
reg [2:0] bit_index = 0;           
reg [17:0] bit_timer = 0;          

// Encoder reference
reg ref = 0;
reg encoded_next;
reg data_bit;  // Output data bit
reg encoded_bit;  // Encoded bit for modulation

always @(posedge clk) begin
    if (bit_timer == BIT_DIV-1) begin
        bit_timer <= 0;

        // Output current data bit (direct from pattern, no inversion)
        data_bit <= pattern[7 - bit_index];  // MSB first

        // Standard differential encoding: XOR with previous reference
        encoded_next = ref ^ pattern[7 - bit_index];  // XOR encoding
        encoded_bit <= encoded_next;
        ref <= encoded_next;  // Update reference for next bit

        // Move to next bit
        if (bit_index == 7)
            bit_index <= 0;
        else
            bit_index <= bit_index + 1;

    end else begin
        bit_timer <= bit_timer + 1;
    end
end

    // === DPSK Modulation ===
    reg phase = 0;
    always @(posedge clk) begin
        if (bit_timer == 0) begin
            if (encoded_bit == 1)
                phase <= ~phase; // toggle phase on 1
        end
        modulated <= carrier_0 ^ phase;
    end

    // === DPSK Demodulation ===
    reg prev_sample = 0;
    reg decoded_bit = 0;
    reg prev_demod  = 0;

    always @(posedge clk) begin
        if (bit_timer == 0) begin
            prev_sample <= modulated;  // store phase start
        end
        else if (bit_timer == (BIT_DIV / 2)) begin
            // Detect phase change → gives encoded stream
            decoded_bit  <= ~(prev_sample ^ modulated);
            demodulated  <= decoded_bit;

            // Differential decoding → recover original data
            decoded      <= ~(decoded_bit ^ prev_demod);
            prev_demod   <= decoded_bit;
        end
    end

endmodule

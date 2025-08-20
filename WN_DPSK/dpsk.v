module dpsk (
    input wire clk,              // 12 MHz system clock
    output reg carrier_0,        // 0° carrier
    output reg carrier_180,      // 180° carrier
    output reg data_bit,         // original bitstream
    output reg encoded_bit,      // XNOR encoded bit
    output reg modulated,        // DPSK modulated output
    output reg demodulated       // recovered bitstream (original)
);

    // === Parameters ===
    parameter CARRIER_DIV = 30000;   // 2 kHz carrier
    parameter BIT_DIV     = 150000;  // 80 Hz message frequency

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

    // === Bit Pattern ===
    reg [7:0] pattern = 8'b10101100;
    reg [2:0] bit_index = 0;
    reg [17:0] bit_timer = 0;

    // === XNOR Encoding ===
    reg ref = 0;
    reg encoded_next;

    always @(posedge clk) begin
        if (bit_timer == BIT_DIV - 1) begin
            bit_timer <= 0;
            
            // Output current data bit
            data_bit = ~ pattern[bit_index];
            demodulated <= data_bit;
            // XNOR encode
            encoded_next = ~(ref ^ data_bit); // XNOR
            encoded_bit <= encoded_next;
            ref <= encoded_next; // update reference

            // Move to next bit
            bit_index <= (bit_index == 7) ? 0 : bit_index + 1;

        end else begin
            bit_timer <= bit_timer + 1;
        end
    end

    // === DPSK Modulation ===
    reg phase = 0;
    always @(posedge clk) begin
        if (bit_timer == 0) begin
            if (encoded_bit)
                phase <= ~phase; // toggle phase on 1
        end
        modulated <= carrier_0 ^ phase;
    end
    // === DPSK Demodulation with Differential Decoding ===
   

endmodule

module OLED(
    output SCL,         // OLED serial Clock
    output SDA,         // OLED serial Data
          // Activity LED
);

parameter T = 5;        // Delay between instructions

// I2C interface
wire Busy;
wire Clk;              
reg Start = 0;
reg DCn = 0;
reg [7:0] DATA = 0;

reg [15:0] d = 0;
reg [12:0] delay = 0;
reg [7:0] addr = 0;
reg [7:0] col = 0;        // Expanded to 8 bits
reg [5:0] step = 0;
reg [2:0] page = 0;
reg bank = 0;
reg mem = 0;
reg page_done = 0;        // New flag for page completion

wire [15:0] dout1;
wire [15:0] dout2;

// Clock generation
SB_HFOSC #(
    .CLKHF_DIV("0b11")  // Divide by 4 for 12MHz
) inthosc (
    .CLKHFPU(1'b1),     // Power up
    .CLKHFEN(1'b1),     // Enable
    .CLKHF(Clk)         // Output clock
);

// I2C Master
I2C Mod(
    .clk(Clk),
    .start(Start),
    .DCn(DCn),
    .Data(DATA),
    .busy(Busy),
    .scl(SCL),
    .sda(SDA)
);

// Memory blocks
SB_RAM40_4K Mem1(
    .WDATA(16'd0),
    .MASK(16'd0),
    .WADDR(11'd0),
    .WE(1'b1),
    .WCLKE(1'b0),
    .WCLK(1'b0),
    .RDATA(dout1),
    .RADDR({3'b0, addr}),
    .RE(1'b1),
    .RCLKE(1'b1),
    .RCLK(Clk)
);

SB_RAM40_4K Mem2(
    .WDATA(16'd0),
    .MASK(16'd0),
    .WADDR(11'd0),
    .WE(1'b1),
    .WCLKE(1'b0),
    .WCLK(1'b0),
    .RDATA(dout2),
    .RADDR({3'b0, addr}),
    .RE(1'b1),
    .RCLKE(1'b1),
    .RCLK(Clk)
);

// Memory selection
always @(negedge Clk) begin
    d <= mem ? dout2 : dout1;
end

// Main state machine with page handling
always @(posedge Clk) begin
    LED <= |step;  // LED on during activity
    
    if (delay != 0) begin
        delay <= delay - 1;
    end 
    else begin
        if (Busy) begin
            Start <= 0;
            delay <= T;
        end 
        else begin
            case(step)
                // Initialization sequence
                0: begin DATA <= 8'hAE; DCn <= 0; Start <= 1; step <= 1; delay <= T; end // Display off
                1: begin DATA <= 8'h20; DCn <= 0; Start <= 1; step <= 2; delay <= T; end // Set Memory Mode
                2: begin DATA <= 8'h00; DCn <= 0; Start <= 1; step <= 3; delay <= T; end // Horizontal addressing
                3: begin DATA <= 8'h21; DCn <= 0; Start <= 1; step <= 4; delay <= T; end // Set column address
                4: begin DATA <= 8'h00; DCn <= 0; Start <= 1; step <= 5; delay <= T; end // Start column = 0
                5: begin DATA <= 8'h7F; DCn <= 0; Start <= 1; step <= 6; delay <= T; end // End column = 127
                6: begin DATA <= 8'h22; DCn <= 0; Start <= 1; step <= 7; delay <= T; end // Set page address
                7: begin DATA <= 8'h00; DCn <= 0; Start <= 1; step <= 8; delay <= T; end // Start page = 0
                8: begin DATA <= 8'h07; DCn <= 0; Start <= 1; step <= 9; delay <= T; end // End page = 7
                9: begin DATA <= 8'h8D; DCn <= 0; Start <= 1; step <= 10; delay <= T; end // Charge pump
                10: begin DATA <= 8'h14; DCn <= 0; Start <= 1; step <= 11; delay <= T; end // Enable charge pump
                11: begin DATA <= 8'hA1; DCn <= 0; Start <= 1; step <= 12; delay <= T; end // Segment remap
                12: begin DATA <= 8'hC8; DCn <= 0; Start <= 1; step <= 13; delay <= T; end // COM output scan direction
                13: begin DATA <= 8'hDA; DCn <= 0; Start <= 1; step <= 14; delay <= T; end // COM pins hardware config
                14: begin DATA <= 8'h12; DCn <= 0; Start <= 1; step <= 15; delay <= T; end // Alternative COM pin config
                15: begin DATA <= 8'h81; DCn <= 0; Start <= 1; step <= 16; delay <= T; end // Set contrast
                16: begin DATA <= 8'hCF; DCn <= 0; Start <= 1; step <= 17; delay <= T; end // Contrast value
                17: begin DATA <= 8'hD9; DCn <= 0; Start <= 1; step <= 18; delay <= T; end // Set pre-charge period
                18: begin DATA <= 8'hF1; DCn <= 0; Start <= 1; step <= 19; delay <= T; end // Pre-charge: 15 clocks on discharge, 1 on charge
                19: begin DATA <= 8'hDB; DCn <= 0; Start <= 1; step <= 20; delay <= T; end // Set VCOMH deselect level
                20: begin DATA <= 8'h40; DCn <= 0; Start <= 1; step <= 21; delay <= T; end // VCOMH = ~0.77 * VCC
                21: begin DATA <= 8'hA4; DCn <= 0; Start <= 1; step <= 22; delay <= T; end // Display resume to RAM
                22: begin DATA <= 8'hA6; DCn <= 0; Start <= 1; step <= 23; delay <= T; end // Normal display
                23: begin DATA <= 8'hAF; DCn <= 0; Start <= 1; step <= 24; delay <= T; end // Display on
                
                // Start sending frame buffer data
                24: begin
                    DATA <= 8'hB0 | page; // Set current page
                    DCn <= 0;
                    Start <= 1;
                    col <= 0;             // Reset column counter
                    addr <= page << 6;     // Start addr = page*64 (since 128 bytes/page, 2 bytes/word)
                    bank <= 0;
                    step <= 25;
                    delay <= T;
                end
                
                // Send data for current page
                25: begin
                    if (bank == 0) begin
                        DATA <= d[7:0];   // Send low byte
                        bank <= 1;
                    end
                    else begin
                        DATA <= d[15:8];  // Send high byte
                        bank <= 0;
                        addr <= addr + 1;  // Move to next word
                    end
                    
                    DCn <= 1;
                    Start <= 1;
                    col <= col + 1;
                    delay <= T;
                    
                    // Check if page complete (128 bytes sent)
                    if (col == 127 && bank == 0) begin
                        page_done <= 1;
                    end
                    
                    // Move to next page when current page complete
                    if (page_done) begin
                        page_done <= 0;
                        page <= page + 1;
                        if (page == 7) begin
                            page <= 0;     // Wrap to first page
                            mem <= ~mem;   // Toggle between Mem1 and Mem2
                        end
                        step <= 24;       // Set up next page
                    end
                end
                
                default: step <= 0;
            endcase
        end
    end
end

// Frame buffer initialization
// Mem1 - "WIRING NEURONS" in first line, others cleared
defparam Mem1.INIT_0 = 256'h0000003E4141413E00404040407F00404040407F00414949497F007F0808087F;
defparam Mem1.INIT_1 = 256'h0;
defparam Mem1.INIT_2 = 256'h0;
defparam Mem1.INIT_3 = 256'h0;
defparam Mem1.INIT_4 = 256'h0;
defparam Mem1.INIT_5 = 256'h0;
defparam Mem1.INIT_6 = 256'h0;
defparam Mem1.INIT_7 = 256'h0;
defparam Mem1.INIT_8 = 256'h0;
defparam Mem1.INIT_9 = 256'h0;
defparam Mem1.INIT_A = 256'h0;
defparam Mem1.INIT_B = 256'h0;
defparam Mem1.INIT_C = 256'h0;
defparam Mem1.INIT_D = 256'h0;
defparam Mem1.INIT_E = 256'h0;
defparam Mem1.INIT_F = 256'h0;

//   Mem2 ‑ all pages cleared
defparam Mem2.INIT_0 = 256'h0;
defparam Mem2.INIT_1 = 256'h0;
defparam Mem2.INIT_2 = 256'h0;
defparam Mem2.INIT_3 = 256'h0;
defparam Mem2.INIT_4 = 256'h0;
defparam Mem2.INIT_5 = 256'h0;
defparam Mem2.INIT_6 = 256'h0;
defparam Mem2.INIT_7 = 256'h0;
defparam Mem2.INIT_8 = 256'h0;
defparam Mem2.INIT_9 = 256'h0;
defparam Mem2.INIT_A = 256'h0;
defparam Mem2.INIT_B = 256'h0;
defparam Mem2.INIT_C = 256'h0;
defparam Mem2.INIT_D = 256'h0;
defparam Mem2.INIT_E = 256'h0;
defparam Mem2.INIT_F = 256'h0;


endmodule

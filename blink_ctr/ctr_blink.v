module ctr_blink (
  output reg led_8,  // Pin 38
  output reg led_7,  // Pin 42
  output reg led_6,  // Pin 43
  output reg led_5,  // Pin 44
  output reg led_4,  // Pin 45
  output reg led_3,  // Pin 46
  output reg led_2,  // Pin 47
  output reg led_1,  // Pin 48
  
  
);

  // Internal 12 MHz oscillator
  wire clk;
  reg [26:0] delay_counter = 0;
  reg [2:0] state = 0;

  // Instantiate internal oscillator
  SB_HFOSC u_SB_HFOSC (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(clk)
  );
  
  

  always @(posedge clk) begin
    delay_counter <= delay_counter + 1;
    if (state == 8)
        state <= 0;

    if (delay_counter == 26'd48000000) begin 
      delay_counter <= 0;
      state <= state + 1;
      
    end
  end

  // LED control logic
  always @(*) begin
    led_8 = (state == 0);
    led_7 = (state == 1);
    led_6 = (state == 2);
    led_5 = (state == 3);
    led_4 = (state == 4);
    led_3 = (state == 5);
    led_2 = (state == 6);
    led_1 = (state == 7);
  end

endmodule

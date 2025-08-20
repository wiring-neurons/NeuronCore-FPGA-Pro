//----------------------------------------------------------------------------
//                                                                          --
//                         Module Declaration                               --
//                                                                          --
//----------------------------------------------------------------------------
module rgb_blink (
  // outputs
  output wire led_red  , // Red
  output wire led_blue , // Blue
  output wire led_green  // Green
);

  wire        int_osc            ;
  reg  [26:0] frequency_counter_i;
  reg [2:0] state = 0;
  reg [0:0] red = 0;
  reg [0:0] green = 0;
  reg [0:0] blue = 0;

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
  SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));


//----------------------------------------------------------------------------
//                                                                          --
//                       Counter                                            --
//                                                                          --
//----------------------------------------------------------------------------
  always @(posedge int_osc) begin
    frequency_counter_i <= frequency_counter_i + 1;
    
    
    
    
    if(state == 0) begin
    	red <= 0;
    	green <= 0;
    	blue <= 0;
    end else if(state == 1) begin
    	red <= 1;
    end else if(state == 2) begin
    	red <=0;
    	green <=1;
    end else if(state == 3) begin
    	green <=0;
    	blue <=1;
    end else if(state == 4) begin
    	blue <=0;
    	red <=1;
    	green <=1;
    end else if(state == 5) begin
    	red <=0;
    	blue <=1;
    end else if(state == 6) begin
    	green <=0;
    	red <=1;
    end else if(state == 7) begin
    	green <=1;
    end else if(state == 8 )
    	state <=0;
    
    
    
    
    if(frequency_counter_i == 26'd48000000 ) begin
    	frequency_counter_i <=0 ;
    	state <= state + 1;
     end
     
     
     
  end

//----------------------------------------------------------------------------
//                                                                          --
//                       Instantiate RGB primitive                          --
//                                                                          --
//----------------------------------------------------------------------------
  SB_RGBA_DRV RGB_DRIVER (
    .RGBLEDEN(1'b1                                            ),
    .RGB0PWM (red),
    .RGB1PWM (green),
    .RGB2PWM (blue),
    .CURREN  (1'b1                                            ),
    .RGB0    (led_red                                       ), //Actual Hardware connection
    .RGB1    (led_green                                        ),
    .RGB2    (led_blue                                       )
  );
  defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
  defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule

module or_and (
  // Inputs from push buttons
  input wire and_in1,
  input wire and_in2,
  input wire or_in1,    
  input wire or_in2,


  // Outputs
  output reg  enable,     // Pin 6  (to enable push buttons externally)
  output reg  and_result, // Pin 38 (AND output)
  output reg  or_result, 

  output reg  led_1,
  output reg  led_2,
  output reg  led_3,
  output reg  led_4

);



  always @(*) begin
    // Enable the push button circuit
    enable = 1'b1;
   
    // Process logic only when buttons are enabled
    
    led_1 = and_in1;
    led_2 = and_in2;
    led_3 = or_in1;
    led_4 = or_in2;

    and_result = and_in1 & and_in2;
    or_result = or_in1 | or_in2;
    
  end

endmodule


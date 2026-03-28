module fsk (
	input wire carr_clk,
	input wire carr_clk2,
	input wire msg_clk,                 
	input wire sine_cosine,             // 1 = sine, 0 = cosine
	input wire [7:0] message,
	output reg [7:0] carr,           // 8-bit wave output
	output reg [7:0] carr2,
	output reg [7:0] mod,
	output reg [7:0] msg
);

	// 20 samples per cycle
	reg [4:0] index = 0;                // 0 to 19
	reg [4:0] index2 = 0;  
	reg [2:0] count = 7;

	// 20-point sine LUT (8-bit scaled)
	reg [7:0] sine_lut [0:19];

	initial begin
		sine_lut[0]  = 8'd127;
		sine_lut[1]  = 8'd166;
		sine_lut[2]  = 8'd202;
		sine_lut[3]  = 8'd230;
		sine_lut[4]  = 8'd248;
		sine_lut[5]  = 8'd254;
		sine_lut[6]  = 8'd248;
		sine_lut[7]  = 8'd230;
		sine_lut[8]  = 8'd202;
		sine_lut[9]  = 8'd166;
		sine_lut[10] = 8'd127;
		sine_lut[11] = 8'd88;
		sine_lut[12] = 8'd52;
		sine_lut[13] = 8'd24;
		sine_lut[14] = 8'd6;
		sine_lut[15] = 8'd0;
		sine_lut[16] = 8'd6;
		sine_lut[17] = 8'd24;
		sine_lut[18] = 8'd52;
		sine_lut[19] = 8'd88;
	end
    
	always @(posedge carr_clk) begin
    
		if (index == 19)
			index <= 0;
		else
			index <= index + 1;
    
		// Sine or Cosine selection
		if (sine_cosine)
			carr <= sine_lut[index];             // Sine
		else
			carr <= sine_lut[(index + 5) % 20];  // Cosine (90° shift)
            
		if(msg)
			mod <= carr;
		else
			mod <= carr2;
            	          
	end
    
	always @(posedge carr_clk2) begin
    
		if (index2 == 19)
			index2 <= 0;
		else
			index2 <= index2 + 1;
    
		// Sine or Cosine selection
		if (sine_cosine)
			carr2 <= sine_lut[index2];             // Sine
		else
			carr2 <= sine_lut[(index2 + 5) % 20];  // Cosine (90° shift)
            
	end
    
	always @(posedge msg_clk) begin
    
		if (count == 0)
			count <= 7;
		else
			count <= count - 1;
                
		msg <= message[count];
  
	end
    
endmodule

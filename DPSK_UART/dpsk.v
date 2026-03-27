module dpsk (
	input wire carr_clk,
	input wire msg_clk,                 
	input wire sine_cosine,             // 1 = sine, 0 = cosine
	input wire [7:0] message,
	output reg [7:0] carr,           // 8-bit wave output
	output reg [7:0] mod,
	output reg [7:0] msg,
	output reg [7:0] enc,
	output reg [7:0] demod
);

    // 20 samples per cycle
	reg [4:0] index = 0;                // 0 to 19
	reg [4:0] mod_index = 0;
	reg [2:0] count = 7;
	reg [2:0] demod_count = 0;
	reg [7:0] mod_prev2;
	reg [7:0] mod_prev1;
	reg [0:0] ref_enc = 0;
	reg [2:0] prev_count;
	reg [0:0] denc;
	reg [0:0] ref_denc = 0;

    
	reg [0:0] phase = 1;

    // 20-point sine LUT (8-bit scaled)
	reg [7:0] sine_lut [0:19];

	initial begin
		sine_lut[0]  = 8'd127;
		sine_lut[1]  = 8'd166;
		sine_lut[2]  = 8'd202;
		sine_lut[3]  = 8'd230;
		sine_lut[4]  = 8'd248;
		sine_lut[5]  = 8'd254;  // High
		sine_lut[6]  = 8'd248;
		sine_lut[7]  = 8'd230;
		sine_lut[8]  = 8'd202;
		sine_lut[9]  = 8'd166;
		sine_lut[10] = 8'd127;
		sine_lut[11] = 8'd88;
		sine_lut[12] = 8'd52;
		sine_lut[13] = 8'd24;
		sine_lut[14] = 8'd6;
		sine_lut[15] = 8'd0;   // Low
		sine_lut[16] = 8'd6;
		sine_lut[17] = 8'd24;
		sine_lut[18] = 8'd52;
		sine_lut[19] = 8'd88;
        
		msg[1] = 0;
		msg[2] = 0;
		msg[3] = 0;
		msg[4] = 0;
		msg[5] = 0;
		msg[6] = 0;
		msg[7] = 0;
        
		enc[1] = 0;
		enc[2] = 0;
		enc[3] = 0;
		enc[4] = 0;
		enc[5] = 0;
		enc[6] = 0;
		enc[7] = 0;
        
		demod[1] = 0;
		demod[2] = 0;
		demod[3] = 0;
		demod[4] = 0;
		demod[5] = 0;
		demod[6] = 0;
		demod[7] = 0;
        
    end
    
	always @(posedge carr_clk) begin
    
		if (index == 19)
			index <= 0;
		else
			index <= index + 1;
              
		if (mod_index == 19)
			mod_index <= 0;
		else
			mod_index <= mod_index + 1;
    
		// Sine or Cosine selection
		if (sine_cosine)
			carr <= sine_lut[index];             // Sine
		else
			carr <= sine_lut[(index + 5) % 20];  // Cosine (90° shift)
                                
                
		if( ( count > prev_count ) || ( count < prev_count ) ) begin
            
			prev_count <= count;
            
			if(enc) begin
            	
				if(phase) begin
            	   
					mod_index <= 0;
					phase <= 0;
            	   
				end else if(~phase) begin
            	   
					mod_index <= 10;
					phase <= 1;
            	   
				end
            	   
			end
            
		end 
            
            
		if (sine_cosine)
			mod <= sine_lut[mod_index];             // Sine
		else
			mod <= sine_lut[(mod_index + 5) % 20];  // Cosine (90° shift)
               
            
		if(mod_prev1 == 127) begin
            
			if((mod > 127) && (mod_prev2 > 127)) begin
            	    
				denc <= 1;
				demod_count <= 0;            	    
            	    
			end else if((mod < 127) && (mod_prev2 < 127)) begin
            	
				denc <= 1;
				demod_count <= 0;            	    
            	
			end else if( (denc == 1) && ( demod_count > 2 ) ) begin
            	
				denc <= 0;
				demod_count <= 0;
            	
			end else if(denc == 1) begin
            	
				demod_count <= demod_count + 1;
            	   
			end
            
		end
                
                  
		if(mod_prev1 != mod)
			mod_prev1 <= mod;
            
            
		if(mod_prev2 != mod_prev1)
			mod_prev2 <= mod_prev1;
            	

	end
    
	always @(posedge msg_clk) begin
    
		if (count == 0)
			count <= 7;
		else
			count <= count - 1;
                
		msg[0] <= message[count];
		enc[0] = ~(message[count] ^ ref_enc);
    	   
		ref_enc <= enc[0];
    	   
		demod[0] = ~(denc ^ ref_denc);
    	   
		ref_denc <= denc;
    	     
    	   
	end
    
endmodule

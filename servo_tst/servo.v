module servo (
    output reg pwm_out  // Changed to wire since we're using direct assignment
);

wire clk;
reg [19:0] counter = 0;
reg [18:0] pw;
reg [8:0]  acount = 0;
reg [10:0] od = 534;
reg [0:0] up = 1'b0;
   
    
    // Instantiate internal oscillator (48 MHz default)
SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
    
    always @(posedge clk) begin
        counter <= counter + 1;

	pw <= 24000 + (od*acount);
        
        // 20ms period (for 50Hz servo signal)
        if (counter >= 20'd960000) begin  // 48MHz / 50Hz = 960,000 cycles
            counter <= 0;
	    if(up) begin
	      acount <= acount-1;
	      if(acount == 0)
	        up <= 1'b0;
            end else if(~up) begin
	      acount <= acount+1;
	      if(acount == 180)
                up <= 1'b1;
	    end
	end
            
        // Pulse width control (0.5-2.5ms)
        if (counter < pw)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
	

    end
    

    
endmodule

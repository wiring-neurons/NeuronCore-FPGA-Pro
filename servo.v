module servo (
    output wire pwm_out  // Changed to wire since we're using direct assignment
);

    wire clk;
    reg [19:0] counter = 0;  // Reduced bit width since we only need ~1ms resolution
    
    // Internal signal for PWM generation
    reg pwm_signal;
    
    // Instantiate internal oscillator (48 MHz default)
    SB_HFOSC u_SB_HFOSC (
        .CLKHFPU(1'b1), 
        .CLKHFEN(1'b1), 
        .CLKHF(clk)
    );
    
    // Main PWM generation
    always @(posedge clk) begin
        counter <= counter + 1;
        
        // 20ms period (for 50Hz servo signal)
        if (counter >= 20'd960000)  // 48MHz / 50Hz = 960,000 cycles
            counter <= 0;
            
        // Pulse width control (1-2ms typically)
        if (counter < 20'd72000)    // 1.5ms pulse (neutral position)
            pwm_signal <= 1'b1;
        else
            pwm_signal <= 1'b0;
    end
    
    assign pwm_out = pwm_signal;
    
endmodule

module ask (

	output reg carrier,
	output reg message,
	output reg ask_mod,
	output reg ask_demod

);

wire clk;

reg [26:0] msg_ctr;
reg [26:0] msg_freq = 48000000/ 1000; //1 hz message signal
reg [26:0] car_ctr;
reg [26:0] car_freq = 48000000/ 8000; //8 hz carrier signal
reg [26:0] demod_ctr = 1;
reg [7:0] msg = 8'b10101100;
reg [2:0] eb_ctr = 0;

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

always @(posedge clk) begin

	msg_ctr <= msg_ctr+1;
	car_ctr <= car_ctr+1;


	if( car_ctr == car_freq) begin
	    car_ctr <= 0;
	    carrier <= ~carrier;
	    
	end

	if( msg_ctr == msg_freq) begin
	    msg_ctr <= 0;
	    ask_demod <= 0;
	    if( eb_ctr == 7) begin
		eb_ctr <= 0;
            end
	    message <= msg[7 - eb_ctr];           
	    eb_ctr <= eb_ctr + 1;
	    
	end
	
	ask_mod <= carrier & message;

	if(~ask_mod) begin
	   demod_ctr <= demod_ctr + 1;
	end else begin
	   demod_ctr <= 1;
	end

	if(demod_ctr > car_freq + 10) begin
	   ask_demod <= 1'b0;
	end else begin
	   ask_demod <= 1'b1;
	end

end

endmodule

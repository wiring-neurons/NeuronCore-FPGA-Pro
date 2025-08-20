module bpsk (

	output reg carrier,
	output reg message,
	output reg bpsk_mod,
	output reg bpsk_demod

);

wire clk;

reg [26:0] msg_ctr;
reg [26:0] msg_freq = 48000000/ 1; //1 hz message signal
reg [26:0] car_ctr;
reg [26:0] car_freq = 48000000/ 8; //8 hz carrier signal
reg [26:0] demod_ctr;
reg [7:0] msg = 8'b10101100;
reg [2:0] eb_ctr = 0;
reg [0:0] edge_1;
reg [0:0] edge_0;

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

always @(posedge clk) begin

	msg_ctr <= msg_ctr+1;
	car_ctr <= car_ctr+1;


	if( car_ctr == car_freq) begin
	    car_ctr <= 0;
	    carrier <= ~carrier;
	    if(~edge_1 && ~edge_0) begin
	       bpsk_mod <= carrier;
	    end else begin
	       edge_1 <= 0;
               edge_0 <= 0;
            end
	    
	end

	if( msg_ctr == msg_freq) begin
	    msg_ctr <= 0;
	    if( eb_ctr == 7) begin
		eb_ctr <= 0;
            end
	    message <= msg[7 - eb_ctr];    

	    if(msg[7 - eb_ctr] == 1) begin
	       edge_1 <= 1;
	    end else if (msg[7 - eb_ctr] == 0) begin
	       edge_0 <= 1;
	    end        
	    eb_ctr <= eb_ctr + 1;
	    
	end
	
	



end

endmodule

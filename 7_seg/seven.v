module seven (
	
	output reg BR,
	output reg TR,
	output reg B,
	output reg BL,
	output reg TL,
	output reg M,
	output reg T,
	output reg D1,
	output reg D2

);

wire clk ;
reg [26:0] counter;
reg [16:0] counter2;
reg [3:0] d1state = 0;
reg [3:0] d2state = 0;
reg [3:0] state;
reg [0:0] toggle;

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

  always @(posedge clk) begin
     counter <= counter + 1;
     counter2 <= counter2 + 1;


	D1 <= toggle;
	D2 <= ~toggle;

	if(D1 == 1) begin
	state <= d2state;
	end else if(D2 == 1) begin
	state <= d1state;
	end

	if(state == 0) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b1;
	BL <= 1'b1;
	TL <= 1'b1;
	 M <= 1'b0;
	 T <= 1'b1;
	
	end

	if(state == 1) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b0;
	BL <= 1'b0;
	TL <= 1'b0;
	 M <= 1'b0;
	 T <= 1'b0;
	
	end
	
	if(state == 2) begin
	BR <= 1'b0;
	TR <= 1'b1;
	 B <= 1'b1;
	BL <= 1'b1;
	TL <= 1'b0;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(state == 3) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b1;
	BL <= 1'b0;
	TL <= 1'b0;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(state == 4) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b0;
	BL <= 1'b0;
	TL <= 1'b1;
	 M <= 1'b1;
	 T <= 1'b0;
	
	end

	if(state == 5) begin
	BR <= 1'b1;
	TR <= 1'b0;
	 B <= 1'b1;
	BL <= 1'b0;
	TL <= 1'b1;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(state == 6) begin
	BR <= 1'b1;
	TR <= 1'b0;
	 B <= 1'b1;
	BL <= 1'b1;
	TL <= 1'b1;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(state == 7) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b0;
	BL <= 1'b0;
	TL <= 1'b0;
	 M <= 1'b0;
	 T <= 1'b1;
	
	end

	if(state == 8) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b1;
	BL <= 1'b1;
	TL <= 1'b1;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(state == 9) begin
	BR <= 1'b1;
	TR <= 1'b1;
	 B <= 1'b1;
	BL <= 1'b0;
	TL <= 1'b1;
	 M <= 1'b1;
	 T <= 1'b1;
	
	end

	if(d2state == 10) begin
	d2state <= 0;
	d1state <= d1state + 1;
	end

	if(d1state == 10) begin
	d1state <= 0;
	end

     if(counter2 == 16'd48000) begin
	counter2 <= 0;
	toggle <= ~toggle;
	end


     if(counter == 26'd48000000 ) begin
    	counter <= 0 ;
    	d2state <= d2state + 1;
     end


 end

endmodule





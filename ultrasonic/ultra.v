module ultra (
	input  wire clk,    
	input  wire echo,  
	output reg  trig,  
	output reg tx,     
	output reg tx2
);

	reg [7:0] data;
	reg [0:0] over, idleframe = 0;
	reg [3:0] cnt = 1;
	reg [0:0] clk1;
	reg [4:0] clk1_counter = 0; // 25
    	reg [3:0] trigcounter = 1;
	reg [15:0] echocounter = 0;
	reg [15:0] duration = 0;
	reg [10:0] distance = 0;
	reg [3:0] d1, d2, d3, d4;

//	reg [18:0] clk1_freq = 500000;

uart_tx u1(
	.clk_uart(clk1),
	.data(data),
	.tx(tx),
	.tx2(tx2),
	.over(over),
	.idleframe(idleframe)
);

	always @(posedge clk) begin

		clk1_counter <= clk1_counter + 1;
		
		if(clk1_counter == 25) begin // 25000000/(clk1_freq*2)
		
			clk1 <= ~clk1;
			clk1_counter <= 0;
		
		end
		
		distance <= (duration * 343) / 20000;
		
		d1 <= distance/1000;
		d2 <= (distance/100) % 10;
		d3 <= (distance/10) % 10;
		d4 <= distance % 10;

	end

	always @(posedge clk1) begin
	
		if(trigcounter == 10)
			trigcounter <= 0;
		else
			trigcounter <= trigcounter + 1;

	
		if(trigcounter < 3) begin
			trig <= 0;
		end else if(trigcounter < 11) begin
			trig <= 1;
		end

	
		if(echo) begin
			echocounter <= echocounter + 1;
		end else begin
		
			if(echocounter != 0) begin
				duration <= echocounter;
			end
				
				
			echocounter <= 0;
		end
		
	
		
		if(over)begin

			case(cnt)
				1: begin
					idleframe <= 0;
					data <= d1 + 48;
					cnt <= cnt+1;
				end
				2: begin
					data <= d2 + 48;
					cnt <= cnt+1;
				end
				3: begin
					data <= d3 + 48;
					cnt <= cnt+1;
				end
				4: begin
					data <= d4 + 48;
					cnt <= cnt+1;
				end
				5: begin
					data <= 32;
					cnt <= cnt+1;
				end
				6: begin
					data <= "c";
					cnt <= cnt+1;
				end
				7: begin
					data <= "m";
					cnt <= cnt+1;
				end
				8: begin
					data <= 10; //Line Feed (LF)
					cnt <= cnt+1;
				end
				9: begin
					data <= 13; //Carraige Return (CR)
					cnt <= cnt+1;
				end
				10: begin
					idleframe <= 1;
					cnt <= 1;
				end
				
			endcase
		end
		
	end
	
endmodule

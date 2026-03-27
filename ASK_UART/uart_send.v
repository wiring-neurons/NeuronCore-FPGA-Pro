module uart_send (

	input wire clk,
	output reg tx, tx2
);

reg [7:0] data;
reg [0:0] over, idleframe = 0;
reg [7:0] cnt = 1;
reg [0:0] clk_uart;
reg [0:0] clk_carr;
reg [0:0] clk_msg;
reg [7:0] carr_out;
reg [7:0] msg = 8'b10101100;
reg [7:0] msg_out;
reg [7:0] mod_out;
reg [7:0] demod_out;
reg [18:0] freq_clk1 = 500000;
reg [11:0] freq_clk2 = 1600; // 80 hz frequency with 20 samples per cycle 80 x 20 = 1,600
reg [6:0]  freq_clk3 = 40; // 40 hz frequency 20 bits per second
reg [0:0] wave = 1;

clk clk0(
	
	.clk(clk),
	.clk1_freq(freq_clk1),
	.clk2_freq(freq_clk2),
	.clk3_freq(freq_clk3),
	.clk1(clk_uart),
	.clk2(clk_carr),
	.clk3(clk_msg)
	
);

ask m1(

	.car_clk(clk_carr),
	.msg_clk(clk_msg),
	.sine_cosine(wave),
	.message(msg),
	.carr(carr_out),
	.msg(msg_out),
	.mod(mod_out),
	.demod(demod_out)
	
);

uart_tx u1(
	.clk_uart(clk_uart),
	.data(data),
	.tx(tx),
	.tx2(tx2),
	.over(over),
	.idleframe(idleframe)
);


	always @(posedge clk_uart)begin
		
		if(over)begin

			case(cnt)
				1: begin
					idleframe <= 0;
					data <= 255;
					cnt <= cnt+1;
				end
				2: begin
					data <= carr_out; //    DAC
					cnt <= cnt+1;
				end
				3: begin
					data <= msg_out;
					cnt <= cnt+1;
				end
				4: begin
					data <= 127;
					cnt <= cnt+1;
				end
				5: begin
					data <= 127;
					cnt <= cnt+1;
				end
				6: begin
					data <= mod_out; //    DAC
					cnt <= cnt+1;
				end
				7: begin
					data <= demod_out;
					cnt <= cnt+1;
				end
				8: begin
					data <= 127;
					cnt <= cnt+1;
				end
				9: begin
					data <= 127;
					cnt <= 1;
				end
				
			endcase
		end
	end

endmodule

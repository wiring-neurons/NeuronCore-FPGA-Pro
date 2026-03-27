module clk(
	input wire clk,
	input wire [18:0] clk1_freq,
	input wire [11:0] clk2_freq,
	input wire [6:0]  clk3_freq,
	output reg clk1,
	output reg clk2,
	output reg clk3
);

reg [4:0] clk1_counter = 0; // 25
reg [17:0] clk2_counter = 0; // 1,56,250
reg [19:0] clk3_counter = 0; // 6,25,000

	always @(posedge clk) begin

		clk1_counter <= clk1_counter + 1;
		clk2_counter <= clk2_counter + 1;
		clk3_counter <= clk3_counter + 1;
		
		if(clk1_counter == 25000000/(clk1_freq*2)) begin
		
			clk1 <= ~clk1;
			clk1_counter <= 0;
		
		end
		
		if(clk2_counter == 25000000/(clk2_freq *2)) begin
		
			clk2 <= ~clk2;
			clk2_counter <= 0;
		
		end
		
		if(clk3_counter == 25000000/(clk3_freq *2)) begin
		
			clk3 <= ~clk3;
			clk3_counter <= 0;
		
		end
		

	end

endmodule

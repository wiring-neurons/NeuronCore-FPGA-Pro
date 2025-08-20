module ultra (
    input  wire clk,    // 12 MHz clock
    input  wire echo,   // Echo pin from sensor
    output reg  trig,   // Trigger pin to sensor
    output reg tx,      // UART TX line
    output reg tx2,
	output reg in1,
	output reg in2
);

    reg [2:0]  state = 0;
    reg [23:0] trigcounter = 1;
    reg [18:0] echocounter = 0;
	reg [7:0] d1, d2, d3, d4, d12, d22, d32, d42, d11, d21, d31;
    reg [13:0] num = 0;
	reg [23:0] num21 = 0;
	reg [23:0] num22 = 0;
	reg [23:0] num2 = 0;
	reg [13:0] num3 = 0;
	reg [0:0] sent = 1;
	reg [3:0] stage = 0;

    uart_tx uart0 (
        .clk(clk),

		.d1(d1),
		.d2(d2),
		.d3(d3),
		.d4(d4),
        .d12(d12),
		.d22(d22),
		.d32(d32),
		.d42(d42),
        .tx(tx),
	 	.tx2(tx2)
    );


    always @(posedge clk) begin

	trigcounter <= trigcounter + 1;

	if(trigcounter == 144) begin
	   trigcounter <= 1;
	end

	if(trigcounter <= 24) begin
	   trig <= 0;
	end else
	   trig <= 1;
	
	if(echo) begin
		echocounter <= echocounter + 1;
		sent <= 0;
	end else if(~sent && ~echo)begin


		case(stage)

			0: begin
				
				num3 <= echocounter/12;
				stage <= 1;
			end
			1: begin

				num21 <= num3 * 49;
				stage <= 2;
			end
			2: begin

				num22 <= num21 * 7;
				stage <= 3;
			end
			3: begin

				num2 <= num22 * 5;
				stage <= 4;
			end
			4: begin
		
				num <= num2/20000;
				stage <= 5;
			end
			5: begin

				d11 = num / 1000;
				d12 = d11 % 10;
				stage <= 6;	
			end
			6: begin

				d21 = num / 100;
				d22 = d21  % 10;
				stage <= 7;
			end
			7: begin
	
				d31 = num / 10;
				d32 = d31 % 10;
				stage <= 8;
			end
			8: begin
		
				d42 =  num % 10;
				stage <= 9;
			end
			9: begin

				d1 = d12 + 48;
				d2 = d22 + 48;
				stage <= 10;
			end
			10: begin
	
				d3 = d32 + 48;
				d4 = d42 + 48;
		
				sent <= 1;
				echocounter <= 0;
			
			end

		endcase

	end  
			if(digcount == 4) begin
				data <= d1;
			end else if(digcount == 3) begin
				data <= d2;
			end else if(digcount == 2) begin
				data <= d3;
			end else if(digcount == 1) begin
				data <= d4;
			end

	
	if(~busy)begin

	
		if(d12 != 0) begin
			digcount <= 4;
		end else if(d22 != 0) begin
			digcount <= 3;
		end else if(d32 != 0) begin
			digcount <= 2;
		end else begin
			digcount <=1;
		end
	

	
		busy <= 1;   
	
	end 




    end
endmodule


module uart_tx (
	input wire clk_uart,
	input wire [7:0] data,
	output reg tx,
	output reg tx2,
	output reg[0:0] over,
	input wire [0:0] idleframe	
);
		
//       1-48    START      0 
//      49-96    First      1 
//     97-144    Second     2 
//    145-192    Third      3 
//    193-240    Fourth     4 
//    241-288    Fifth      5 
//    289-336    Sixth      6 
//    337-384    Seventh    7 
//    385-432    Eight      8 
//    433-480    STOP       9 
//    baud 500000

reg [3:0] uartcounter = 0;
	
	always @(posedge clk_uart) begin
	
		uartcounter <= uartcounter + 1;
		tx2 <= tx;
	
		if(~idleframe)begin


			if(uartcounter == 0)begin
		
				tx <= 0;
				over <= 0;
			
			end else if(uartcounter > 0 && uartcounter < 8)begin
		
				tx <= data[uartcounter-1];
			
			end else if(uartcounter == 8)begin
			
				tx <= data[uartcounter - 1];
				over <= 1;
			
			end else if(uartcounter == 9)begin
			
				over <= 0;
				tx <= 1;
				uartcounter <= 0;
	  		
	   		end
		
		end	else if(idleframe)begin
		
			if(uartcounter < 8)begin
				over <= 0;
				tx <= 1;
			end else if(uartcounter == 8)begin
				over <= 1;
			end else if(uartcounter == 9)begin
				over <= 0;
				uartcounter <= 0;
			end

		end

	end

endmodule

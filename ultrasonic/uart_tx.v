module uart_tx (
    input  wire clk,
	input wire [7:0] data,
    output reg tx,
	output reg tx2
);

    reg[23:0] uartcounter = 1;
	reg[7:0] data;
    reg[9:0] sendcount = 0;
	reg[0:0] busy = 0;	

always @(posedge clk) begin

	uartcounter <= uartcounter + 1;
	tx2 <= tx;


	if(~busy) begin

		tx <= 1;
		busy <= 1;

	end
	
	if(busy) begin

		if(uartcounter <= 48)begin
			tx <= 0;
		end else if(uartcounter > 432 && uartcounter <= 480)begin
	   		tx <= 1;
			uartcounter <= 1;
			busy <= 0;
		end

	
		if(uartcounter == (sendcount*48)+48) begin
	   
			tx <= data[sendcount];
			sendcount <= sendcount + 1;

			if(sendcount == 8)begin
				sendcount <= 0;
				tx <= 1;
	 		end	
	
		end
	
	end 

end


endmodule


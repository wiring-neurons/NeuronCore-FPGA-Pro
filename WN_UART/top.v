module top (
	input wire clk,
	output reg tx,
	output reg tx2
);


reg [7:0] send;
reg [0:0] busy;
reg [7:0] data_r;

    uart_tx uart0 (
        .clk(clk),
		.data(send),
		.data_s(data_r),
		.busy(busy),
        .tx(tx),
	 	.tx2(tx2)
    );

always @(posedge clk) begin

send <= data_r;


if(~busy) begin

	send <= 35;
	
end



end

endmodule

	

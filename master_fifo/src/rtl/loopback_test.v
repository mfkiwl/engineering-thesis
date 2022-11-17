module loopback_test(
	// tx interface
	output wire				tx_write,
	output wire [31:0]	tx_data,
	
	// rx interface
	output wire				rx_read,
	input  wire				rx_valid,
	input  wire [31:0]	rx_data
	);
	
	assign tx_write	=	rx_valid;
	assign tx_data		=	rx_data;
	assign rx_read 	=	1'b1;
	
endmodule
module top_loopback (
	// Input
	input  wire 			CLK_USER, //27MHz
	input  wire 			CLK_FTDI, //100MHz
	input  wire 			HRST_N,
	input  wire 			SRST_N,
	input  wire 			TXE_N,
	input  wire				RXF_N,
	// Output
	inout  wire [31:0] 	DATA,
	inout  wire [3:0] 	BE,
	output wire 			WR_N, 
	output wire				RD_N,
	output wire				OE_N
	);

	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	wire usb_wr, usb_rd, usb_oe;
	
	wire [31:0] tx_data, rx_data;
	wire tx_write, rx_read;
	wire rx_valid;
	
	loopback_test u_loopback_test(
		.tx_write(tx_write),
		.tx_data(tx_data),
		.rx_read(rx_read),
		.rx_valid(rx_valid),
		.rx_data(rx_data)
	);
	
	core_ft245 u_core_ft245(
		.rst(rst),
		.tx_clk(CLK_FTDI),
		.tx_write(tx_write), //in
		.tx_data(tx_data), //in
		.tx_valid(), //out
		.rx_clk(CLK_FTDI), 
		.rx_read(rx_read), //in
		.rx_valid(rx_valid), //out
		.rx_data(rx_data), //out
		.usb_clk(CLK_FTDI),
		.usb_rxf(!RXF_N),
		.usb_txe(!TXE_N),
		.usb_wr(usb_wr),
		.usb_rd(usb_rd),
		.usb_oe(usb_oe),
		.usb_data(DATA),
		.usb_be(BE)
	);
	
	assign WR_N = ~usb_wr;
	assign RD_N = ~usb_rd;
	assign OE_N = ~usb_oe;
	
endmodule
module top_receiver (
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
	output wire				OE_N,
	output wire [1:0]		LED
	);

	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	wire clk_gen;
	
	wire usb_wr, usb_rd, usb_oe;
	
	wire [31:0] rx_data;
	wire rx_valid, rx_read;

	clock_generator_0 u_clock (
		.clk_27MHz(CLK_USER),
		.clk_gen(clk_gen)
	);
	
	data_check u_data_check(
		.rst(rst),
		.clk_in(clk_gen),
		.rx_valid(rx_valid),
		.rx_data(rx_data),
		.rx_read(rx_read),
		.evm_led(LED)
	);
	
	core_ft245 u_core_ft245(
		.rst(rst),
		.tx_clk(clk_gen),
		.tx_write(0), //in
		.tx_data(0), //in
		.tx_valid(), //out
		.rx_clk(clk_gen), 
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
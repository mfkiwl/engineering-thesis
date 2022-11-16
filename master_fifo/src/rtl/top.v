module top (
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
	
	wire clk_80MHz;
	wire [31:0] gen_data;
	wire gen_valid;
	
	wire full;
	
	clock_generator_0 u_clock (
		.clk_27MHz_in(CLK_USER),
		.clk_80MHz_out(clk_80MHz)
	);
	
	data_generator u_data_generator(
		.clk_in(clk_80MHz),
		.rst_in(rst),
		.trigger_in((!full)),
		.data_out(gen_data),
		.valid_out(gen_valid)
	);
	
	data_gateway u_data_gateway(
		.rst(rst),
		.tx_clk(clk_80MHz),
		.tx_valid(gen_valid), //in
		.tx_data(gen_data), //in
		.tx_ready(), //out
		.rx_clk(CLK_FTDI), 
		.rx_ready(0), //in
		.rx_valid(), //out
		.rx_data(), //out
		.usb_clk(CLK_FTDI),
		.usb_rxf(!RXF_N),
		.usb_txe(!TXE_N),
		.usb_wr(usb_wr),
		.usb_rd(usb_rd),
		.usb_oe(usb_oe),
		.usb_data(DATA),
		.usb_be(BE),
		.full(full)
	);
	
	assign WR_N = ~usb_wr;
	assign RD_N = ~usb_rd;
	assign OE_N = ~usb_oe;
	
endmodule
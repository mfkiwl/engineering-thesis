module data_gateway(
	input wire				rst,
	
	// master tx interface
	input  wire				tx_clk,
	input  wire				tx_valid,
	input  wire [31:0]	tx_data,
	output wire				tx_ready,
	
	// master rx interface
	input  wire				rx_clk,
	input  wire				rx_ready,
	output wire				rx_valid,
	output wire [31:0]	rx_data,
	
	// usb interface
	input  wire				usb_clk,
	input  wire				usb_rxf,
	input  wire				usb_txe,
	output wire				usb_wr,
	output wire				usb_rd,
	output wire				usb_oe,
	inout  wire [31:0]	usb_data,
	inout  wire	[3:0]		usb_be
	);
	
	wire rx_fifo_read, tx_fifo_prog_empty;
	wire [31:0] tx_fifo_data;
	
	wire rx_fifo_write, rx_fifo_prog_full;
	wire [31:0] rx_fifo_data;
	
	fifo_generator_0	u_fifo_tx(
		.rst(rst), 
		.wr_clk(tx_clk),  
		.rd_clk(usb_clk), 
		.din(tx_data),
		.wr_en(tx_valid), 
		.rd_en(tx_fifo_read), 
		.dout(tx_fifo_data), 
		.full(), 
		.empty(),
		.valid(tx_ready),
		.prog_empty(tx_fifo_prog_empty),
		.prog_full()
	);
	
	fifo_generator_0	u_fifo_rx(
		.rst(rst), 
		.wr_clk(usb_clk),  
		.rd_clk(rx_clk),
		.din(rx_fifo_data), 
		.wr_en(rx_fifo_write),  
		.rd_en(rx_ready), 
		.dout(rx_data), 
		.full(), 
		.empty(),
		.valid(rx_valid),
		.prog_empty(),
		.prog_full(rx_fifo_prog_full)
	);	
	
	ft245_controller u_ft245_controller(
		.rst(rst),
		.usb_clk(usb_clk),
		.usb_rxf(usb_rxf),
		.usb_txe(usb_txe),
		.usb_wr(usb_wr),
		.usb_rd(usb_rd),
		.usb_oe(usb_oe),
		.usb_data(usb_data),
		.usb_be(usb_be),
		.tx_fifo_prog_empty(tx_fifo_prog_empty),
		.tx_fifo_data(tx_fifo_data),
		.tx_fifo_read(tx_fifo_read),
		.rx_fifo_prog_full(rx_fifo_prog_full),
		.rx_fifo_data(rx_fifo_data),
		.rx_fifo_write(rx_fifo_write)
	);

endmodule
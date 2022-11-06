module data_gateway (
	// Input
	input  wire 			rst_in,
	input  wire 			wr_clk_in,
	input  wire 			rd_clk_in,
	input  wire 			txe_n_in,
	input  wire				rxf_n_in,
	// Output
	output wire				wr_n_out,
	output wire				rd_n_out,
	output wire				oe_n_out,
	// Inout
	inout wire [31:0] 	data_io,
	inout wire [3:0]		be_io
	);
	
	wire fifo_prog_empty, fifo_prog_full;
	wire [31:0] fifo_data, usb_data;
	wire [3:0] fifo_be, usb_be;
	wire fifo_read, fifo_write;
	wire fifo_valid;
	
	assign fifo_be = 4'hf;
	
	fifo_fsm u_fifo_fsm(
		// Input
		.clk_in(rd_clk_in),
		.rst_in(rst_in),
		.usb_txe_n_in(txe_n_in),
		.usb_rxf_n_in(rxf_n_in),
		.fifo_prog_empty_in(fifo_prog_empty),
		.fifo_prog_full_in(fifo_prog_full),
		.fifo_data_in(fifo_data),
		.fifo_be_in(fifo_be),
		// Output
		.fifo_read_out(fifo_read),
		.fifo_write_out(fifo_write),
		.usb_wr_n_out(wr_n_out),
		.usb_rd_n_out(rd_n_out),
		.usb_oe_n_out(oe_n_out), 
		.usb_data_out(usb_data),
		.usb_be_out(usb_be),
		// Inout
		.usb_data_io(data_io),
		.usb_be_io(be_io)
	);
	
	fifo_generator_0 u_fifo(
		.rst(rst_in), 
		.wr_clk(wr_clk_in),  
		.rd_clk(rd_clk_in), 
		.din(usb_data),
		.wr_en(fifo_write), 
		.rd_en(fifo_read), 
		.dout(fifo_data), 
		.full(), 
		.empty(), 
		.prog_empty(fifo_prog_empty),
		.prog_full(fifo_prog_full)
	);

endmodule
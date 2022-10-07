module data_gateway (
	// In
	input 	wire 			rst,
	input 	wire 			data_in_clk,
	input 	wire [31:0] data_in,
	input 	wire 			data_in_valid,
	input 	wire 			ftdi_clk,
	input 	wire 			ftdi_txe_n,
	//Out
	output 	wire [31:0] ftdi_data,
	output	wire [3:0]	ftdi_be,
	output	wire			ftdi_wr_n,
	output wire fifo_full
	);
	
	localparam	PACKET_SIZE 	= 	1024;
	
	wire fifo_valid;
	wire fifo_empty, fifo_empty_thresh;
	
	reg fifo_read;
	reg [10:0] fifo_data_ctr;
	
	assign ftdi_be 	= 	4'b1111;
	assign ftdi_wr_n	=	~fifo_valid;
	
	always @(posedge ftdi_clk)
		if(fifo_empty)
			fifo_data_ctr <= PACKET_SIZE;
		else
			if((~fifo_empty_thresh) &  (fifo_data_ctr == PACKET_SIZE) & (~ftdi_txe_n))
				fifo_data_ctr <= 0;
			else if((fifo_data_ctr != PACKET_SIZE) && (!ftdi_txe_n))
				fifo_data_ctr <= fifo_data_ctr + 1'b1;
				
	always @(posedge ftdi_clk) fifo_read <= (fifo_data_ctr != PACKET_SIZE);
	
	fifo_generator_0 u_fifo(
		.rst(rst), 
		.wr_clk(data_in_clk), 
		.rd_clk(ftdi_clk), 
		.din(data_in),
		.wr_en(data_in_valid), 
		.rd_en(fifo_read), 
		.dout(ftdi_data), 
		.full(fifo_full), 
		.empty(fifo_empty), 
		.valid(fifo_valid),
		.prog_empty(fifo_empty_thresh) 
	);

endmodule
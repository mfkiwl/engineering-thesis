module data_gateway (
	// Input
	input  wire 			rst_in,
	input  wire 			wr_clk_in,
	input  wire [31:0] 	data_in,
	input  wire 			valid_in,
	input  wire 			rd_clk_in,
	input  wire 			txe_n_in,
	// Output
	output wire [31:0]	data_out,
	output wire [3:0]		be_out,
	output wire				wr_n_out,
	output wire				trigger_out
	);
	
	localparam PACKET_SIZE = 1024;
	
	// fifo
	wire fifo_empty, fifo_valid, fifo_prog_full, fifo_prog_empty;
	
	reg fifo_read;
	reg [1:0] fifo_reset_ctr;
	reg [10:0] fifo_data_ctr;

	assign be_out = 4'hf;
	assign wr_n_out = !fifo_valid;
	assign trigger_out = !fifo_prog_full;
	
	always @(posedge rd_clk_in)
		if(rst_in || fifo_empty) begin
			fifo_data_ctr <= PACKET_SIZE;
			fifo_reset_ctr <= 0;
		end
		else
			if((!fifo_prog_empty) && (fifo_data_ctr == PACKET_SIZE) && (!txe_n_in)) begin
				fifo_reset_ctr <= fifo_reset_ctr + 1'b1;
				if(fifo_reset_ctr == 2)
					fifo_data_ctr <= 0;
			end
			else if(fifo_data_ctr != PACKET_SIZE) begin
					fifo_data_ctr <= fifo_data_ctr + 1'b1;
					fifo_reset_ctr <= 0;
			end
	
	always @(posedge rd_clk_in) fifo_read <= (fifo_data_ctr != PACKET_SIZE);
	
	fifo_generator_0 u_fifo(
		.rst(rst_in), 
		.wr_clk(wr_clk_in), 
		.rd_clk(rd_clk_in), 
		.din(data_in),
		.wr_en(valid_in), 
		.rd_en(fifo_read), 
		.dout(data_out), 
		.full(), 
		.empty(fifo_empty), 
		.valid(fifo_valid),
		.prog_full(fifo_prog_full),
		.prog_empty(fifo_prog_empty) 
	);

endmodule
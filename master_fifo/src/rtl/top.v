module top (
	// Input
	input  wire 			CLK_USER, //27MHz
	input  wire 			CLK_FTDI, //100MHz
	input  wire 			HRST_N,
	input  wire 			SRST_N,
	input  wire 			TXE_N,
	input	 wire				BUTTON,
	// Output
	inout  wire [31:0] 	DATA,
	inout  wire [3:0] 	BE,
	output wire 			WR_N,
	output wire				RD_N,
	output wire				OE_N
	);
	
	// In & Out ports
	wire [31:0] data;
	wire [3:0] be;
	wire txe_n, wr_n;

	// reset
	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	// data_generator
	wire [31:0] gen_data;
	wire gen_valid;
	
	// clock_generator
	wire clk_80MHz;
	
	// data_gateway
	
	
	clock_generator_0 u_clock (
		.clk_27MHz_in(CLK_USER),
		.clk_80MHz_out(clk_80MHz)
	);
	
	data_generator u_data_generator(
		.clk_in(clk_80MHz),
		.rst_in(rst),
		.trigger_in(BUTTON),
		.data_out(gen_data),
		.valid_out(gen_valid)
	);
	
	data_gateway u_data_gateway(
		.rst_in(rst),
		.wr_clk_in(clk_80MHz),
		.data_in(gen_data),
		.valid_in(gen_valid),
		.rd_clk_in(CLK_FTDI),
		.txe_n_in(txe_n),
		.data_out(data),
		.be_out(be),
		.wr_n_out(wr_n)
	);
	
	assign txe_n = TXE_N;
	assign DATA = data;
	assign BE = be;
	assign WR_N = wr_n;
	assign RD_N = 1'b1;
	assign OE_N = 1'b1;
	
endmodule
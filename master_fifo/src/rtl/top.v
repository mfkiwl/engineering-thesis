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

	// reset
	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	// data_generator
	wire [31:0] gen_data;
	wire gen_valid;
	
	// clock_generator
	wire clk_81MHz;
	
	clock_generator_0 u_clock (
		.CLK_IN1(CLK_USER),
		.CLK_OUT1(clk_81MHz)
	);
	
	data_generator u_data_generator(
		.clk_in(clk_81MHz),
		.rst_in(rst),
		.trigger_in(BUTTON),
		.data_out(gen_data),
		.valid_out(gen_valid)
	);
	
	data_gateway u_data_gateway(
		.rst_in(rst),
		.wr_clk_in(clk_81MHz),
		.data_in(gen_data),
		.valid_in(gen_valid),
		.rd_clk_in(CLK_FTDI),
		.txe_n_in(TXE_N),
		.data_out(DATA),
		.be_out(BE),
		.wr_n_out(WR_N)
	);
	
	assign RD_N = 1'b1;
	assign OE_N = 1'b1;
	
endmodule
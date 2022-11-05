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
	
	// In & Out ports
	wire [31:0] data;
	wire [3:0] be;
	wire clk_user, clk_ftdi; 
	wire txe_n, rxf_n;
	wire wr_n, rd_n, oe_n;

	// reset
	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	// clock_generator
	wire clk_80MHz;
	
	clock_generator_0 u_clock (
		.clk_27MHz_in(clk_user),
		.clk_80MHz_out(clk_80MHz)
	);
	
	data_gateway u_data_gateway(
		.rst_in(rst),
		.wr_clk_in(clk_80MHz),
		.rd_clk_in(clk_ftdi),
		.txe_n_in(txe_n),
		.rxf_n_in(rxf_n),
		.wr_n_out(wr_n),
		.rd_n_out(rd_n),
		.oe_n_out(oe_n),
		.data_io(data),
		.be_io(be)
	);
	
	// ports assignments
	assign clk_user = CLK_USER;
	assign clk_ftdi = CLK_FTDI;
	assign txe_n = TXE_N;
	assign rxf_n = RXF_N;
	assign DATA = data;
	assign BE = be;
	assign WR_N = wr_n;
	assign RD_N = rd_n;
	assign OE_N = oe_n;
	
endmodule
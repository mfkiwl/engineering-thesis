`timescale 1ns/1ns

module top_testbench;

	reg rst, CLK_FPGA, CLK_FTDI; 
	
	wire WR_N, TXE_N;
	wire [3:0] BE;
	wire [31:0] DATA;

	initial begin
		#50;
		rst = 1;
		#150;
		rst = 0;
		#10000000;
		$stop;
	end

	always begin // 10MHz
		CLK_FPGA = 0;
		#50;
		CLK_FPGA = 1;
		#50;
	end
	
	always begin // 100MHz
		CLK_FTDI = 0;
		#5;
		CLK_FTDI = 1;
		#5;
	end
	
	ft60x_stub u_ft60x_stub (
		.CLK_FTDI(CLK_FTDI),
		.rst(rst),
		.WR_N(WR_N),
		.TXE_N(TXE_N)	
	);

	top u_top (
		.CLK_FPGA(CLK_FPGA),
		.CLK_FTDI(CLK_FTDI),
		.HRST_N(rst),
		.SRST_N(rst),
		.TXE_N(TXE_N),
		.DATA(DATA),
		.BE(BE),
		.WR_N(WR_N),
		.RD_N(),
		.OE_N()
	);
	
endmodule

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
	
	localparam	IDLE	=	4'b0001,
					MTWR	=	4'b0010,
					MDLE	=	4'b0100,
					MTRD	=	4'b1000;
	
	localparam PACKET_SIZE = 1024;
	
	// In & Out ports
	wire [31:0] data;
	wire [3:0] be;
	wire clk_user, clk_ftdi; 
	wire txe_n, rxf_n;
	wire wr_n;
	reg rd_n, oe_n;

	// reset
	wire rst;
	assign rst = (HRST_N & SRST_N);
	
	// clock_generator
	wire clk_80MHz;
	
	// fifo
	wire [31:0] fifo_data;
	wire fifo_prog_empty, fifo_prog_full, fifo_empty, fifo_full;
	wire fifo_valid;
	
	// master_fsm
	reg [3:0] state;
	wire [31:0] usb_data;
	reg fifo_write, fifo_read;
	
	clock_generator_0 u_clock (
		.clk_27MHz_in(clk_user),
		.clk_80MHz_out(clk_80MHz)
	);
	
	// state machine
	always @(posedge clk_ftdi)
		if(rst)
			state <= IDLE;
		else
			case(state)
				IDLE:
					state <= ((!rxf_n) && (!fifo_full))? MTWR: MDLE;
				MTWR:
					state <= (rxf_n || fifo_full)? MDLE: MTWR;
				MDLE:
					state <= ((!txe_n) && (!fifo_empty))? MTRD: IDLE;
				MTRD:
					state <= (txe_n || fifo_empty)? IDLE: MTRD;
			endcase
	
	always @(posedge clk_ftdi)
		if((state == IDLE) || (rst)) begin
			fifo_write <= 0;
			fifo_read <= 0;
			rd_n <= 1'b1;
			oe_n <= 1'b1;
		end
		else if(state == MTWR) begin
			fifo_write <= ~oe_n;
			fifo_read <= 0;
			rd_n <= oe_n;
			oe_n <= 0;
		end
		else if(state == MDLE) begin
			fifo_write <= 0;
			fifo_read <= 0;
			rd_n <= 1'b1;
			oe_n <= 1'b1;
		end
		else if(state == MTRD) begin
			fifo_write <= 0;
			fifo_read <= 1'b1;
			rd_n <= 1'b1;
			oe_n <= 1'b1;
		end
	
	fifo_generator_0 u_fifo(
		.rst(rst), 
		.wr_clk(clk_ftdi),  
		.rd_clk(clk_ftdi), 
		.din(usb_data),
		.wr_en(fifo_write), 
		.rd_en(fifo_read), 
		.dout(fifo_data), 
		.full(fifo_full), 
		.empty(fifo_empty),
		.valid(fifo_valid),
		.prog_empty(fifo_prog_empty),
		.prog_full(fifo_prog_full)
	);
	
	//assignments for be and wr_n in MTRD mode
	assign be = (state == MTRD)? 4'hf: 4'bZ;
	assign wr_n = (state == MTRD)? !fifo_valid: 1'b1;
	
	// I&O ports assignments
	assign clk_user = CLK_USER;
	assign clk_ftdi = CLK_FTDI;
	assign txe_n = TXE_N;
	assign rxf_n = RXF_N;
	assign DATA = (state == MTRD)? fifo_data: 32'bZ;
	assign BE = (state == MTRD)? be: 4'bZ;
	assign usb_data = (state == MTWR)? DATA: 4'bZ;
	assign be = (state == MTWR)? BE: 4'bZ;
	assign WR_N = wr_n;
	assign RD_N = rd_n;
	assign OE_N = oe_n;
	
endmodule
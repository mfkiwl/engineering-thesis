module fifo_fsm (
	// Input
	input  wire 				clk_in,
	input  wire 				rst_in,
	input  wire					usb_txe_n_in,
	input  wire					usb_rxf_n_in,
	input  wire					fifo_prog_empty_in,
	input	 wire					fifo_prog_full_in,
	input  wire [31:0]		fifo_data_in,
	input  wire [3:0]			fifo_be_in,
	// Output
	output wire					fifo_read_out,
	output wire					fifo_write_out,
	output wire					usb_wr_n_out,
	output wire					usb_rd_n_out,
	output wire					usb_oe_n_out,
	output wire [31:0]		usb_data_out,
	output wire [31:0]		usb_be_out,
	// Inout
	inout  wire [31:0]		usb_data_io,
	inout  wire [3:0]       usb_be_io
	);
	
	localparam		IDLE		=	4'b0001,
						MST_RD	=	4'b0010,
						MIDDLE	=	4'b0100,
						MST_WR	=	4'b1000;
	
	localparam		PACKET_SIZE = 1024;
	
	reg [3:0] state, next_state;
	reg [10:0] fifo_data_ctr;
	reg [1:0] fsm_debounce_ctr;
	
	reg fifo_read, fifo_write; // fifo control
	reg usb_wr_n, usb_rd_n, usb_oe_n;
	reg [31:0] usb_data;
	reg [3:0] usb_be;
	
	// state machine logic
	always @(posedge clk_in)
		if(rst_in)
			state <= IDLE;
		else
			case(state)
				IDLE:
					if((!fifo_prog_full_in) && (!usb_rxf_n_in)) begin
						fsm_debounce_ctr <= fsm_debounce_ctr + 1'b1;
						if(fsm_debounce_ctr == 2)
							state <= MST_RD;
						else
							state <= IDLE;
					end
					else begin
						state <= MIDDLE;
						fsm_debounce_ctr <= 0;
					end
				MST_RD:
					if(fifo_data_ctr == PACKET_SIZE)
						state <= MIDDLE;
					else
						state <= MST_RD;
				MIDDLE:
					if((!fifo_prog_empty_in) && (!usb_txe_n_in)) begin
						fsm_debounce_ctr <= fsm_debounce_ctr + 1'b1;
						if(fsm_debounce_ctr == 2)
							state <= MST_WR;
						else
							state <= MIDDLE;
					end
					else begin
						state <= IDLE;
						fsm_debounce_ctr <= 0;
					end
				MST_WR:
					if(fifo_data_ctr == PACKET_SIZE)
						state <= IDLE;
					else
						state <= MST_WR;
			endcase
	
	// output logic
	always @(posedge clk_in)
		case(state)
			IDLE: begin
				fifo_read <= 0;
				fifo_write <= 0;
				usb_wr_n <= 1'b1;
				usb_rd_n <= 1'b1;
				usb_oe_n <= 1'b1;
			end
			MST_RD: begin
				fifo_read <= 0;
				fifo_write <= 1'b1;
				usb_wr_n <= 1'b1;
				usb_rd_n <= 0;
				usb_oe_n <= 0;
			end
			MIDDLE: begin
				fifo_read <= 0;
				fifo_write <= 0;
				usb_wr_n <= 1'b1;
				usb_rd_n <= 1'b1;
				usb_oe_n <= 1'b1;
			end
			MST_WR: begin
				fifo_read <= 1'b1;
				fifo_write <= 0;
				usb_wr_n <= 0;
				usb_rd_n <= 1'b1;
				usb_oe_n <= 1'b1;
			end
		endcase
	
	// data counter logic
	always @(posedge clk_in)
		if(((state == MST_RD) || (state == MST_WR)) && (fifo_data_ctr != PACKET_SIZE))
			fifo_data_ctr <= fifo_data_ctr + 1'b1;
		else if((state == IDLE) || (state == MIDDLE))
			fifo_data_ctr <= 0;
			
			
	assign fifo_read_out = fifo_read;
	assign fifo_write_out = fifo_write;
	assign usb_wr_n_out = usb_wr_n;
	assign usb_rd_n_out = usb_rd_n;
	assign usb_oe_n_out = usb_oe_n;
	assign usb_data_io = (state == MST_WR)? fifo_data_in: 32'bZ;
	assign usb_be_io = (state == MST_WR)? fifo_be_in: 4'bZ;
	assign usb_data_out = (state == MST_RD)? usb_data_io: 32'bZ;
	assign usb_be_out = (state == MST_RD)? usb_be_io: 4'bZ;
endmodule
module ft245_controller(
	input wire		rst,
	
	// usb interface
	input  wire				usb_clk,
	input  wire				usb_rxf,
	input  wire				usb_txe,
	output wire				usb_wr,
	output wire				usb_rd,
	output wire				usb_oe,
	inout	 wire [31:0]	usb_data,
	inout  wire [3:0]		usb_be,
	
	// master tx interface
	input  wire				tx_fifo_prog_empty,
	input	 wire [31:0]	tx_fifo_data,
	output wire				tx_fifo_read,
	
	// master rx interface
	input  wire				rx_fifo_prog_full,
	output wire [31:0]	rx_fifo_data,
	output wire				rx_fifo_write
	);
	
	localparam	IDLE			=	6'b000001,
					MST_READ		=	6'b000100,
					MIDDLE_ST1	=	6'b001000,
					MIDDLE_ST2	=	6'b010000,
					MIDDLE_ST3  =  6'b110000,
					MIDDLE_ST4  =  6'b111000,
					MST_WRITE	=	6'b100000;
					
	localparam PACKET_SIZE = 1024;
	
	reg [10:0] burst_data_ctr;
	
	reg [5:0] state;
	reg usb_wr_reg, usb_rd_reg, usb_oe_reg;
	reg tx_fifo_read_reg;
	reg rx_fifo_write_reg;
	
	// state machine
	always @(posedge usb_clk)
		if(rst)
			state <= IDLE;
		else
			case(state)
				IDLE:
					state <= (usb_rxf && (!rx_fifo_prog_full))? MST_READ: MIDDLE_ST1;
				MST_READ:
					state <= ((!usb_rxf) || rx_fifo_prog_full)? MIDDLE_ST1: MST_READ;
				MIDDLE_ST1:
					state <= (usb_txe && (!tx_fifo_prog_empty))? MIDDLE_ST2: IDLE;
				MIDDLE_ST2: 
					state <= (usb_txe && (!tx_fifo_prog_empty))? MST_WRITE: IDLE;
				MST_WRITE:
					state <= (burst_data_ctr == PACKET_SIZE)? IDLE: MST_WRITE;
			endcase
	
	// usb signals logic
	always @(posedge usb_clk)
		if(state == MST_READ) begin
			rx_fifo_write_reg <= usb_oe;
			tx_fifo_read_reg <= 0;
			usb_rd_reg <= usb_oe;
			usb_oe_reg <= 1'b1;
			usb_wr_reg <= 0;
		end
		else if(state == MST_WRITE) begin
			rx_fifo_write_reg <= 0;
			tx_fifo_read_reg <= (burst_data_ctr != PACKET_SIZE);
			usb_rd_reg <= 0;
			usb_oe_reg <= 0;
			usb_wr_reg <= (burst_data_ctr != PACKET_SIZE);
		end
		else begin
			rx_fifo_write_reg <= 0;
			tx_fifo_read_reg <= 0;
			usb_rd_reg <= 0;
			usb_oe_reg <= 0;
			usb_wr_reg <= 0;
		end
	
	// data counter logic
	always @(posedge usb_clk)
		if((state == MST_WRITE))
			burst_data_ctr <= (burst_data_ctr != PACKET_SIZE)? burst_data_ctr + 1'b1: burst_data_ctr;
		else
			burst_data_ctr <= 0;
		
	assign usb_data = (state == MST_WRITE)? tx_fifo_data: 32'bZ;
	assign usb_be = (state == MST_WRITE)? 4'b1111: 4'bZ;
	assign rx_fifo_data = (state == MST_READ)? usb_data: 32'bZ;
	
	assign usb_wr = usb_wr_reg;
	assign usb_rd = usb_rd_reg;
	assign usb_oe = usb_oe_reg;
	assign tx_fifo_read = tx_fifo_read_reg;
	assign rx_fifo_write = rx_fifo_write_reg;
	
endmodule
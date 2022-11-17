module data_gateway(
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
	
	localparam	IDLE			=	4'b0001,
					MST_READ		=	4'b0010,
					MIDDLE		=	4'b0100,
					MST_WRITE	=	4'b1000;
					
	localparam 	PACKET_SIZE_TX = 1024,
					PACKET_SIZE_RX	= 128;
	
	reg [10:0] burst_data_ctr;
	
	reg [3:0] state;
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
					state <= (usb_rxf && (!rx_fifo_prog_full))? MST_READ: MIDDLE;
				MST_READ:
					state <= (burst_data_ctr == PACKET_SIZE_RX)? MIDDLE: MST_READ;
				MIDDLE:
					state <= (usb_txe && (!tx_fifo_prog_empty))? MST_WRITE: IDLE;
				MST_WRITE:
					state <= (burst_data_ctr == PACKET_SIZE_TX)? IDLE: MST_WRITE;
			endcase
	
	// usb signals logic
	always @(posedge usb_clk)
		if(state == IDLE) begin
			rx_fifo_write_reg <= 0;
			tx_fifo_read_reg <= 0;
			usb_rd_reg <= 0;
			usb_oe_reg <= (usb_rxf && (!rx_fifo_prog_full));
			usb_wr_reg <= 0;
			burst_data_ctr <= 0;
		end
		else if(state == MST_READ) begin
			rx_fifo_write_reg <= (burst_data_ctr != PACKET_SIZE_RX);
			tx_fifo_read_reg <= 0;
			usb_rd_reg <= 1'b1;
			usb_oe_reg <= 1'b1;
			usb_wr_reg <= 0;
			burst_data_ctr <= (burst_data_ctr != PACKET_SIZE_RX)? burst_data_ctr + 1'b1: burst_data_ctr;
		end
		else if(state == MIDDLE) begin
			rx_fifo_write_reg <= 0;
			tx_fifo_read_reg <= 0;
			usb_rd_reg <= 0;
			usb_oe_reg <= 0;
			usb_wr_reg <= 0;
			burst_data_ctr <= 0;
		end
		else if(state == MST_WRITE) begin
			rx_fifo_write_reg <= 0;
			tx_fifo_read_reg <= (burst_data_ctr != PACKET_SIZE_TX);
			usb_rd_reg <= 0;
			usb_oe_reg <= 0;
			usb_wr_reg <= tx_fifo_read_reg;
			burst_data_ctr <= (burst_data_ctr != PACKET_SIZE_TX)? burst_data_ctr + 1'b1: burst_data_ctr;
		end
		
	assign usb_data = (state == MST_WRITE)? tx_fifo_data: 32'bZ;
	assign usb_be = (state == MST_WRITE)? 4'b1111: 4'bZ;
	assign rx_fifo_data = (state == MST_READ)? usb_data: 32'bZ;
	
	assign usb_wr = usb_wr_reg;
	assign usb_rd = usb_rd_reg;
	assign usb_oe = usb_oe_reg;
	assign tx_fifo_read = tx_fifo_read_reg;
	assign rx_fifo_write = rx_fifo_write_reg;
	
endmodule
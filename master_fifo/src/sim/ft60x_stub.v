module ft60x_stub (
	// In
	input		wire		CLK_FTDI,
	input 	wire		rst,
	input 	wire 		WR_N,
	// Out
	output 	wire 		TXE_N
	);
	
	localparam 	FTDI_FIFO_SIZE 			= 	4096,
					FTDI_USB_READ_CYCLES 	= 	1000;	
	
	reg [12:0] data_ctr, read_cycles_ctr;
	
	always @(posedge CLK_FTDI) 
		if(rst) begin
			data_ctr <= FTDI_FIFO_SIZE;
			read_cycles_ctr <= FTDI_USB_READ_CYCLES;
		end
		else begin
			if((!WR_N) && (data_ctr != FTDI_FIFO_SIZE))
				data_ctr <= data_ctr + 1;
				
			else if((data_ctr == FTDI_FIFO_SIZE) && (read_cycles_ctr != FTDI_USB_READ_CYCLES))
				read_cycles_ctr <= read_cycles_ctr + 1;
				
			else if(read_cycles_ctr == FTDI_USB_READ_CYCLES) begin
				data_ctr <= 0;
				read_cycles_ctr <= 0;
			end
			
		end
	
	assign TXE_N = (data_ctr == FTDI_FIFO_SIZE)? 1: 0;
	
endmodule
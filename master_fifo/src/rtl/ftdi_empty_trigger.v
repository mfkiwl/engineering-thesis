module ftdi_empty_trigger(
	// In
	input 	wire 				clk,
	input		wire				rst,
	input 	wire 				txe_n,
	// Out
	output	wire				ftdi_empty_trigger
	);
	
	localparam PACKET_SIZE = 4096;
	
	reg [15:0] empty_cycles_ctr;
	
	always @(posedge clk)
		if(rst)
			empty_cycles_ctr <= 0;
		else
			if(txe_n)
				empty_cycles_ctr <= 0;
			else if((!txe_n) && (empty_cycles_ctr != PACKET_SIZE)) //1024 cycles of txe_n to clear ftdi buffer
				empty_cycles_ctr <= empty_cycles_ctr + 1'b1;
	
	assign ftdi_empty_trigger = ((!txe_n) && (empty_cycles_ctr == PACKET_SIZE))? 1'b0: 1'b1;	
	
endmodule
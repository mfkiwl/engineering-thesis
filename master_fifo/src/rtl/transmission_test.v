module transmission_test(
	// Input
	input  wire 				clk_in,
	input  wire 				rst_in,
	input	 wire					trigger,
	// Output
	output wire [31:0]		tx_data,
	output wire 				tx_write
	);

	localparam WORDS_TO_GEN = 1024;
	
	reg [31:0] data;
	reg valid;
	reg trigger_prev, trigger_tick;
	reg [31:0] data_ctr;
	
	assign tx_data = data;
	assign tx_write = valid;
	
	always @(posedge clk_in)
		if(rst_in) begin
			trigger_prev <= 0;
			trigger_tick <= 0;
		end
		else begin
			trigger_prev <= trigger;
			if((trigger == 1'b1) && (trigger_prev == 0))
				trigger_tick <= 1'b1;
			else
				trigger_tick <= 1'b0;
		end
		
	always @(posedge clk_in)
		if(rst_in)
			data_ctr <= WORDS_TO_GEN;
		else
			if(trigger_tick)
				data_ctr <= 0;
			else if(data_ctr != WORDS_TO_GEN)
				data_ctr <= data_ctr + 1'b1;
					
	always @(posedge clk_in)
		if(rst_in) begin
			data <= 32'hffffffff;
			valid <= 1'b0;
		end
		else
			if(data_ctr != WORDS_TO_GEN) begin
				data <= (data != 32'hffffffff)? data + 1'b1: 0;
				valid <= 1'b1;
			end
			else begin
				data <= data;
				valid <= 1'b0;
			end
			
endmodule
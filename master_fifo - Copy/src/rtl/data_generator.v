module data_generator (
	// Input
	input  wire 				clk_in,
	input  wire 				rst_in,
	input	 wire					trigger_in,
	// Output
	output wire [31:0]		data_out,
	output wire 				valid_out
	);

	localparam DATA_AMOUNT = 4096;
	
	reg [31:0] data;
	reg valid;
	reg trigger_prev, trigger_tick;
	reg [31:0] data_ctr;
	
	assign data_out = data;
	assign valid_out = valid;
	
	always @(posedge clk_in)
		if(rst_in) begin
			trigger_prev <= 0;
			trigger_tick <= 0;
		end
		else begin
			trigger_prev <= trigger_in;
			if((trigger_in == 1'b1) && (trigger_prev == 0))
				trigger_tick <= 1'b1;
			else
				trigger_tick <= 1'b0;
		end
		
	always @(posedge clk_in)
		if(rst_in)
			data_ctr <= DATA_AMOUNT;
		else
			if(trigger_tick)
				data_ctr <= 0;
			else if(data_ctr != DATA_AMOUNT)
				data_ctr <= data_ctr + 1'b1;
					
	always @(posedge clk_in)
		if(rst_in) begin
			data <= 32'hffffffff;
			valid <= 1'b0;
		end
		else
			if(data_ctr != DATA_AMOUNT) begin
				data <= (data != 32'hffffffff)? data + 1'b1: 0;
				valid <= 1'b1;
			end
			else begin
				data <= data;
				valid <= 1'b0;
			end
			
endmodule
module data_generator (
	// Input
	input  wire 				clk_in,
	input  wire 				rst_in,
	input	 wire					trigger_in,
	// Output
	output wire [31:0]		data_out,
	output wire 				valid_out
	);	
	
	reg [31:0] data;
	reg valid;
	
	assign data_out = data;
	assign valid_out = valid;
		
	always @(posedge clk_in)
		if(rst_in) begin
			data <= 32'hffffffff;
			valid <= 1'b0;
		end
		else
			if(trigger_in) begin
				data <= (data != 32'hffffffff)? data + 1'b1: 0;
				valid <= 1'b1;
			end
			else begin
				data <= data;
				valid <= 1'b0;
			end
			
endmodule
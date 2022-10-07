module data_generator (
	// In
	input 	wire 				clk,
	input 	wire 				rst,
	input wire gen,
	// Out
	output 	wire [31:0]		ge_data,
	output 	wire 				ge_valid
	);
	
	reg [31:0] ge_data_reg;
	reg ge_valid_reg;
	
	assign ge_data = ge_data_reg;
	assign ge_valid = ge_valid_reg;
		
	always @(posedge clk)
		if(rst) begin
			ge_data_reg <= 32'hffffffff;
			ge_valid_reg<= 1'b0;
		end
		else 
			if(gen) begin
				ge_data_reg <= (ge_data_reg != 32'hffffffff)? ge_data_reg + 1'b1: 0;
				ge_valid_reg <= 1'b1;
			end
			else begin
				ge_data_reg <= ge_data_reg;
				ge_valid_reg <= 1'b0;
			end
	
endmodule
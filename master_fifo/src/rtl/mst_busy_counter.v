module mst_busy_counter(
	input wire clk,
	input wire rst,
	input wire busy_txe_n_i,
	output wire [31:0] busy_counter_o
	);
	
	//external registers
	reg [31:0] busy_counter_o_reg;
	
	//internal registers
	reg reset_counter;
	
	always @(posedge clk)
		if(rst) begin
			busy_counter_o_reg <= 0;
			reset_counter <= 0;
		end
		else
			if(busy_txe_n_i) begin
				reset_counter <= 0;
				if(reset_counter)
					busy_counter_o_reg <= 1;
				else
					busy_counter_o_reg <= (busy_counter_o_reg != 32'hffffffff)? busy_counter_o_reg + 1: busy_counter_o_reg;
			end
			else begin
				busy_counter_o_reg <= busy_counter_o_reg;
				reset_counter <= 1;
			end
	
	assign busy_counter_o = busy_counter_o_reg;
endmodule
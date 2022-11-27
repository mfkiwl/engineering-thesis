module data_check(
	input  wire 			rst,
	input  wire 			clk_in,
	input  wire				rx_valid,
	input  wire	[31:0]	rx_data,
	output wire				rx_read,
	output wire	[1:0]		evm_led
	);
	
	localparam WORDS_TO_CMP = 1024;
	
	reg [31:0] data_to_cmp;
	reg rx_read_reg;
	
	reg cmp_failed;
	
	//reg [31:0] test_val;
	
	always @(posedge clk_in)
		if(rst) begin
			data_to_cmp <= 0;
			cmp_failed <= 0;
			rx_read_reg <= 0;
			//test_val <= 0;
		end
		else begin
			rx_read_reg <= 1'b1;
			if((rx_valid) && (data_to_cmp != WORDS_TO_CMP)) begin
				data_to_cmp <=	data_to_cmp + 1'b1; 
				cmp_failed 	<= (data_to_cmp != rx_data)? 1'b1: cmp_failed;
				//test_val <= rx_data;
			end
		end

	assign evm_led[0] = (data_to_cmp == WORDS_TO_CMP);
	assign evm_led[1] = ((data_to_cmp == WORDS_TO_CMP) && (!cmp_failed));
	assign rx_read = rx_read_reg;
	//assign evm_led[1] = (test_val == WORDS_TO_CMP-1);
endmodule
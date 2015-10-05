module shift_register (vect_out, vect_in, start_in, clk_in, rst_in);
	input [7:0] vect_in;
	input start_in;
	input clk_in;
	input rst_in;	
	output [7:0] vect_out;
	
	wire [7:0] vect_in;
	wire start_in;
	wire clk_in;
	wire rst_in;
	reg [7:0] vect_out;
	
	reg [7:0] vect_internal;
	
	initial begin
		vect_out <= 7'b00000000;
		vect_internal <= 7'b00000000;
	end
	always @ (posedge clk_in)
	begin : main_function
		if (rst_in == 1'b1)
			vect_internal <= 7'b00000000;
		else if (start_in == 1'b1)
			vect_internal <= vect_in;
		else begin
			vect_out <= vect_internal;
			vect_internal <= vect_internal << 1;
		end		
		
	end 
	
endmodule 
	
	
//include "shift_register.v"

module tb_shift_register();	
	reg [7:0] vect_in;
	reg start_in;
	reg clk_in;
	reg rst_in;
	wire [7:0] vect_out;
	
initial begin
	$display ("testing starts here");
	#5 clk_in = 1;
	#15 rst_in = 0;
	#10 vect_in = 7'b00000001;
	#10 start_in = 1;
	#10 start_in = 0;
	#10 vect_in = 7'b00000000; 
	#100 $finish;
end 

always begin
	#5 clk_in = ~clk_in;
end 

shift_register sr_inst (
vect_out,
vect_in,
start_in,
clk_in,
rst_in
);

endmodule
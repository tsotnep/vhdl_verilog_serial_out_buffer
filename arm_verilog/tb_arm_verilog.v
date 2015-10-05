`timescale 1ns/1ps
module tb_shift_register();	
	wire OutD;
	wire OutC;
	reg [6:0] A;
	reg [7:0] D;
	reg Go;
	reg clk_in;
	reg reset_n;	
	
initial begin
	$display ("testing starts here");
	Go = 0;
	#5 clk_in = 1;
	#15 reset_n = 0;
	#10 D = 8'b11111111; A = 7'b1111111;
	#10 Go = 1;
	#10 Go = 0;
	#10 D = 7'b00000000; A = 7'b0000000;
	#100 $finish;
end 

always begin
	#5 clk_in = ~clk_in;
end 

arm_verilog armv_inst (OutD, OutC, D, A, Go, clk_in, reset_n);
	

endmodule
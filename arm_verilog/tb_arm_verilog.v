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

//reset	
	reset_n = 0; Go = 0; clk_in = 1; D = 7'b00000000; A = 7'b0000000;  
	#10 reset_n = 1;
	
$display ("test pattern N1");
//test pattern N1
	#10 D = 8'b11111111; A = 7'b1111111;	Go = 1;
	#10 D = 7'b00000000; A = 7'b0000000;	Go = 0;
	#(30*10)
	
//$display ("test pattern N2");	
////test pattern N2
//	#10 D = 8'b10011111; A = 7'b1000001;	Go = 1;
//	#10 D = 7'b00000000; A = 7'b0000000;	Go = 0;
//	#(30*10)
	
	#100 $finish;
end 

//clock driver
	always
	begin 
		#5 clk_in = ~clk_in;
	end 

//instantiation of uut
	arm_verilog armv_inst (OutD, OutC, D, A, Go, clk_in, reset_n);
endmodule
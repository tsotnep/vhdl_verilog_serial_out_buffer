`timescale 1ns/1ps
module tb_arm_verilog();	
	wire OutD;
	wire OutC;
	reg [6:0] A;
	reg [7:0] D;
	reg Go;
	reg clk_in;
	reg reset_n;	
	
//clock driver
	always
		#5 clk_in = ~clk_in;
//displaying output
	always
		#10 $display ("Time = %d, outputs:  OutC = %d OutD = %d",$time,OutC,OutD);
		
initial begin
//$monitor ("Time = %d outputs:  OutC = %d OutD = %d",$time,OutC,OutD);

//reset	
	$display ("to make things simple: when OutC = 0 then output should be valid. it should start and end with 0, after A & D it should output 'Z' ");
	reset_n = 0; Go = 0; clk_in = 1; D = 8'b00000000; A = 7'b0000000;  
	#10 reset_n = 1;
	

//test pattern N1
	#10 A = 7'b1111111;	D = 8'b11111111; 	Go = 1;
	#10 A = 7'b0000000;	D = 8'b00000000; 	Go = 0;
	$display ("Time: %d, outputs:  test pattern N1: A = 7'b1111111 D = 8'b11111111", $time);
	#(20*10)
	

////test pattern N2
//	#10 A = 7'b1000001;	D = 8'b10011111; 	Go = 1;
//	#10 A = 7'b0000000;	D = 8'b00000000; 	Go = 0;
//	$display ("Time: %d, outputs:  test pattern N2: A = 7'b1000001 D = 8'b10011111", $time);
//	#(20*10)
	
	$display ("Time: %d, outputs:  end of test patterns: A = 7''b0000000 D = 8''b00000000", $time);		
	#100 $finish;
end 


		
//instantiation of uut
	arm_verilog armv_inst (OutD, OutC, D, A, Go, clk_in, reset_n);
endmodule
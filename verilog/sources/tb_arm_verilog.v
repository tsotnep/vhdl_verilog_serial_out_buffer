//-------------- Copyright (c) Notice -----------------------------------------
//
// The VHDL/Verilog code, the logic and concepts described OUT this file constitute
// the intellectual property of the authors listed below, who is/are affiliated
// to TUT (Tallinn University of Technology), School of ICT, Tallinn.
// Any unauthorised use, copy or distribution is strictly prohibited.
// Any authorised use, copy or distribution should carry this copyright notice
// unaltered.
// Authors: Tsotne Putkaradze, MSc student, Tallinn University of Technology, Tallinn, Estonia.
//			Balaji Venu, Sr. Engineer, ARM Research, Cambridge, UK.
// Contact: tsotnep@gmail.com
// Date: 6 October, 2015.
//
// Code Description:
//		the purpose of this code below is to stimlate inputs for unit: arm_verilog, in the current versions three tests are given, 
//		the reason we don't test this unit exhaustively is following:
//		according to the logic, unit: arm_logic simply takes inputs, and outputs them unmodifyed, except, adding four bits of information:
//		two 'Z' - bits meaning - high impedance, two '0' - starting and ending bits.
//
//		in the module we are printing output on screen with command: "always #10 $display <values&comments>", this prints out values every 10ns, from 10th ns.
//		for better observation on outputs (for signal: OutC), you can change the value of #10 into #5.
//
// 		I also implemented Receiver, that gathers outputted data and reconstructs the original vector, after that we do 'assert-like' checking
//		If Received data matches inputted data, we print that everything is OK
//
// Tools used set 1 non-free:
// Coding:		Sigasi linux 64bit - Floating Licence (TTU)
// Synthesis: 	Vivado Synthesis - Vivado 2015.2 linux 64bit - Floating Licence (TUT)
// Simulation: 	Vivado Simulator - Vivado 2015.2 linux 64bit - Floating Licence (TUT)
//
// Tools used set 2 open-source:
// Simulation:	Icarus Verilog on linux http://iverilog.icarus.com/
// Simulation:  Icarus Verilog online simulator - iverilog.com 

`timescale 1ns/1ps
module tb_arm_verilog();
//Declaration of I/O of arm_verilog
	wire OutD;
	wire OutC;
	reg [6:0] A;
	reg [7:0] D;
	reg Go;
	reg clk_in;
	reg reset_n;	
//Declaration of signals for checking the correctness of module arm_verilog
	reg [6:0] receivedA;
	reg [7:0] receivedD;
	reg zA;
	reg zD;
	reg [7:0] recTemp; //this should act as input buffer, so it should have the size of biggest input

//instantiation of uut
	arm_verilog armv_inst (OutD, OutC, D, A, Go, clk_in, reset_n);
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////PROCESSES/////////////////////////////////////////////////////////////////
//clock driver
	always	#5 clk_in = ~clk_in;

//displaying: simulation time, OutC, OutD on every 10ns
	always	#10 $display ("Time = %d, outputs:  OutC = %d OutD = %d",$time,OutC,OutD); //to observe OutC change #10 into #5

//receive generated output from main unit: arm_verilog, and 
//write them into registers called: receivedA, receivedD, which is then used for comparison
	always @(posedge OutC or posedge Go or negedge reset_n)
	begin
		if (reset_n == 1'b0 || Go == 1'b1) begin
			zA <= 1'b0;
			zD <= 1'b0;
			recTemp <= {8{1'b0}};
			receivedA <= {7{1'b0}};
			receivedD <= {8{1'b0}};
		end else if (OutD !== 1'bZ && zD == 1'b0) begin
			recTemp <= {recTemp[7-1:0], OutD};
		end else begin
			if (zA == 1'b0) begin
				zA <= 1'b1;
				receivedA <= recTemp[7:0];
			end else if (zD == 1'b0) begin
				zD <= 1'b1;
				receivedD <= recTemp;
				recTemp <= {8{1'b0}};
			end
		end
	end 

//stimulus for unit under test
initial begin
//reset tester signals
	zA <= 1'b0;
	zD <= 1'b0;
	recTemp <= {8{1'b0}};
	receivedA <= {7{1'b0}};
	receivedD <= {8{1'b0}};
	
//reset	Inputs of UUT
	$display ("to make things simple: when OutC = 0 then output should be valid. it should start and end with 0, after A & D it should output 'Z' ");
	reset_n = 0; Go = 0; clk_in = 1; D = 8'b00000000; A = 7'b0000000;  
	#10 reset_n = 1;

////test pattern N1
//	#10 A = 7'b1111111;	D = 8'b11111111; 	Go = 1;
//	#10 	Go = 0;
//	$display ("Time: %d, outputs:  START test pattern N1: A = 7'b1111111 D = 8'b11111111", $time);
//	#(25*10) //simply wait long enough
//	#1 if ((receivedA == A) && (receivedD ==D)) $display ("OUTPUT DO MATCH WITH INPUT, Test 1");
//    #10
    
////test pattern N2
//	#10 A = 7'b1000001;	D = 8'b10011111; 	Go = 1;
//	#10 	Go = 0;
//	$display ("Time: %d, outputs:  START test pattern N2: A = 7'b1000001 D = 8'b10011111", $time);
//	#(25*10) //simply wait long enough
//	#1 if ((receivedA == A) && (receivedD ==D)) $display ("OUTPUT DO MATCH WITH INPUT, Test 2");
//	#100 $finish;
	
	
//test pattern N3
	#10 A = 7'b1000001;		D = 8'b10000001;		Go = 1;
	#10		Go = 0;
	$display ("Time: %d, outputs:  START test pattern N1: A = 7'b1000001 D = 8'b10000001", $time);
	#(25*10) //simply wait long enough
	if ((receivedA == A) && (receivedD ==D)) $display ("OUTPUT DO MATCH WITH INPUT (A = 7'b1000001; D = 8'b10000001)");
	#10
	#100 $finish;
end 

endmodule

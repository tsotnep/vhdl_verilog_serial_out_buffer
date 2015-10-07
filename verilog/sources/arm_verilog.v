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
//		This code is "parallel in serial out" buffer, where it takes two inputs "A" and "D" and outputs them bit-by-bit(1 bit at a time) when:
//		"Go" input signal is set to '1' as a pulse (. . . , 0, 1, 0, . . .). firs "A" then "D". starts from Left bit, goes to Right.
//		after pulsing the "Go" signal inputs registered/saved.
//		to interrupt the transmission, can only be done by setting "Reset_n" to '0' or pulsing the "Go" signal and giving new input data. 
//		during transmission of data, code sends out clock as well. 
//		so, receiver can use this clock to read the sent data, even though if receiver is on different clock domain.
//		if data is not being sent program is 'idle', clock output "OutC" and data output "OutD" are set to constant '1'
//		
// Code Details:
//		after finishing sending each input, code sends out 'Z'(signal name: "zPause") high impedance signal, notifying that one input is sent.  
//		BEFORE sending first input AND AFTER sending second input (with it's "Z" signal), 
//		output "OutD" gets the value of '0' (signal name: "header")
//		everything is parameterizable: "header", "zPause", input size.
//
// Solution Details:
//		to satisfy the requirements of the task, two solutions are used. 
//		solution A: by using shift registers 	to select THE BIT by constructing the concatenated-vector, shifting it, and pointing always to LM/RM bit.
//		solution B: by using counter, 			to select THE BIT by pointing to it with counter value
//		I used solution A.
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
module arm_verilog (
	OutD,		//output OutD, this one bit serial output gives out data: A and then B. transmission starts and ends with '0', after each part: A,B, it gives out 'Z' signal for 1 clock cycle 
	OutC, 		//output OutC, it's output clock, that is probably used by receiver (which is probably in different domain) to clock this output of this system in right frequency, so that it will get correct data
	D, 			//input D, 8 bits, [MSB:LSB]
	A, 			//input A, 7 bits, [MSB:LSB]
	Go, 		//when go makes positive pulse, we save inputs and start to output them on next clock cycle
	clk_in, 	//clock input
	reset_n		//when reset_n = 0 we reset everything. 
); 
//parameters-generics
	parameter sizeA = 7;
	parameter sizeD = 8;
	parameter sizeZpause = 1;
    parameter sizeHeader = 1;
    parameter sizeConcatenatedInputs = sizeHeader + sizeA + sizeZpause + sizeD + sizeZpause + sizeHeader;
	parameter [sizeHeader-1:0] header ={sizeHeader{1'b0}};
    parameter [sizeZpause-1:0] zPause ={sizeZpause{1'bZ}};
    parameter constAllBitOnes = {sizeConcatenatedInputs{1'b1}};
//I/O
	output OutD;
	output OutC;
	input [sizeA-1:0] A;
	input [sizeD-1:0] D;
	input Go;
	input clk_in;
	input reset_n;	
	
//I/O types
	reg OutD;
	reg OutC;
	wire [sizeA-1:0] A;
	wire [sizeD-1:0] D;
	wire Go;
	wire clk_in;
	wire reset_n;
	
//internal signals
	reg [sizeConcatenatedInputs-1:0] concatenatedInputs; //when Go signal arrives, this vector gets-saves '0'+A+'Z'+D+'Z'+'0' 
	reg enable_OutC; //this is used to control OutC output
	
//initial values, resetted
	initial begin
		OutD <= 1'b1;
		OutC <= 1'b1;
		enable_OutC <= 1'b0;
		concatenatedInputs <= {sizeConcatenatedInputs{1'b1}};
	end
	
//assigning, shifting and outputting concatenated vector of inputs
	always @ (posedge clk_in or negedge reset_n)
	begin : main_function
		if (reset_n == 1'b0) begin
			concatenatedInputs <= {sizeConcatenatedInputs{1'b1}};
			OutD <= 1'b1;
		end 
		else if (Go == 1'b1) begin
			concatenatedInputs <= {header, A, zPause, D, zPause, header};
		end 
		else begin
			concatenatedInputs <= {concatenatedInputs[sizeConcatenatedInputs-2:0], 1'b1};
			OutD <= concatenatedInputs[18];			
		end
	end
	
//setting enable signal which controls when OutC will be active.
	always @ (posedge clk_in or negedge reset_n)
	begin : enabling_output_c
		if (reset_n == 1'b0) begin
			enable_OutC <= 1'b0;
		end else if (concatenatedInputs == constAllBitOnes) begin //on this pattern, we should reset OutC to zero. its "ending pattern"
			enable_OutC <= 1'b0;
		end else begin
			enable_OutC <= 1'b1;
		end
	end
	
//outputting OutC
	always @(clk_in or reset_n or enable_OutC)
	begin : output_c
		if (reset_n == 1'b0) begin
			OutC <= 1'b1;
		end else begin
			OutC <= ~((~clk_in) && enable_OutC);
		end	
	end	
endmodule 

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
	parameter constAllBitOnes = {19{1'b1}};

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
	reg [18:0] Concatenated_Inputs; //when Go signal arrives, this vector gets-saves '0'+A+'Z'+D+'Z'+'0' 
	reg enable_OutC; //this is used to control OutC output
	
//initial values, resetted
	initial begin
		OutD <= 1'b1;
		OutC <= 1'b1;
		enable_OutC <= 1'b0;
		Concatenated_Inputs <= {19{1'b1}};
	end
	
//assigning, shifting and outputting concatenated vector of inputs
	always @ (posedge clk_in or posedge reset_n)
	begin : main_function
		if (reset_n == 1'b0) begin
			Concatenated_Inputs <= {19{1'b1}};
			OutD <= 1'b1;
		end 
		else if (Go == 1'b1) begin
			Concatenated_Inputs <= {1'b0, A, 1'bZ, D, 1'bZ, 1'b0};
		end 
		else begin
			Concatenated_Inputs <= {Concatenated_Inputs[17:0], 1'b1};
			OutD <= Concatenated_Inputs[18];			
		end
	end
	
//setting enable signal which controls when OutC will be active.
	always @ (posedge clk_in or posedge reset_n)
	begin : enabling_output_c
		if (reset_n == 1'b0) begin
			enable_OutC <= 1'b0;
		end else if (Concatenated_Inputs == constAllBitOnes) begin //on this pattern, we should reset OutC to zero. its "ending pattern"
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
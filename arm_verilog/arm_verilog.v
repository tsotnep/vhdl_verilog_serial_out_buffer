`timescale 1ns/1ps
module arm_verilog (OutD, OutC, D, A, Go, clk_in, reset_n);
	
	output OutD;
	output OutC;
	input [6:0] A;
	input [7:0] D;
	input Go;
	input clk_in;
	input reset_n;	
	
	reg OutD;
	reg OutC;
	wire [6:0] A;
	wire [7:0] D;
	wire Go;
	wire clk_in;
	wire reset_n;
	
	reg [18:0] Concatenated_Inputs;
	
	initial begin
		OutD <= 1'b1;
		for (integer i=0; i<=18; i=i+1) Concatenated_Inputs[i] <= 1'b1;
	end
	
	always @ (posedge clk_in or posedge reset_n)
	begin : main_function
		if (reset_n == 1'b1) begin
			for (integer i=0; i<=18; i=i+1) Concatenated_Inputs[i] <= 1'b1;
		end else if (Go == 1'b1) begin
			Concatenated_Inputs <= {1'b0, A, 1'bZ, D, 1'bZ, 1'b0};
		end else begin
			Concatenated_Inputs <= Concatenated_Inputs << 1;
			OutD <= Concatenated_Inputs[18];
			//if Concatenated_Inputs = all ones, then out C = 1; else OutC = ~OutC;
		end
	end
	
endmodule 
	
//kind of asynchronous reset
//always @(negedge C or posedge CLR)
//    begin
//        if (CLR)
//            Q <= 1’b0;
//        else
//            Q <= D;
//    end
//    
    
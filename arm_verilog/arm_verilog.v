module arbiter(
	data		,
	clock		,
	reset		,
	req_0		,
	req_1		,
	gnt_0		,
	gnt_1			
);

input [7:0]data;
input clock;
input reset;
input req_0;
input req_1;

output gnt_0;
output gnt_1;

wire and_gate_output; // "and_gate_output" is a wire that only outputs
reg d_flip_flop_output; // "d_flip_flop_output" is a register; it stores and outputs a value
reg [7:0] address_bus; // "address_bus" is a little-endian 8-bit register

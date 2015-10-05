//This code shows how input/output ports
// and primitve is declared
primitive udp_syntax (
a, // Port a
b, // Port b
c, // Port c
d  // Port d
);
output a;
input b,c,d;

// UDP function code here

endprimitive

/*******************  RULES   *********************/
//An UDP can contain only one output and up to 10 inputs.
//Output port should be the first port followed by one or more input ports.
//All UDP ports are scalar, i.e. Vector ports are not allowed.
//UDPs can not have bidirectional ports.
//The output terminal of a sequential UDP requires an additional declaration as type reg.
//It is illegal to declare a reg for the output terminal of a combinational UDP
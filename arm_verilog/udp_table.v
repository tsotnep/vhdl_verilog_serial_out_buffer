// This code shows how UDP body looks like
primitive udp_body (
a, // Port a
b, // Port b
c  // Port c
);
output a;
input b,c;

// UDP function code here
// A = B | C;
table
 // B  C    : A
    ?  1    : 1;
    1  ?    : 1;
    0  0    : 0;
endtable

endprimitive


	
//Table is used for describing the function of UDP. Verilog reserved word table marks the 
//start of table and reserved word endtable marks the end of table.
//Each line inside a table is one condition; when an input changes, the input condition 
//is matched and the output is evaluated to reflect the new change in input.
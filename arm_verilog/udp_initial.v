//Initial statement is used for initialization of sequential UDPs. 
//This statement begins with the keyword 'initial'. 
//The statement that follows must be an assignment statement that 
//assigns a single bit literal value to the output terminal reg.


primitive udp_initial (a,b,c);
output a;
input b,c;
reg a;
// a has value of 1 at start of sim
initial a = 1'b1;

table
// udp_initial behaviour
endtable

endprimitive



//?
//0 or 1 or X
//? means the variable can be 0 or 1 or x
//
//b
//0 or 1
//Same as ?, but x is not included
//
//f
//(10)
//Falling edge on an input
//
//r
//(01)
//Rising edge on an input
//
//p
//(01) or (0x) or (x1) or (1z) or (z1)
//Rising edge including x and z
//
//n
//(10) or (1x) or (x0) or (0z) or (z0)
//Falling edge including x and z
//
//*
//(??)
//All transitions
//
//-
//no change
//No Change
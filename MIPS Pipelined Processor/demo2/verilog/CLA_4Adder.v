////////////////////////////////////////////////////////
//4-bit Carry Look Ahead Adder 
////////////////////////////////////////////////////////
 
module CLA_4Adder(A,B, Cin, Out,Of1);
input [3:0] A,B;
input Cin;
output [3:0] Out;
output Of1;
 
wire [3:0] p,g,c;
 
assign p=A^B;//propagate
assign g=A&B; //generate
 
//carry=gi + Pi.ci
// Fundamental carry operations of a CLA
assign c[0]=Cin;
assign c[1]= g[0]|(p[0]&c[0]);
assign c[2]= g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0];
assign c[3]= g[2] | (p[2]&g[1]) | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&c[0];
assign Of1= g[3] | (p[3]&g[2]) | p[3]&p[2]&g[1] | p[3]&p[2]&p[1]&g[0] | p[3]&p[2]&p[1]&p[0]&c[0];
assign Out=p^c;
 
endmodule

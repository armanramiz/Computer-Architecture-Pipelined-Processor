
module CLA_16Adder(A, B,sign, Cin, Out,Of1);
input [15:0] A,B;
input Cin;
input sign;
output [15:0] Out;
output Of1;
wire c1,c2,c3,c4;
 
CLA_4Adder adder1 (.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .Out(Out[3:0]), .Of1(c1));
CLA_4Adder adder2 (.A(A[7:4]), .B(B[7:4]), .Cin(c1), .Out(Out[7:4]), .Of1(c2));
CLA_4Adder adder3 (.A(A[11:8]), .B(B[11:8]), .Cin(c2), .Out(Out[11:8]), .Of1(c3));
CLA_4Adder adder4 (.A(A[15:12]), .B(B[15:12]), .Cin(c3), .Out(Out[15:12]), .Of1(c4));

assign Of1 = sign ? Out[15]^A[15]^B[15]^c4 : c4; // calculate offset (Its not the same as CO!)
 
endmodule
 
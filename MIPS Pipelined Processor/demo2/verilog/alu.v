//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: alu.v
//ALU handles operations like add, shift, rotate bits and Set as defined below. Called from execute stage

module alu (A, B, Cin, Op, invA, invB, sign, Out, Ofl, Z, N);
//PASSES ALL TESTS FROM alu_hier_bench.v	
        input [15:0] A;
        input [15:0] B;
        input Cin;
        input [3:0] Op;
        input invA;
        input invB;
        input sign;// if 1 signed, 0 unsigned
        output reg [15:0] Out;
        output Ofl;
        output Z;
	output N; // is negative?

//below statement wasnt necessary, keeping for later study...
//assign shiftOut = ((~Op[2]) & Op[1]   & (~Op[0])& sign)? (shiftOut | {{B[3:0]{1'b1}}, 5d'16{1'0}}) : shiftOut;

wire [15:0] operationA ; //if invA is 1, invert A!
wire [15:0] operationB ;// if inv B is 1, invert B!
wire overflow;

wire [15:0] addResult ;// save output of add operation
//wire [15:0] orResult ;// save oputput of or operation
//wire [15:0] xorResult ;// save output of xor operation
//wire [15:0] andResult ;// save output of and operation
wire [15:0] shiftOut ;// output from shift operations

//second = if(op[1:0] ==3) andResult; elseif(2) xor ;elseif(1)or ;elseif(0) add

assign  operationA= invA ?(~A):A;// check if A should be inverted: Bitwise invert
assign  operationB= invB?(~B):B;// check if B Should be inverted

shifter shift(.In(operationA), .Cnt(operationB[3:0]), .Op(Op[1:0]), .Out(shiftOut));// Shift module gets ROL, SLL, ROR, SRL

CLA_16Adder add(.A(operationA),.B(operationB),.sign (sign), .Cin(Cin), .Out(addResult),.Of1(overflow)); // Add A and B with proper signs, overflow is caluclated within


assign Ofl = overflow;
	
assign N = addResult[15];
assign Z = |addResult ?  1'b0:  1'b1 ; // or reduction : if all bits 0 -> 0 // Z is zero flick, if all bits are 0 Z is 1, if not 1


   localparam ROL = 4'h0; //ROTATE LEFT
   localparam SLL = 4'h1;// SHIFT LEFT LOGICAL
   localparam ROR = 4'h2;// ROTATE RIGHT
   localparam SRL = 4'h3;// SHIFT RIGHT LOGICAL
   localparam ADD = 4'h4;// 2'S COMPLAMENT ADD
   localparam OR = 4'h5;// OR
   localparam XOR = 4'h6;// XOR
   localparam AND = 4'h7;// AND

   localparam SEQ = 4'h8;// SET EQUAL TO ( IS 1 IF OPERANDS EQUAL)
   localparam SLT = 4'h9;// SET LESS THAN
   localparam SLE = 4'hA;// SET LESS THAN OR EQUAL TO
   localparam SCO = 4'hB;// SET IS THERE A CARRY OUT (MY OVERFLOW CHECKS THIS)
   localparam BTR= 4'hC;// INVERT THE BITS ALL TOGETHER (OPPOSITE ORDER)


always @(*) begin
        casex(Op)
				
	ROL:  Out = shiftOut;

	SLL:  Out = shiftOut;
		  
	ROR: Out = shiftOut;

	SRL:  Out = shiftOut;
		
	ADD:  Out = addResult;

	OR:  Out = operationA[15:0] | operationB[15:0];
		  
	XOR:  Out = operationA[15:0] ^ operationB[15:0];

	AND: Out = operationA[15:0] & operationB[15:0];
		
	SEQ: Out = (Z) ? 16'h1 : 16'h0;

	SLT: Out = (overflow) ? (N ? 16'h0 : 16'h1) : (N ? 16'h1 : 16'h0);

	SLE:  Out = (overflow) ? (N ? 16'h0 : 16'h1) : ((N | Z) ? 16'h1 : 16'h0);

	SCO: Out = (overflow) ? 16'h1 : 16'h0;
		
	BTR:  Out = {operationA[0], operationA[1], operationA[2], operationA[3], operationA[4], operationA[5], operationA[6], operationA[7],
 
		    operationA[8], operationA[9], operationA[10], operationA[11], operationA[12], operationA[13], operationA[14], operationA[15]};

endcase
end
	

endmodule

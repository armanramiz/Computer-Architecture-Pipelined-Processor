//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: shifter.v
//Shifter that handles ROL, SLL, ROR, SRL. Called from the alu.v
module shifter (In, Cnt, Op, Out);
   
   input  [15:0] In;
   input  [3:0]  Cnt;
   input [1:0]  Op;
   output reg[15:0] Out;

   reg [15:0] temp1bit;
   reg [15:0] temp2bit;
   reg [15:0] temp4bit;

   localparam ROL = 2'b00;
   localparam SLL = 2'b01;
   localparam ROR = 2'b10;
   localparam SRL = 2'b11;

   always @*
 	  begin case (Op)
 	  		//ROTATE LEFT
  		  ROL	:	
		begin
	             	temp1bit = Cnt[0] ? {In[14:0],In[15]}			:	In;
             		temp2bit = Cnt[1] ? {temp1bit[13:0], temp1bit[15:14]}	: 	temp1bit;
             		temp4bit= Cnt[2] ? {temp2bit[11:0],temp2bit[15:12]} 	: 	temp2bit;
             		Out = Cnt[3] ? {temp4bit[7:0], temp4bit[15:8]} 		: 	temp4bit;          
		end

	  		//SHIFT LEFT
	 	 SLL	:
		begin
	             	temp1bit = Cnt[0] ? {In[14:0],1'b0}		:	In;
             		temp2bit = Cnt[1] ? {temp1bit[13:0], {2{1'b0}}}	: 	temp1bit;
             		temp4bit = Cnt[2] ? {temp2bit[11:0],{4{1'b0}}} 	: 	temp2bit;
             		Out = Cnt[3] ? {temp4bit[7:0], {8{1'b0}}}	: 	temp4bit;          
		end

       
          		//ROTATE RIGHT
          	ROR:
		begin
             		temp1bit = Cnt[0] ? { In[0], In[15:1]}			:	In;
             		temp2bit = Cnt[1] ? { temp1bit[1:0], temp1bit[15:2]}	: 	temp1bit;
             		temp4bit = Cnt[2] ? { temp2bit[3:0], temp2bit[15:4]}    : 	temp2bit;
             		Out = Cnt[3] ? { temp4bit[7:0], temp4bit[15:8]} 	: 	temp4bit;          
		end

         		 //SHIFT RIGHT
	 	 SRL	:
		begin
	             	temp1bit = Cnt[0] ? {1'b0,In[15:1]}		:	In;
             		temp2bit = Cnt[1] ? {{2{1'b0}}, temp1bit[15:2]}	: 	temp1bit;
             		temp4bit = Cnt[2] ? {{4{1'b0}},temp2bit[15:4]} 	: 	temp2bit;
             		Out = Cnt[3] ? {{8{1'b0}}, temp4bit[15:8]}	: 	temp4bit;          
		end
		//Default case is good to avoid unintentional latches
	  default:	Out = In;
      endcase
    end
endmodule

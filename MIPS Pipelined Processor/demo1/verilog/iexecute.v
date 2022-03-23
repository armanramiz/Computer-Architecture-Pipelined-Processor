//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: iexecute.v
//Instruction execute stage: Contains the ALU, muxes for sign extension, PC branc/ jump calculation with control signals and seperate Adder

module iexecute(clk ,rst, ALUOp, instruction, mem_data2, mem_data1, ALUselB, invA, invB, cin, sign, jump_back, pcOffSel, PCplus2, nextPC,

		alu_data, jump, branchSel, halt, isHalt, alu_result);

//Basic inputs
input clk, rst;
input[15:0] instruction; 
input halt;

//ALU CALCULATION
input[15:0] mem_data2, mem_data1;
input [2:0] ALUselB;
input[3:0] ALUOp;
input invA, invB, cin, sign;
input[1:0] alu_result;
wire [15:0] SLBI, LBI, ALU;
reg[15:0] B;
wire n;//negative

//PC CALCULATION
input jump_back;
input pcOffSel;
input[15:0] PCplus2;
input [2:0] branchSel;
output[15:0] nextPC;
input jump;
wire [15:0] PCaddress, offset;
wire[15:0] jumpPc;

//WB OUTPUT
wire zero, ofl;
output [15:0] alu_data;

wire dummy, dummy2;


  //Calculate PC address of a jump through the relevant control signals (pc offset and are we returning?) Calls a new adder
   assign PCaddress = (jump_back) ? mem_data1 : PCplus2;
   assign offset = (pcOffSel) ? {{5{instruction[10]}}, instruction[10:0]} : {{8{instruction[7]}}, instruction[7:0]};
   CLA_16Adder adder(.A(PCaddress), .B(offset), .sign(dummy), .Cin(1'h0), .Out(jumpPc), .Of1(dummy2));


   // ALU B input mux, handling extension
   always@(*) begin
      case(ALUselB)

	 3'h0: B = {{8{instruction[7]}}, instruction[7:0]};// I type sign extended
         3'h1: B = {{8{1'b0}}, instruction[7:0]}; // I type sign extended

         3'h2: B = {{11{instruction[4]}}, instruction[4:0]};// j type, sign extend 
         3'h3: B = {{11{1'b0}}, instruction[4:0]}; //J type, zero extended

         3'h4: B = mem_data2; // USED IN BASIC ALU OPERATIONS
         3'h5: B = 16'h0; // USED IN BRANCH, SET COMPARISON
      endcase 
   end	


//Use the signals from control (decode stage) to determine the alu operation that will take place
   alu alu(.A(mem_data1), .B(B), .Cin(cin), .Op(ALUOp), .invA(invA), .invB(invB), 
      .sign(sign), .Out(ALU), .Ofl(ofl), .Z(zero), .N(n));

//I accomodated for these two instruction types within exec stage, using the alu_result control signal
assign LBI =  {{4'h8{instruction[7]}},instruction[7:0]};
assign SLBI = {mem_data1[7:0], instruction[7:0]};
// Obtain the final alu result
assign  alu_data = (alu_result[1]) ? ((alu_result[0]) ? (16'h0) : (SLBI)) : ((alu_result[0]) ? (LBI) : (ALU));

wire doBranch;
output isHalt;

//Handle branch PC calculation using the branchSel Control signal

					//no brach          no           GEZ                                  LTZ   :  NEZ                  EGZ     NOBR
assign doBranch = branchSel[2] ? (branchSel[1] ? 1'b0 : (branchSel[0] ? 1'b0 : ( ~n | zero))) : (branchSel[1] ? (branchSel[0] ? n : ~zero) : (branchSel[0] ? (zero) : 1'b0));
assign isHalt = (rst) ? 1'h0 : isHalt | halt;
assign nextPC = (jump | doBranch) ? jumpPc : PCplus2;

endmodule

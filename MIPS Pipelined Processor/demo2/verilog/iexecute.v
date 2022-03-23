//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: iexecute.v
//Instruction execute stage: Contains the ALU, muxes for sign extension, PC branch/ jump calculation with control signals and seperate Adder

module iexecute(clk, rst, instruction, nextPc, data_reg1, data_reg2, ALUOp, ALUselB, halt, sign, pcOffSel,  jump_EX, invA, invB, cin, jump_back,memToReg, 

				branchSel, newPC_DX, alu_data_XM, branch_DX, alu_result);
	

	input halt, jump_back, sign, jump_EX, invA, invB, cin, memToReg, clk, rst, pcOffSel;
	input [3:0] ALUOp;
	input [2:0] ALUselB, branchSel;
	input [15:0] data_reg1, data_reg2, nextPc, instruction;
	input[1:0] alu_result;
	
	output branch_DX;
	output [15:0] alu_data_XM, newPC_DX;
	
	wire zero, n, ofl;
	wire [15:0] PCaddress, offset;
	reg [15:0] B;
	wire [15:0] SLBI, LBI, ALU, jumpPc;


	//Calculate PC address of a jump through the relevant control signals (pc offset and are we returning?) Calls a new adder
	assign PCaddress = (jump_back) ? data_reg1 : nextPc;
	assign offset = (pcOffSel) ? {{5{instruction[10]}}, instruction[10:0]} : {{8{instruction[7]}}, instruction[7:0]};
	
	CLA_16Adder adder(.A(PCaddress), .B(offset), .sign(dummy), .Cin(1'h0), .Out(jumpPc), .Of1(dummy2));

//Handle branch PC calculation using the branchSel Control signal
				//no brach          no           GEZ                                  LTZ   :  NEZ                  EGZ     NOBR
assign branch_DX =branchSel[2] ? (branchSel[1] ? 1'b0 : (branchSel[0] ? 1'b0 : ( ~n | zero))) : (branchSel[1] ? (branchSel[0] ? n : ~zero) : (branchSel[0] ? (zero) : 1'b0));

//assign isHalt = (rst) ? 1'h0 : halt;
assign newPC_DX = (branch_DX | jump_EX) ? jumpPc :nextPc;

   always@(*) begin
      case(ALUselB)

	 3'h0: B = {{8{instruction[7]}}, instruction[7:0]};// I type sign extended
         3'h1: B = {{8{1'b0}}, instruction[7:0]}; // I type sign extended

         3'h2: B = {{11{instruction[4]}}, instruction[4:0]};// j type, sign extend 
         3'h3: B = {{11{1'b0}}, instruction[4:0]}; //J type, zero extended

         3'h4: B = data_reg2; // USED IN BASIC ALU OPERATIONS
         3'h5: B = 16'h0; // USED IN BRANCH, SET COMPARISON
      endcase 
   end	

//I accomodated for these two instruction types within exec stage, using the alu_result control signal
assign LBI =  {{4'h8{instruction[7]}},instruction[7:0]};
assign SLBI = {data_reg1[7:0], instruction[7:0]};

//Use the signals from control (decode stage) to determine the alu operation that will take place
	alu alua(.A(data_reg1), .B(B), .Cin(cin), .Op(ALUOp), .invA(invA), .invB(invB), .sign(sign), .Out(ALU), .Ofl(ofl), .Z(zero), .N(n));
	
// Obtain the final alu result
assign  alu_data_XM = (alu_result[1]) ? ((alu_result[0]) ? (16'h0) : (SLBI)) : ((alu_result[0]) ? (LBI) : (ALU));

endmodule
//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: idecode.v
//Insturction decode stage: Contains the control unit and the register file

module idecode (target_WB, clk, rst, instruction, writeData, jump, halt, sign, pcOffSel, mem_write, memToReg, mem_read, invA, invB,

		jump_back, cin, ALUOp, ALUselB, Sel_WBreg, branchSel, read1data, read2data, err, reg_wrt, alu_result); 
		
//Basic inputs
input clk, rst;
input[15:0] instruction; 

//Input signal from write back 
input[15:0] writeData;
output [2:0] target_WB;

//Out from control logic
output jump, halt, sign, pcOffSel, mem_write, memToReg, mem_read, invA, invB, jump_back, cin;
output [3:0] ALUOp;
output [2:0] ALUselB, branchSel;
output[1:0] alu_result, Sel_WBreg;
output reg_wrt; 
//Signals from writeback stage (rf), these will be output to Execute, and for branch calculation
output [15:0] read1data, read2data;
output err;

//Internal signals
wire[1:0] RegDstSel; 
wire error_reg;// kind of unsure about error handling


control_logic ctrl(.opCode(instruction[15:11]), .func(instruction[1:0]), .halt(halt), .sign(sign), .pcOffSel(pcOffSel), 

         .reg_wrt(reg_wrt), .mem_write(mem_write), .memToReg(memToReg), .mem_read(mem_read), .jump(jump), .invA(invA), .invB(invB), 

	.ALUselB(ALUselB), .err(err), .RegDstSel(RegDstSel), .Sel_WBreg(Sel_WBreg), .ALUOp(ALUOp), .jump_back(jump_back), .cin(cin), 

   	 .branchSel(branchSel), .alu_result(alu_result));

assign  target_WB = (RegDstSel[1]) ? ((RegDstSel[0]) ? (3'h7) : (instruction[4:2])) : ((RegDstSel[0]) ? (instruction[10:8]) : (instruction[7:5]));
 

rf register(.read1data(read1data), .read2data(read2data), .err(error_reg), 

      .clk(clk), .rst(rst), .read1regsel(instruction[10:8]), .read2regsel(instruction[7:5]), 

      .target_WB(target_WB), .writedata(writeData), .write(reg_wrt));
	
endmodule
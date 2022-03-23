/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here */

   wire  cin, sign, invA, invB, jump_back, jump , mem_write, reg_wrt, mem_read, halt, isHalt, pcOffSel, regErr;
   wire [1:0] alu_result, Sel_WBreg;
   wire [2:0] ALUselB, read1Sel, read2Sel, branchSel;
   wire [3:0] ALUOp;
   wire [15:0] pc, nextPC, PCplus2, alu_data, memOut, mem_data1, mem_data2, instruction, PCaddress, offset, writeData;
   wire[2:0] target_WB;

//I had to take this out of the fetch stage in order for synthesis to work, will make this better in pipelined version
register16 pcReg(.clk(clk), .rst(rst), .write_en(~isHalt), .write_data(nextPC), .read_data(pc));

//////////////////////////////////////////////////   FETCH STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

ifetch dut(.clk(clk), .rst(rst), .PC(pc), .PCplus2(PCplus2), .instruction(instruction));


//////////////////////////////////////////////////   DECODE STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
idecode decode0(.target_WB(target_WB), .clk(clk), .rst(rst), .instruction(instruction), .writeData(writeData), .jump(jump), .halt(halt), .sign(sign), 

	.pcOffSel(pcOffSel), .mem_write(mem_write), .memToReg(memToReg), .mem_read(mem_read), .invA(invA), .invB(invB),

		.jump_back(jump_back), .cin(cin), .ALUOp(ALUOp), .ALUselB(ALUselB), .Sel_WBreg(Sel_WBreg), .branchSel(branchSel), 

		.read1data(mem_data1), .read2data(mem_data2), .err(regErr), .reg_wrt(reg_wrt), .alu_result(alu_result)); 


//////////////////////////////////////////////////   EXECUTE STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
iexecute execute0 (.clk(clk), .rst(rst), .ALUOp(ALUOp), .instruction(instruction), .mem_data2(mem_data2), .mem_data1(mem_data1), .ALUselB(ALUselB),

		   .invA(invA), .invB(invB), .cin(cin), .sign(sign), .jump_back(jump_back), .pcOffSel(pcOffSel), .PCplus2(PCplus2),

		 .nextPC(nextPC), .alu_data(alu_data), .jump(jump), .branchSel(branchSel),

		 .halt(halt), .isHalt(isHalt), .alu_result(alu_result));


//////////////////////////////////////////////////   MEMORY STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
imemory memory0(.clk(clk), .rst(rst), .err(err), .isHalt(isHalt), .mem_read(mem_read), .mem_write(mem_write),

			 .mem_data2(mem_data2), .alu_data(alu_data), .memOut(memOut));


//////////////////////////////////////////////////   WIRTE BACK STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
iwriteback writeback0(.Sel_WBreg(Sel_WBreg), .PCplus2(PCplus2), .alu_data(alu_data), 

			.memOut(memOut), .writeData(writeData)); 


endmodule 
// DUMMY LINE FOR REV CONTROL :0:
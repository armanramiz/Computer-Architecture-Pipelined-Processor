//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: EXMEM.v
//Execute to Memory pipe latch: Contains registers for the output signals from execute unit, that will be passed to memory stage, 
//as well as PC, instruction, jump and branch registers for the fetch stage. 

module EXMEM ( clk, rst, reg_write_DX, reg_write, halt_DX, halt_XM, mem_read, mem_read_XM, mem_write, mem_write_XM, target_WBreg, target_WBreg_XM, Sel_WBreg, Sel_WBreg_XM, 

		data_reg1, Data1_XM, mem_writeData, Data2_XM, instruction, instruction_XM, nextPc, nextPC_XM, alu_data_XM, alu_data, newPC_DX, newPC,

		branch_DX, branch, jump_EX, jump_XM, branchCond);

input clk, rst;
input  reg_write_DX, mem_read, halt_DX, mem_write, branch_DX, jump_EX;
input[2:0] target_WBreg, Sel_WBreg;
input[15:0] data_reg1, mem_writeData, instruction, nextPc, alu_data_XM, newPC_DX;

//wire reset;

output reg_write, halt_XM, mem_read_XM,  mem_write_XM, branch, jump_XM;
output[2:0] target_WBreg_XM, Sel_WBreg_XM;
output[15:0] Data1_XM, Data2_XM, instruction_XM, nextPC_XM, alu_data, newPC;
output branchCond;

assign branchCond = branch | jump_XM;

register16 #(.SIZE(1)) regWrtOut_REG(.clk(clk), .rst(rst |branchCond ), .write_en(1'b1), .write_data(reg_write_DX), .read_data(reg_write));

register16 #(.SIZE(1)) haltTT_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(halt_DX), .read_data(halt_XM));

register16 #(.SIZE(1)) mem_read_XM_REG(.clk(clk), .rst(rst |branchCond), .write_en(1'b1), .write_data(mem_read), .read_data(mem_read_XM));

register16 #(.SIZE(1)) mem_write_XM_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(mem_write), .read_data(mem_write_XM));

register16 #(.SIZE(3))target_WBreg_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(target_WBreg), .read_data(target_WBreg_XM));

register16 #(.SIZE(3)) Sel_WBreg_XM_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(Sel_WBreg), .read_data(Sel_WBreg_XM));

//SIZE 16'S
register16 #(.SIZE(16))data_reg1_REG(.clk(clk), .rst(rst |branchCond), .write_en(1'b1), .write_data(data_reg1), .read_data(Data1_XM));

register16 #(.SIZE(16))mem_writeData_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(mem_writeData), .read_data(Data2_XM));

register16 #(.SIZE(16))instruction_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(instruction), .read_data(instruction_XM));

register16 #(.SIZE(16))nextPc_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(nextPc), .read_data(nextPC_XM));

register16 #(.SIZE(16))alu_data_XM_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(alu_data_XM), .read_data(alu_data));

register16 #(.SIZE(16))newPC_DX_REG(.clk(clk), .rst(rst |branchCond), .write_en(1'b1), .write_data(newPC_DX), .read_data(newPC));


register16 #(.SIZE(1))branch_DX_REG(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(branch_DX), .read_data(branch));

register16 #(.SIZE(1))jumpd_EX(.clk(clk), .rst(rst | branchCond), .write_en(1'b1), .write_data(jump_EX), .read_data(jump_XM));


endmodule







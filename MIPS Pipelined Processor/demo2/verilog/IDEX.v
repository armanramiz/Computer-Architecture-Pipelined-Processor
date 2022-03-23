//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: IDEX.v
//Decode to Execute pipe latch: Contains registers for the control signals from the decode stage. These will be used in execute stage. 

module IDEX(clk, rst, stall, alu_resultDX, alu_result, PC_F, PC_DX, instruction_F, instruction_DX, mem_data1_F, mem_data1_DX, mem_data2_F, mem_data2_DX, ALUOp_ID, ALUOp_EX,

		ALUselB_ID, ALUselB_EX, Sel_WBreg_ID, Sel_WBreg_EX,branchSel_ID, branchSel_EX, target_WB, target_WBEX, halt_ID, halt_EX, sign_ID, sign_EX, pcOffSel_ID, pcOffSel_EX, 

		jump_ID, jump_EX, invA_ID, invA_EX, invB_ID, invB_EX, jumpBack_ID, cin_ID, memToReg_ID, jumpBack_EX, cin_EX, memToReg_EX, reg_wrt_ID, reg_wrt_EX, 

		mem_write_ID, mem_read_ID, mem_write_EX, mem_read_EX);

		 

input clk, rst, stall;
input[1:0] alu_result;
input[15:0] PC_F, instruction_F, mem_data1_F, mem_data2_F;
input[3:0] ALUOp_ID;
input[2:0] ALUselB_ID, Sel_WBreg_ID, branchSel_ID, target_WB;
input halt_ID, sign_ID, pcOffSel_ID, jump_ID, invA_ID, invB_ID, jumpBack_ID, cin_ID, memToReg_ID, reg_wrt_ID, mem_write_ID, mem_read_ID;



output[15:0] PC_DX, instruction_DX, mem_data1_DX, mem_data2_DX;
output[3:0] ALUOp_EX;
output [2:0] ALUselB_EX, Sel_WBreg_EX, branchSel_EX, target_WBEX;
output[1:0] alu_resultDX;
output halt_EX, sign_EX, pcOffSel_EX, jump_EX, invA_EX, invB_EX, jumpBack_EX, cin_EX, memToReg_EX, reg_wrt_EX, mem_write_EX, mem_read_EX;


//size16's
register16 #(.SIZE(2))alu_result_REG(.clk(clk), .rst(rst), .write_en(~stall),.write_data(alu_result), .read_data(alu_resultDX));

register16 #(.SIZE(16))PC_F_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(PC_F), .read_data(PC_DX));


register16 #(.SIZE(16))instruction_F_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(instruction_F), .read_data(instruction_DX));


register16 #(.SIZE(16))mem_data1_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(mem_data1_F), .read_data(mem_data1_DX));

register16 #(.SIZE(16))mem_data2_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(mem_data2_F), .read_data(mem_data2_DX));


//SIZE4'S

register16 #(.SIZE(4))ALUOp_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(ALUOp_ID), .read_data(ALUOp_EX));

//size3's
    register16 #(.SIZE(3))ALUselB_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(ALUselB_ID), .read_data(ALUselB_EX));

  register16 #(.SIZE(3))Sel_WBreg_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(Sel_WBreg_ID), .read_data(Sel_WBreg_EX));

register16 #(.SIZE(3))branchSel_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(branchSel_ID), .read_data(branchSel_EX));

register16 #(.SIZE(3))target_WB_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(target_WB), .read_data(target_WBEX));



register16 #(.SIZE(1))halt_REG(.clk(clk), .rst(rst), .write_en(~stall),.write_data(halt_ID), .read_data(halt_EX));

    register16 #(.SIZE(1))sign_REG(.clk(clk), .rst(rst),.write_en(~stall),  .write_data(sign_ID), .read_data(sign_EX));

    register16 #(.SIZE(1))PCoffset_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(pcOffSel_ID), .read_data(pcOffSel_EX));


register16 #(.SIZE(1))jump_REG(.clk(clk), .rst(rst), .write_en(~stall),.write_data(jump_ID), .read_data(jump_EX));

register16 #(.SIZE(1))invA_REG(.clk(clk), .rst(rst),.write_en(~stall),  .write_data(invA_ID), .read_data(invA_EX));

register16 #(.SIZE(1))invB_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(invB_ID), .read_data(invB_EX));


 register16 #(.SIZE(1))jump_back_REG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(jumpBack_ID), .read_data(jumpBack_EX));

    register16 #(.SIZE(1))cin_REG(.clk(clk), .rst(rst),.write_en(~stall),  .write_data(cin_ID), .read_data(cin_EX));


   register16 #(.SIZE(1)) memToReg_REG(.clk(clk), .rst(rst),.write_en(~stall),  .write_data(memToReg_ID), .read_data(memToReg_EX));


 register16 #(.SIZE(1))reg_wrtID(.clk(clk), .rst(rst), .write_en(1'b1),.write_data(reg_wrt_ID), .read_data(reg_wrt_EX));

register16 #(.SIZE(1))mem_write_ID_REG(.clk(clk), .rst(rst),.write_en(~stall),  .write_data(mem_write_ID), .read_data(mem_write_EX));

 register16 #(.SIZE(1))mem_read_ID_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(mem_read_ID), .read_data(mem_read_EX));



endmodule
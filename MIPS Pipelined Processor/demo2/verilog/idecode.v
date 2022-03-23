//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: idecode.v
//Insturction decode stage: Contains the control unit and the register file
module idecode(clk, rst, err, stall, instruction,  reg_writeData, reg_write, target_WBreg, halt_ID, sign_ID, pcOffSel_ID, reg_wrt_ID, mem_write_ID, mem_read_ID,

 jump_ID, jumpBack_ID, invA_ID, invB_ID, cin_ID, memToReg_ID, target_WB, ALUselB_ID, Sel_WBreg_ID, branchSel_ID, ALUOp_ID, mem_data1_F, mem_data2_F, alu_result);
	

	input clk, rst, stall, reg_write;
	input [2:0] target_WBreg;
	input [15:0] instruction, reg_writeData;
		
	output err, halt_ID, sign_ID, pcOffSel_ID, reg_wrt_ID, mem_write_ID, mem_read_ID, jump_ID, invA_ID, invB_ID, jumpBack_ID, cin_ID, memToReg_ID;
	output [1:0] alu_result;
	output [2:0] ALUselB_ID, Sel_WBreg_ID, branchSel_ID, target_WB;
	output [3:0] ALUOp_ID;
	output [15:0] mem_data1_F, mem_data2_F;
	

	wire [1:0] RegDstSel;
    wire error_C, error_rf;
	wire [15:0] instruction_ID;
	assign instruction_ID = stall ? 16'h0800: instruction;
	assign err = error_C | error_rf;

//obtain control signals, accounting for the stall which will insert NOP's if set
	control_logic ctrlBlk(.opCode(instruction_ID[15:11]), .func(instruction_ID[1:0]), 

		.halt(halt_ID), .sign(sign_ID), .pcOffSel(pcOffSel_ID), 

		.reg_write(reg_wrt_ID), .mem_write(mem_write_ID), .memToReg(memToReg_ID), .mem_read(mem_read_ID), 

		.jump(jump_ID), .invA(invA_ID), .invB(invB_ID), .ALUselB(ALUselB_ID), .err(error_C), 

		.RegDstSel(RegDstSel), .Sel_WBreg(Sel_WBreg_ID), .ALUOp(ALUOp_ID), .cin(cin_ID), 

		.jump_back(jumpBack_ID), .branchSel(branchSel_ID), .alu_result(alu_result));

//Select register at bit address 7 for JAL AND JALR
//Select register at address 4:2 for  R type instructions
//Select register at address 10:8 for Load and stroe type instruction
//Select register at address 7:5 for the rest of the instructions
assign  target_WB = (RegDstSel[1]) ? ((RegDstSel[0]) ? (3'h7) : (instruction_ID[4:2])) : 

			((RegDstSel[0]) ? (instruction_ID[10:8]) : (instruction_ID[7:5]));
			
			
//obtain data from register 1 and 2. USING THE TARGET FROM LATCHED SIGNAL AND ENABLE

    rf_bypass register1(.read1data(mem_data1_F), .read2data(mem_data2_F), .err(error_rf), 

		.clk(clk), .rst(rst), .read1regsel(instruction_ID[10:8]), .read2regsel(instruction_ID[7:5]), 

		.writeregsel(target_WBreg), .writedata(reg_writeData), .write(reg_write));


endmodule
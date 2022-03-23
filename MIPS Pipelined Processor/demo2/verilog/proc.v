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


 wire [15:0] PCplus2_FD, PC_current, newPC, instruction;
 wire reg_write, halt, stall, branchCond;
 
//I had to take this out of the fetch stage in order for synthesis to work, will make this better in pipelined version. FIXED
//register16 #(.SIZE(16)) regWta_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(newPC), .read_data(pc));

//////////////////////////////////////////////////   FETCH STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

//Fetch stage starts initial PC from the memory unit, follows up by considering branch/ jump/ halt's. This information is in newPC (for updating pc), brancCond and halt from execute stage
ifetch fetch0( .clk(clk), .rst(rst), .stall(stall), .halt(halt), .instruction(instruction), .branch(branchCond), .newPC(newPC), .nextPc(PC_current) );

//Later included this inside fetch for convenience. FIXED
     //IFID pipe1(.stall(stall), .clk(clk), .rst(rst), .PC(PC_current), .PCplus2_FD(PCplus2_FD));


//////////////////////////////////////////////////   DECODE STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
wire [1:0] alu_result;
wire[15:0] mem_data1_F, mem_data2_F, reg_writeData;
wire[3:0] ALUOp_ID;
wire[2:0] ALUselB_ID, Sel_WBreg_ID, branchSel_ID, target_WB_ID, target_WBreg;
wire halt_ID, sign_ID, pcOffSel_ID, jump_ID, invA_ID, invB_ID, jumpBack_ID, cin_ID, memToReg_ID, reg_wrt_ID, mem_read_ID, mem_write_ID;

//decode stage decodes the instructions from the control logic, sending them through to the following stage. It considers stall to place NOP's.
	idecode decode0(.clk(clk), .rst(rst), .stall(stall), .err(err), .instruction(instruction), .reg_writeData(reg_writeData), .reg_write(reg_write), .reg_wrt_ID(reg_wrt_ID), .jump_ID(jump_ID), .halt_ID(halt_ID), .sign_ID(sign_ID), .pcOffSel_ID(pcOffSel_ID),
	
	.mem_write_ID(mem_write_ID), .mem_read_ID(mem_read_ID), .memToReg_ID(memToReg_ID), .invA_ID(invA_ID), .invB_ID(invB_ID), .jumpBack_ID(jumpBack_ID), .cin_ID(cin_ID), .ALUOp_ID(ALUOp_ID), .ALUselB_ID(ALUselB_ID), .Sel_WBreg_ID(Sel_WBreg_ID),
	
	.branchSel_ID(branchSel_ID), .mem_data1_F(mem_data1_F), .mem_data2_F(mem_data2_F), .target_WBreg(target_WBreg),  .target_WB(target_WB_ID), .alu_result(alu_result));

		    
wire[15:0]instruction_DX, nextPC_DX, Data1_DX, Data2_DX;
wire [3:0] ALUOp_DX;
wire[2:0]  Sel_WBreg,  ALUselB, branchSel, target_WBreg_DX;
wire[1:0] alu_resultDX;
wire halt_DX, sign, pcOffSel, jump, invA, invB, jump_back, cin, memToReg, reg_write_DX, mem_write_DX, mem_read_DX;


IDEX pipe2(.clk(clk), .rst(rst), .stall(stall),

									//send the control signals decoded to the IDEX PIPE as inputs
		.PC_F(PC_current), .instruction_F(instruction), .mem_data1_F(mem_data1_F), .mem_data2_F(mem_data2_F), .alu_result(alu_result), .ALUOp_ID(ALUOp_ID), .ALUselB_ID(ALUselB_ID), 

		.Sel_WBreg_ID(Sel_WBreg_ID), .branchSel_ID(branchSel_ID), .target_WB(target_WB_ID),  .halt_ID(halt_ID), .sign_ID(sign_ID), .jump_ID(jump_ID), .invA_ID(invA_ID), .invB_ID(invB_ID),
		
		.pcOffSel_ID(pcOffSel_ID),  .jumpBack_ID(jumpBack_ID), .cin_ID(cin_ID),  .memToReg_ID( memToReg_ID), .reg_wrt_ID(reg_wrt_ID),  .mem_write_ID(mem_write_ID), .mem_read_ID(mem_read_ID), 
		
									//Retrieve them as outputs for the execute stage
		.PC_DX(nextPC_DX), .instruction_DX(instruction_DX),  .mem_data1_DX(Data1_DX),  .mem_data2_DX(Data2_DX), .alu_resultDX(alu_resultDX), .ALUOp_EX(ALUOp_DX),  .ALUselB_EX(ALUselB), 
		
		.Sel_WBreg_EX(Sel_WBreg), .branchSel_EX(branchSel), .target_WBEX(target_WBreg_DX), .halt_EX(halt_DX), .sign_EX(sign), .jump_EX(jump), .invA_EX(invA), .invB_EX(invB), .jumpBack_EX(jump_back),  .pcOffSel_EX(pcOffSel),

		.cin_EX(cin), .memToReg_EX(memToReg),  .reg_wrt_EX(reg_write_DX), .mem_write_EX(mem_write_DX), .mem_read_EX(mem_read_DX));


//////////////////////////////////////////////////   EXECUTE STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!		

wire reset, branch_DX;
wire[15:0] alu_data_XM,  newPC_DX, data_reg1, data_reg2;
											
												
	iexecute execute0( .clk(clk), .rst(rst), .ALUOp(ALUOp_DX), .instruction(instruction_DX), .data_reg1(data_reg1), .data_reg2(data_reg2), .nextPc(nextPC_DX), .ALUselB(ALUselB),  .invA(invA), .invB(invB),  .sign(sign), .cin(cin),
	
	.jump_back(jump_back), .pcOffSel(pcOffSel), .jump_EX(jump), .branchSel(branchSel), .halt(halt_DX),.memToReg(memToReg), .newPC_DX(newPC_DX), .branch_DX(branch_DX), .alu_data_XM(alu_data_XM), .alu_result(alu_resultDX));
	
	
 
 wire[15:0] instruction_XM, Data1_XM,  Data2_XM, nextPC_XM, alu_data;
 wire  reg_write_XM,  mem_write_XM,  mem_read_XM, jump_XM,  branch;
 wire [2:0]   target_WBreg_XM, Sel_WBreg_XM;
 
				
	EXMEM pipe3( 						//INPUTS TO THE PIPE FROM EXECTURE AND STALL/FWD LOGIC
	
			.clk(clk), .rst(rst), .instruction(instruction_DX), .data_reg1(data_reg1), .mem_writeData(data_reg2), .nextPc(nextPC_DX), .alu_data_XM(alu_data_XM), .newPC_DX(newPC_DX),
	
			.target_WBreg(target_WBreg_DX), .Sel_WBreg(Sel_WBreg), .reg_write_DX(reg_write_DX), .mem_read(mem_read_DX), .mem_write(mem_write_DX), .halt_DX(halt_DX), .branch_DX(branch_DX), .jump_EX(jump),
			
								//OUTPUTS FOR MEMORY/ FETCH/ STALL/FWD LOGIC
			 .Data1_XM(Data1_XM), .Data2_XM(Data2_XM), .instruction_XM(instruction_XM), .nextPC_XM(nextPC_XM),  .alu_data(alu_data), .newPC(newPC), .target_WBreg_XM(target_WBreg_XM),  .Sel_WBreg_XM(Sel_WBreg_XM),
			 
			 .reg_write(reg_write_XM), .mem_read_XM(mem_read_XM), .mem_write_XM(mem_write_XM), .halt_XM(halt), .branch(branch), .jump_XM(jump_XM), .branchCond(branchCond));
	
	
	
//////////////////////////////////////////////////   MEMORY STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
wire [15:0] mem_readData;
	//MEMORY UNIT
	imemory memory0(.clk(clk), .rst(rst), .mem_write(mem_write_XM), .mem_read(mem_read_XM), .halt(halt), .mem_writeData(Data2_XM), .alu_data(alu_data),  .mem_readData(mem_readData));

wire [2:0] Sel_WBreg_MW;
wire[15:0] mem_data;

		MEMWB pipe4( .clk(clk), .rst(rst), .reg_write_XM(reg_write_XM), .reg_write(reg_write), .mem_readData(mem_readData), .mem_data(mem_data),.target_WBreg_XM(target_WBreg_XM), .target_WBreg(target_WBreg),
		
			.Sel_WBreg_XM(Sel_WBreg_XM), .Sel_WBreg_MW(Sel_WBreg_MW));
		
//////////////////////////////////////////////////   WIRTE BACK STAGE   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
wire[15:0] forward_dataW;

iwriteback writeback0(.clk(clk), .rst(rst), .alu_data(alu_data), .Sel_WBreg(Sel_WBreg_XM), .forward_dataW(forward_dataW), .nextPc(nextPC_XM), .mem_data(mem_data)); 

//STALL LOGIC- FIXED FOR FORWARDING IMPLEMENTATION

stall_logic stalling(.clk(clk), .rst(rst), .instruction(instruction), .instruction_DX(instruction_DX), .mem_read_DX(mem_read_DX), .mem_write_DX(mem_write_DX), .stall(stall), .target_WBreg(target_WBreg), .target_WBreg_XM(target_WBreg_XM),

			.reg_write_XM(reg_write_XM), .reg_write(reg_write), .Sel_WBreg_MW(Sel_WBreg_MW),.mem_data(mem_data), .forward_dataW(forward_dataW), .Data1_DX(Data1_DX), .Data2_DX(Data2_DX),

			 .data_reg1(data_reg1), .data_reg2(data_reg2), .reg_writeData(reg_writeData));
	
	
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
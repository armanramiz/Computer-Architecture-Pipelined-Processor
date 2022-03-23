//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: stall_logic.v
//STALL (WHICH LATER INCLUDES FORWARD!): Accounts for stalling, forwarding data to the execute stage based on hazards

module stall_logic(clk, rst, mem_read_DX, mem_write_DX, stall, instruction, instruction_DX, target_WBreg, target_WBreg_XM, reg_write_XM,  reg_write, Sel_WBreg_MW, mem_data,

		forward_dataW, Data1_DX, Data2_DX, data_reg1, data_reg2, reg_writeData);

input clk, rst;
input mem_read_DX, mem_write_DX, reg_write_XM, reg_write;//reg_write comes from EXEM stage

input[15:0] instruction, instruction_DX, mem_data, forward_dataW, Data1_DX, Data2_DX;
input[2:0]  target_WBreg, target_WBreg_XM, Sel_WBreg_MW;

output stall;
output[15:0] data_reg1, data_reg2, reg_writeData;

wire fwd2_mem1, fwd2_mem2,writeback_forwardData1, writeback_forwardData2;
wire[15:0]  write_dataFW;

	//STALL WHEN THE NEXT INSTRUCTION CONTAINS THE VALUE for the NEXT INSTRUCTION
	//STALL WHEN WE WILL WRITE TO A REG THAT IS USED FOR THE NEXT INSTRUCTION
	assign stall_1 = (instruction[7:5] == instruction_DX[7:5]) | 
	
					(instruction[10:8] == instruction_DX[7:5]);
		
					//mem being read from
	assign stall = (mem_read_DX & ~mem_write_DX)& stall_1;
	
	//acquire forwarded data again (like the pipes)
	register16 writedata_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(forward_dataW), .read_data(write_dataFW));
	//USE THE FORWARDED DATA, INSERT FOR THE EXECUTE STAGE.
	assign writeback_forwardData1 = reg_write & ( target_WBreg == instruction_DX[10:8]); 
	assign writeback_forwardData2 = reg_write &( target_WBreg == instruction_DX[7:5]);
	assign fwd2_mem1 = reg_write_XM & ( target_WBreg_XM == instruction_DX[10:8]);
	assign fwd2_mem2 = reg_write_XM & (target_WBreg_XM == instruction_DX[7:5]);
	
	//actual data written after the MW stage, if not use the memory data
	assign reg_writeData = (Sel_WBreg_MW == 0 ) ?  mem_data: write_dataFW;
	assign data_reg1 = (fwd2_mem1) ? forward_dataW : ((writeback_forwardData1) ? reg_writeData : Data1_DX);
	assign data_reg2 = (fwd2_mem2) ? forward_dataW : ((writeback_forwardData2) ? reg_writeData : Data2_DX);

	
	

endmodule
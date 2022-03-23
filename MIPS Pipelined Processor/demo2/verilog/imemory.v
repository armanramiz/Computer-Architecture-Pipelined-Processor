//Author: ARMAN RAMIZ
//Class: ECE552 Computer Architecture, File: imemory.v
//Memory Stage: Data Memory
module imemory(clk, rst, mem_write, mem_read, halt, mem_writeData, alu_data, mem_readData);
	
	input clk, rst, halt, mem_read, mem_write;
	input [15:0]  mem_writeData, alu_data;//inputs from EXECUTE pipe
	output [15:0] mem_readData; //output to WB
	
//DATA MEMORY
									//mem read eacts like the enable signal for the memory unit
memory2c mem(.data_out(mem_readData), .data_in(mem_writeData), .addr(alu_data), .enable(mem_read), .createdump(halt), 
				.wr(mem_write), .clk(clk), .rst(rst));


endmodule
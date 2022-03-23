//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: iwriteback.v
//Write Back stage: contains a 4-2 mux to control what output gets written to the register file

module iwriteback(clk, rst, alu_data, Sel_WBreg, forward_dataW, nextPc, mem_data); 

input clk, rst;
input [2:0] Sel_WBreg;
input [15:0] alu_data, nextPc, mem_data;
output[15:0] forward_dataW;

//select which register to use, write/read from that register (write or read is done via memory unit selection)

assign forward_dataW = (Sel_WBreg[1]) ? ((Sel_WBreg[0]) ? (16'h0) : (nextPc)) : ((Sel_WBreg[0]) ? (alu_data) : (mem_data));

endmodule

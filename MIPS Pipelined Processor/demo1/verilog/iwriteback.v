//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: iwriteback.v
//Write Back stage: contains a 4-2 mux to control what output gets written to the register file

module iwriteback(Sel_WBreg, PCplus2, alu_data, memOut, writeData); 

input[1:0] Sel_WBreg;
input [15:0] PCplus2, alu_data, memOut;
output [15:0] writeData;
//Will implement memToReg for the future in the pipelined version, for now not needed...
assign writeData = (Sel_WBreg[1]) ? ((Sel_WBreg[0]) ? (16'h0) : (PCplus2)) : ((Sel_WBreg[0]) ? (alu_data) : (memOut));

endmodule

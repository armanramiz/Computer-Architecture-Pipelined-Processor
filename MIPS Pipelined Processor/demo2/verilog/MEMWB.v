//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: MEMWB.v
//MEM TO WB PIPE LATCH: contains register for the memory data, register write Enable signal, target register, and the accompanying control select signal.

module MEMWB( clk, rst, reg_write_XM, reg_write, mem_readData, mem_data, target_WBreg_XM, target_WBreg, Sel_WBreg_XM, Sel_WBreg_MW);

input clk, rst, reg_write_XM;
input [15:0] mem_readData;
input[2:0] target_WBreg_XM, Sel_WBreg_XM;


output [2:0] target_WBreg, Sel_WBreg_MW;
output reg_write;
output [15:0] mem_data;

register16 #(.SIZE(16)) MemOut_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(mem_readData), .read_data(mem_data));

register16 #(.SIZE(1)) regWrt_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(reg_write_XM), .read_data(reg_write));

register16 #(.SIZE(3)) writeReg_REG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(target_WBreg_XM), .read_data(target_WBreg));

register16 #(.SIZE(3)) select_reg2use(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(Sel_WBreg_XM), .read_data(Sel_WBreg_MW));

endmodule
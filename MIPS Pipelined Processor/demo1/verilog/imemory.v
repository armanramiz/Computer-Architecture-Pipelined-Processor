//Author: ARMAN RAMIZ
//Class: ECE552 Computer Architecture, File: imemory.v
//Memory Stage: Data Memory

module imemory (clk, rst, err, isHalt, mem_read, mem_write, mem_data2, alu_data, memOut);

  //Very basic way to access data memory and use our  outputs from  exec, and control
    input clk, rst, err, isHalt;
    input mem_read, mem_write;

    input [15:0] mem_data2, alu_data;

    output [15:0] memOut;

//Data memory
memory2c memory(.data_out(memOut), .data_in(mem_data2), .addr(alu_data), .enable(mem_read), .createdump(err|isHalt), .wr(mem_write), .clk(clk), .rst(rst));
   
endmodule

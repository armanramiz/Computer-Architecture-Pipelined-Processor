//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: ifetch.v
//Instruction fetch stage :  Contains a instruction memory, adder (plus 2) for PC and a PC register file
module ifetch(clk, rst, halt, branch, newPC, nextPc, instruction, stall);
    input clk, rst, halt, branch, stall;
    input [15:0] newPC;

    output [15:0] instruction, nextPc;

    wire haltEn;
    wire [15:0] newPc, PC, PC_plus2, newPC_TEMP, instr, GetInstruction, PCup;
    wire dummy, dummy2;
		
	assign PCup = (branch) ? newPC : PC;
    assign newPC_TEMP = (stall) ? PCup : PC_plus2;
	
	//obtain the current value of PC, accounting for stall and halt
    register16 pcReg(.clk(clk), .rst(rst), .write_en( ~halt | ~stall), .write_data(newPC_TEMP), .read_data(PC));
	
	//obtain instruction from memory unit, will be used against stall. Uses current PC (for the case when we insert NOP after a halt)
    memory2c MEM_4Instruction(.data_out(GetInstruction), .data_in(16'h0), .addr(PCup), .enable(1'h1), .wr(1'h0), .createdump(1'h0), .clk(clk), .rst(rst));
	//Obtain pc +2, test for stall
	CLA_16Adder pc_plus2(.A(PCup), .B(16'h2), .sign(dummy), .Cin(1'h0), .Out(PC_plus2), .Of1(dummy2));


register16 PCREG(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(newPC_TEMP), .read_data(nextPc));
register16 INSRREG(.clk(clk), .rst(rst), .write_en(~stall), .write_data(GetInstruction), .read_data(instr));
	//test for NOP and reset condition
  assign instruction = (PC == 16'h0 | branch) ? 16'h0800 : instr;

endmodule
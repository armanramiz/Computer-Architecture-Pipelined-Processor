//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: ifetch.v
//Instruction fetch stage :  Contains a instruction memory, adder (plus 2) for PC and a PC register file

module ifetch (clk, rst, PC, PCplus2, instruction);


    input clk, rst;
    input [15:0] PC;//default pc
	//nextPC is result of write data
    output [15:0] instruction, PCplus2;//Pincr will hold pc_plus_2
    //wire[15:0] currentPC;
    wire dummy, dummy2;
   
   //GET THE INITIAL PC ADDRESS, CHECK HALT
  // register16 pcReg(.clk(clk), .rst(rst), .write_en(~isHalt), .write_data(nextPC), .read_data(PC));


    //GET PC PLUS 2 IF WE HAVE NOT HALTED
   CLA_16Adder pc_plus2(.A(PC), .B(16'h2), .sign(dummy), .Cin(1'h0), .Out(PCplus2), .Of1(dummy2));

  // assign branchPC = halt ? currentPC : nextPc;

  //get the relevant address of the instruction from the current PC
   memory2c iMem(.data_out(instruction), .data_in(16'h0), .addr(PC), .enable(1'h1), .wr(1'h0), .createdump(1'h0), 
      .clk(clk), .rst(rst));



  
endmodule



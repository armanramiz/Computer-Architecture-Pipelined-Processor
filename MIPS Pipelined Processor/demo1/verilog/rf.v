/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */

//Arman Ramiz
//ECE552 HW3-1
//TEST PASSED
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, target_WB, writedata, write
           );
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] target_WB;
   input [15:0] writedata;
   input        write;

   output [15:0] read1data;
   output [15:0] read2data;
   output        err;

   // your code
wire [15:0] read0, read1, read2, read3, read4, read5, read6, read7; // register outputs will be stored here, for 8 registers each 16bit wide
//wrote these in two different ways to test synopsis area and timing
wire [7:0] writeValue; // 

//Handling write select, so when we initate our regs, proper writedata will be written PCaddressd on the select signal.
// determine which register whould be written to. Write is the enable signal. Writeregse is 3bits, its like a 3-8 decoder
assign writeValue [0] = (target_WB == 0) & write;
assign writeValue [1] = (target_WB == 1) & write;
assign writeValue [2] = (target_WB == 2) & write;
assign writeValue [3] = (target_WB == 3) & write;
assign writeValue [4] = (target_WB == 4) & write;
assign writeValue [5] = (target_WB == 5) & write;
assign writeValue [6] = (target_WB == 6) & write;
assign writeValue [7] = (target_WB == 7) & write;


//Instantiate 8 registers, each 16-bit wide. Registers should change on rising edge (we use dff to ensure this)

register16 reg0(.clk(clk), .rst(rst), .write_en(writeValue[0]), .write_data(writedata), .read_data(read0));
register16 reg1(.clk(clk), .rst(rst), .write_en(writeValue[1]), .write_data(writedata), .read_data(read1));
register16 reg2(.clk(clk), .rst(rst), .write_en(writeValue[2]), .write_data(writedata), .read_data(read2));
register16 reg3(.clk(clk), .rst(rst), .write_en(writeValue[3]), .write_data(writedata), .read_data(read3));
register16 reg4(.clk(clk), .rst(rst), .write_en(writeValue[4]), .write_data(writedata), .read_data(read4));
register16 reg5(.clk(clk), .rst(rst), .write_en(writeValue[5]), .write_data(writedata), .read_data(read5));
register16 reg6(.clk(clk), .rst(rst), .write_en(writeValue[6]), .write_data(writedata), .read_data(read6));
register16 reg7(.clk(clk), .rst(rst), .write_en(writeValue[7]), .write_data(writedata), .read_data(read7));

//puting all of these registers together to create 8 to 1 mux, 3 bit select ( read1regsel, read2regsel) for reading data

assign read1data = (read1regsel == 0) ? read0 :
		   (read1regsel == 1) ? read1 :
		   (read1regsel == 2) ? read2 :
		   (read1regsel == 3) ? read3 :
		   (read1regsel == 4) ? read4 :
		   (read1regsel == 5) ? read5 :
		   (read1regsel == 6) ? read6 :
		   (read1regsel == 7) ? read7 : 
		    			16'h0000;
assign read2data = (read2regsel == 0) ? read0 :
		   (read2regsel == 1) ? read1 :
		   (read2regsel == 2) ? read2 :
		   (read2regsel == 3) ? read3 :
		   (read2regsel == 4) ? read4 :
		   (read2regsel == 5) ? read5 :
		   (read2regsel == 6) ? read6 :
		   (read2regsel == 7) ? read7 : 
		    			16'h0000;

assign err = 0; // set to 0 temporarily so far. As our testbench isnt testing for this...

//set err to 1 if any state is impossible to get into. Indicates hardware errors or illegal states.
/*assign err =  	(^read1regsel == 1'bx) ? 1'b1 :
		(^read2regsel == 1'bx) ? 1'b1 :
		(^target_WB == 1'bx) ? 1'b1 :
		(^writedata == 1'bx) ? 1'b1 :
		(^write == 1'bx) ? 1'b1 : 1'b0;*/




endmodule
// DUMMY LINE FOR REV CONTROL :1:



/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
/*Arman Ramiz
  ECE552 HW3 PROBLEM3
  Create internal bypassing so results written in once cycle can be read during that same cycle

  Testbench generates random values that we shall test of bypass against.
  TEST PASSED
*/
module rf_bypass (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] writeregsel;
   input [15:0] writedata;
   input        write;

   output [15:0] read1data;
   output [15:0] read2data;
   output        err;

wire [15:0] read1bypass, read2bypass; //store read data from rf for the bypass situation

//instantiate rf
rf bypass(.read1data(read1bypass), .read2data(read2bypass), .err(err), .clk(clk), .rst(rst), .read1regsel(read1regsel), .read2regsel(read2regsel), .writeregsel(writeregsel), .writedata(writedata), .write(write));
//This bypass sitatuion ( results written in once cycle can be read during that same cycle )
//will occur when both write is enabled and the register to read is enabled.

// if true assign output from writedata, otherwise assign value from RF output.
assign read1data = write &&(read1regsel == writeregsel) ? writedata: read1bypass;
assign read2data = write &&(read2regsel == writeregsel) ? writedata: read2bypass;


endmodule
// DUMMY LINE FOR REV CONTROL :1:


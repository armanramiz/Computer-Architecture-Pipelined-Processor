module register16(clk, rst, write_en, write_data, read_data);

parameter SIZE = 16;

input clk, rst, write_en;
input [SIZE-1:0] write_data;// store data on write enable=1
output [SIZE-1:0] read_data; //stored data

wire[SIZE-1:0] in_signal;

assign in_signal = write_en ? write_data : read_data; // works like a 2 to 1 mux for selecting write or read data

dff reg16bits[SIZE-1:0] (.q(read_data), .d(in_signal), .clk(clk), .rst(rst)); // this will initiate this 16 times, for 16bits. This is for when we select read data.

endmodule
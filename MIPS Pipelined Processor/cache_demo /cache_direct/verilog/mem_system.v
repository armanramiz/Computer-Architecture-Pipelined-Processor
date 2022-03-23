/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output  Done;
   output Stall;
   output CacheHit;
   output err;
// your code here


reg [15:0]next_state, data_in_cache, addr_mem, DataOut, data_in_mem;
wire[15:0]state, data_out_cache, data_out_mem;
wire hit,dirty,valid;
reg RD_mem, WR_mem, comp, enable, valid_in,WR_cache, Stall, Done, CacheHit;
wire[4:0] tag_out;
reg [4:0] tag_in;
reg [7:0] index;
reg [2:0] offset;
 

wire stall;
assign stall = Stall; // fix the issue of assigning stall to memory
  
wire [3:0] busy;//dummy
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;  
   cache #(0 + memtype) c0(//outputs
                          .tag_out              (tag_out),
                          .data_out             (data_out_cache),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_in),
                          .index                (index),
                          .offset               (offset),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (WR_cache),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (data_out_mem),
                     .stall             (stall),
                     .busy              (busy),
                     .err               (err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (addr_mem),
                     .data_in           (data_in_mem),
                     .wr                (WR_mem),
                     .rd                (RD_mem));

   
  
localparam IDLE = 4'b0000; //0

localparam RD_COMP = 16'h1000; //1.1
localparam WR_COMP = 16'h2000; //1.2
localparam RD_HIT = 4'b0010; // 2
localparam WR_HIT = 4'b0011; // 3

localparam MISS = 4'b0100; // 4

localparam EVICT1 = 4'b0101; // 
localparam EVICT2 = 4'b0110; // 
localparam EVICT3 = 4'b0111; // 
localparam EVICT4 = 4'b1000; // 
localparam LOAD_MEM = 4'b1100; // 
localparam LOAD_MEM1= 4'b1101; // 
localparam LOAD_MEM2 = 4'b1110; // 
localparam LOAD_MEM3 = 4'b1111; // 
localparam LOAD_MEM3_1 = 4'b1001; // 
localparam LOAD_MEM3_2 = 4'b1010; // 
localparam RD_WR = 4'b1011; // 
localparam RD_COMP1 = 16'h0011; // 
localparam WR_COMP1 =  16'h0012; // 

//state reg for the SM implementations
register16 statereg (.clk(clk), .rst(rst), .write_en(1'b1),.write_data(next_state), .read_data(state));

  always@(*)begin
	next_state = IDLE;
    addr_mem  =16'h0000;  
    DataOut = 16'h0000;
	data_in_cache = 16'h0000;
    data_in_mem = 16'h0000;	
	tag_in = Addr[15:11];
    index = Addr[10:3];
    offset = Addr[2:0];
	RD_mem = 1'b0;
    WR_mem = 1'b0;       
    CacheHit = 0;
    WR_cache = 0;
	valid_in = 1'b0;
	Stall = 0;
    Done = 0;
	
    case (state) //get the current state from next state register! important	
      IDLE:	
      begin
        enable = (Rd)? 1'b1:1'b0;
		next_state = (Wr)? WR_COMP: (Rd)? RD_COMP : IDLE;
        data_in_cache = DataIn;
        Stall = 1'b0;
      end
      	
	//COMPARE READ
     RD_COMP:			
      begin
        next_state = (hit&Rd)? RD_HIT: MISS;      		   
        enable = 1'b1;
        comp = 1'b1;       
        data_in_cache = DataIn;    
		Stall = 1'b1;
      end
	  
	  //COMPARE WRITE 
	  WR_COMP:				
      begin
        next_state = (hit&Wr)? WR_HIT: MISS;
        enable = 1'b1;
        comp = 1'b1;
        WR_cache = Wr;
        data_in_cache = DataIn;
		Stall = 1'b1;
      end
	  
	  //READ HIT FOUND
      RD_HIT:
      begin
        enable = 1'b1;
        DataOut = (valid)? data_out_cache: data_in_cache;
        Done = valid;
        next_state = (valid)? RD_COMP:LOAD_MEM;
        CacheHit = valid;
		Stall = 1'b1;
      end
      
	  //WRITE HIT FOUND
	  //Load from memory if miss
      WR_HIT:		
      begin
        next_state = (valid)? WR_COMP:LOAD_MEM;
        Done = valid;
        CacheHit = valid;
		Stall = 1'b1;
      end
      
	  //MISS READ OR WRITE
	  //evict or writeback
      MISS:	
      begin
        next_state = (valid&dirty)? EVICT1:LOAD_MEM;
		Stall = 1'b1;
      end
      	  //EVICT THE CACHE TO MEM, INCREMENT OFFSET BELOW
      EVICT1:
      begin
			WR_mem = 1'b1;
			offset = 3'b000;
			addr_mem = {{tag_out},{Addr[10:3]},{offset}};			
			comp = 1'b0;
			WR_cache = 1'b0;
			data_in_mem = data_out_cache;
			next_state =  EVICT2;
			Stall = 1'b1;
      end
	  
      //EVICT THE CACHE TO MEM
      EVICT2:
      begin
			WR_mem = 1'b1;
			offset = 3'b010;
			addr_mem = {{tag_out},{index},{offset}};			
			comp = 1'b0;
			WR_cache = 1'b0;
			data_in_mem = data_out_cache;
			next_state = EVICT3;
			Stall = 1'b1;
      end
      
	  //EVICT THE CACHE TO MEM
      EVICT3:	
      begin
	  
			WR_mem = 1'b1;
			offset = 3'b100;
			addr_mem = {{tag_out},{index},{offset}};			
			comp = 1'b0;
			WR_cache = 1'b0;
			data_in_mem = data_out_cache;
			next_state = EVICT4;
			Stall = 1'b1;
      end
      
	  //EVICT THE CACHE TO MEM
      EVICT4:		
      begin
			offset = 3'b110;
			WR_mem = 1'b1;
			addr_mem = {{tag_out},{index},{offset}};			
			comp = 1'b0;
			WR_cache = 1'b0;
			data_in_mem = data_out_cache;
			next_state = LOAD_MEM;
			Stall = 1'b1;
      end      
	  
	  //LOAD FROM MEM, OFFSET =0
      LOAD_MEM:		
      begin
	    offset = 3'b000;
        RD_mem = 1'b1;
        addr_mem = {Addr[15:3],offset};
        next_state = LOAD_MEM1;
		Stall = 1'b1;
      end
      
	  //LOAD MEM WITH OFFSET =2
      LOAD_MEM1:	//mem read
      begin
		offset = 3'b010;
        RD_mem = 1'b1;
        addr_mem = {{Addr[15:3]},offset};
        next_state = LOAD_MEM2;
		Stall = 1'b1;
      end
      
	  //LOAD MEM WITH OFFSET =4
      LOAD_MEM2:				
		begin
			RD_mem = 1'b1;
			offset = 3'b100;//fixed load early issue
			addr_mem = {{Addr[15:3]},offset};
			offset = 3'b000;
			comp = 1'b0;
			WR_cache = 1'b1;
			valid_in = 1'b1;
			data_in_cache = data_out_mem;
			next_state = LOAD_MEM3;
			Stall = 1'b1;
      end
      
	  //LOAD MEM WITH OFFSET =6
      LOAD_MEM3:			
      begin
			RD_mem = 1'b1;
			offset = 3'b110;//fixed load early issue
			addr_mem = {{Addr[15:3]},offset};
			offset = 3'b010;
			comp = 1'b0;
			WR_cache = 1'b1;
			valid_in = 1'b1;
			data_in_cache = data_out_mem;
			next_state = LOAD_MEM3_1;
			Stall = 1'b1;
      end
      
      //COMP IS 0, [2:1] =10
      LOAD_MEM3_1:
      begin		
			offset = 3'b100;			
			addr_mem = {{Addr[15:3]},offset};
			RD_mem = 1'b1;
			comp = 1'b0;
			WR_cache = 1'b1;
			valid_in = 1'b1;
			data_in_cache = data_out_mem;
			next_state = LOAD_MEM3_2;
			Stall = 1'b1;
      end
      
	  //COMP IS 0, [2:1] =11
      LOAD_MEM3_2:
      begin
			offset = 3'b110;
			addr_mem = {{Addr[15:3]},offset};
			data_in_cache = data_out_mem;
			RD_mem = 1'b1;			
			comp = 1'b0;		
			WR_cache = 1'b1;
			valid_in = 1'b1;						
			Stall = 1'b1;
			next_state = RD_WR;
		
      end
      
	  //go to compara read or compare write
      RD_WR:	
      begin			
			comp = 1'b1;
			WR_cache = Wr;
			RD_mem = 1'b1;
			data_in_cache = DataIn;
			Stall = 1'b1;
			next_state = (Wr&~Rd)? WR_COMP1:(~Wr&Rd)? RD_COMP1: IDLE;
			
      end
	  	
	//COMP RD1 FINAL	BACK TO IDLE(DONE ASSERTED)
      RD_COMP1:	
      begin		  
			DataOut = (valid)? data_out_cache:16'h0000;
			Done = valid;
			CacheHit = 1'b0;
			Stall = 1'b1;
      end
      
	  //COMP WR1 	BACK TO IDLE(DONE ASSERTED)
      WR_COMP1:
      begin
			WR_cache = Wr;
			Done = valid;
			CacheHit = 1'b0;
			DataOut = (valid)? data_out_cache:16'h0000;
			Stall = 1'b1;
      end
	  
     
      default:
        next_state = IDLE ;
      endcase
        
 end       
                   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:

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
   
   output  [15:0] DataOut;
   output  Done;
   output  Stall;
   output  CacheHit;
   output  err;
 // your code here
 
  reg [15:0] addr_mem, data_in_cache,data_in_mem, next_state, DataOut;
  wire[15:0] data_out_cache0, data_out_cache1, data_out_mem, state;
  wire hit, hit_c0, hit_c1, valid_c0, valid_c1, dirty_c0,dirty_c1, victim, victim_State;
  reg  comp, enable, valid_in, WR_cache0, WR_cache1, selCache0, selCache1, 
	   RD_mem, WR_mem, CacheHit, Stall, Done;
  //wire [2:0] offset; 
  reg [4:0] tag_in, tag_out; 
  wire[4:0] tag_out_c0, tag_out_c1;
  reg [7:0] index;
  reg[2:0] offset;
  wire[3:0] busy;
  wire[2:0] off_c0, off_c1;
  
 
 assign off_c0 = {offset[2:1], {1'b0}};//FINALY. Avoid wire loop for the err bit inside the offset!
 assign off_c1 = {offset[2:1], {1'b0}};

  assign stall = Stall; // fix the issue of assigning stall to memory
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */	
   parameter memtype = 0;
   
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_c0),
                          .data_out             (data_out_cache0),
                          .hit                  (hit_c0),
                          .dirty                (dirty_c0),
                          .valid                (valid_c0),
                          .err                  (err),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_in),
                          .index                (index),
                          .offset               (off_c0),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (WR_cache0),
                          .valid_in             (valid_in));
						  
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_c1),
                          .data_out             (data_out_cache1),
                          .hit                  (hit_c1),
                          .dirty                (dirty_c1),
                          .valid                (valid_c1),
                          .err                  (err),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_in),
                          .index                (index),
                          .offset               (off_c1),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (WR_cache1),
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


assign victim_State = (valid_in) ? 1'h0 :(Rd|Wr) ? ~victim : victim; 

register16 #(.SIZE(1))VICTIM(.clk(clk), .rst(rst), .write_en(1'b1), .write_data(victim_State), .read_data(victim));

assign hit = hit_c1 | hit_c0;
assign valid = valid_c0 | valid_c1;


register16 statereg (.clk(clk), .rst(rst), .write_en(1'b1),.write_data(next_state), .read_data(state));

  always@(*)begin
    next_state = IDLE;
	addr_mem  =16'h0000;
	DataOut = 16'h0000;
	data_in_cache = 16'h0000;
	data_in_mem = 16'h0000;	
    tag_in = Addr[15:11];
    index = Addr[10:3];
	offset =  Addr[2:0]; 
    RD_mem = 1'b0;
    WR_mem = 1'b0;
    CacheHit = 1'b0;
    WR_cache0 = 1'b0;
    WR_cache1 = 1'b0;  
	valid_in = 1'b0;
	Stall = 1'b0;	
	Done = 0;	 

    case (state)//get the current state from next state register! important
      IDLE:	
      begin       
	    next_state = (Wr)? WR_COMP: (Rd)? RD_COMP : IDLE;
        enable = (Rd)? 1'b1:1'b0;
		selCache0 = (~valid)?1'b1:(valid & ~victim)?1'b1:1'b0;	//determine active caches at the IDLE					
        selCache1 = (~valid)?1'b0:(valid & victim)?1'b1:1'b0;	//determine active caches at the IDLE	
        comp = 1'b1;	
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
		WR_cache0 = Wr&hit;
        WR_cache1 = Wr&hit;
		data_in_cache = DataIn;
		Stall = 1'b1;
      end
	    	  
      //READ HIT FOUND
      RD_HIT:		
      begin
		next_state = ((hit_c0&valid_c0)|(hit_c1&valid_c1))? IDLE:LOAD_MEM;
        enable = 1'b1;
		DataOut = (hit_c0&valid_c0)? data_out_cache0: (hit_c1&valid_c1)? data_out_cache1: DataOut;
		Done = (valid_c0 &hit_c0) | (valid_c1 &hit_c1) ;		
		CacheHit = valid;					 
		Stall = 1'b1;
      end
	    
	  //WRITE HIT FOUND
	  //Load from memory if miss
      WR_HIT:
      begin
        next_state = ((hit&valid_c0)|(hit&valid_c1))? IDLE:LOAD_MEM;
        Done = valid;
        CacheHit = valid;       			 
		Stall = 1'b1;   
      end
      	  
	  //MISS READ OR WRITE. CHECK DIRTY BIT FOR EVICT FOR LOAD MEM
	  //evict or writeback
      MISS:				
      begin
        next_state = ((selCache0& dirty_c0)|(selCache1&dirty_c1))?EVICT1:LOAD_MEM; 
		Stall = 1'b1;
      end
	  	  
	  //EVICT THE CACHE TO MEM, INCREMENT OFFSET BELOW
      EVICT1:
      begin
        WR_mem = 1'b1;
		offset = 3'b000;
		comp = 1'b0;
        tag_out = (selCache0)? tag_out_c0: (selCache1)? tag_out_c1: 5'h00;
        addr_mem = {{tag_out},{Addr[10:3]},{3'b000}};
        data_in_mem = (selCache0)?data_out_cache0:(selCache1)? data_out_cache1: data_in_mem;
        next_state = EVICT2;
		Stall = 1'b1;
      end
	  
      //EVICT THE CACHE TO MEM
      EVICT2:
      begin
        WR_mem = 1'b1;
		offset = 3'b010;
		comp = 1'b0;
		tag_out = (selCache0)? tag_out_c0: (selCache1)? tag_out_c1: 5'h00;
		addr_mem = {{tag_out},{index},{3'b010}};
        data_in_mem = (selCache0)?data_out_cache0: (selCache1)?data_out_cache1: data_in_mem;
        next_state = EVICT3;
		Stall = 1'b1;
      end
	  
      //EVICT THE CACHE TO MEM
      EVICT3:				
      begin
        WR_mem = 1'b1;
		offset = 3'b100;
		comp = 1'b0;
		tag_out = (selCache0)? tag_out_c0: (selCache1)? tag_out_c1: 5'h00;
		addr_mem = {{tag_out},{index},{3'b100}};
        data_in_mem = (selCache0)?data_out_cache0: (selCache1)?data_out_cache1: data_in_mem;
        next_state = EVICT4;
		Stall = 1'b1;
      end
      
	  //EVICT THE CACHE TO MEM
      EVICT4:				
      begin
        WR_mem = 1'b1;
		offset = 3'b110;
		comp = 1'b0;
		tag_out = (selCache0)? tag_out_c0: (selCache1)? tag_out_c1: 5'h00;
		addr_mem = {{tag_out},{index},{3'b110}};
        data_in_mem = (selCache0)?data_out_cache0: (selCache1)?data_out_cache1: data_in_mem;
        next_state = LOAD_MEM;
		Stall = 1'b1;
      end
      	  
	  //LOAD FROM MEM, OFFSET =0
      LOAD_MEM:		
      begin
	    offset = 3'b000;
        RD_mem = 1'b1;
        addr_mem = {Addr[15:3],{3'b000}};
        next_state = LOAD_MEM1;
		Stall = 1'b1;
      end
      
	  //LOAD MEM WITH OFFSET =2
      LOAD_MEM1:	
      begin
		offset = 3'b010;
        RD_mem = 1'b1;
        addr_mem = {{Addr[15:3]},{3'b010}};
        next_state = LOAD_MEM2;
		Stall = 1'b1;
      end
	  
      //LOAD MEM WITH OFFSET =4
      LOAD_MEM2:			
      begin
        RD_mem = 1'b1;
		//offset = 3'b100;//fixed load early issue
        addr_mem = {{Addr[15:3]},{3'b100}};
        offset = 3'b000;
        comp = 1'b0;	
        WR_cache0 = (selCache0) ? 1:0;
        WR_cache1 = (selCache1) ? 1:0;
        valid_in = 1'b1;
        data_in_cache = data_out_mem;
        next_state = LOAD_MEM3;
		Stall = 1'b1;
      end
      
	  //LOAD MEM WITH OFFSET =6
      LOAD_MEM3:				
      begin
		RD_mem = 1'b1;
		//offset = 3'b110;//fixed load early issue
        addr_mem = {{Addr[15:3]},{3'b110}};
        offset = 3'b010;
        comp = 1'b0;
        WR_cache0 = (selCache0) ? 1:0;
        WR_cache1 = (selCache1) ? 1:0;
        valid_in = 1'b1;
        data_in_cache = data_out_mem;
        next_state = LOAD_MEM3_1;
		Stall = 1'b1;
      end
      
      
      //COMP IS 0, [2:1] =10
      LOAD_MEM3_1:
      begin	  
		offset = 3'b100;
        addr_mem = {{Addr[15:3]},{3'b100}};
        RD_mem = 1'b1;
        comp = 1'b0;
        WR_cache0 = (selCache0) ? 1:0;
        WR_cache1 = (selCache1) ? 1:0;
        valid_in = 1'b1;
        data_in_cache = data_out_mem;
        next_state = LOAD_MEM3_2;
		Stall = 1'b1;
      end
	  
	  //COMP IS 0, [2:1] =11
      LOAD_MEM3_2:
      begin
		offset = 3'b110;
        addr_mem = {{Addr[15:3]},{3'b110}};
		data_in_cache = data_out_mem;
        RD_mem = 1'b1;
        comp = 1'b0;
        WR_cache0 = (selCache0) ? 1:0;
        WR_cache1 = (selCache1) ? 1:0;
        valid_in = 1'b1;
        Stall = 1'b1;
        next_state = RD_WR;		
      end
      
	  //go to compare read or compare write
      RD_WR:				
      begin
        RD_mem = 1'b1;
        comp = 1'b1;
		offset = Addr[2:0];
        WR_cache0 = (selCache0) ? Wr:0;
        WR_cache1 = (selCache1) ? Wr:0;
        data_in_cache = DataIn;
		Stall = 1'b1;
		next_state = (Wr&~Rd)? WR_COMP1:(~Wr&Rd)? RD_COMP1: IDLE;
				 
      end
	  
	 //COMP Read. go to IDLE FOR DONE
     RD_COMP1:			  
      begin       
        DataOut = (selCache0)? data_out_cache0: (selCache1)? data_out_cache1:DataOut;
        Done = valid;
        CacheHit = 1'b0;
		Stall = 1'b1;
      end
      
	  //COMP WRITE. go to IDLE FOR DONE
      WR_COMP1:				
      begin
        WR_cache0 = (selCache0) ? Wr:0;
        WR_cache1 = (selCache1) ? Wr:0;
        Done = valid;
        CacheHit = 1'b0;
        DataOut = (selCache0)? data_out_cache0: (selCache1)? data_out_cache1: DataOut;
		Stall = 1'b1;
      end

      default:
        next_state = IDLE;
      endcase
        
 end       
           
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
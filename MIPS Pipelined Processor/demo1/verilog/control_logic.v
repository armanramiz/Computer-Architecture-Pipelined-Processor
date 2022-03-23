//Author: ARMAN RAMIZ
//Class: ECE 552 Computer Architecture, File: control_logic.v
//Control Logic: Produce the relevant control signals PCaddressd on the instruction opcode and func

module control_logic(opCode, func, halt, sign, pcOffSel, reg_wrt, mem_write, memToReg, mem_read, jump, invA, invB, ALUselB, err,
    RegDstSel, Sel_WBreg, ALUOp, jump_back, cin, branchSel, alu_result);
	
	input [4:0] opCode;
    	input[1:0] func;
	//control signals for operations 
 
	//used in ALU operations
	output reg invA, invB,  sign, cin;

	//Used in nextPC calculation (also BrancSel)
	output reg halt, jump, jump_back, pcOffSel;

	//reg wrt is like an enable signal, is mem being read? used in the first memory unit
	//mem_write is the wr input for memory2c, is mem being written to?
	//memToReg will become usefull in the pipelining feature
	//mem_read is the enable signal for memory unit, used in the final memory unit
	output reg  reg_wrt, mem_write, memToReg, mem_read, err;

	//Usefull in selecting the correct and final alu data
	output reg [1:0] alu_result;

	// RegDstSel is used to select the target register for the write_back, Sel_WBreg is used for the final write back mux
    	output reg [1:0] RegDstSel, Sel_WBreg;

	// Selecting what ALU operation to perform from the alu.v
    	output reg [3:0] ALUOp;
	
	//Used in selecting alu B input (also its relevant sign extension) and branch pc address
    	output reg [2:0] ALUselB, branchSel;


								//WISCSP-13 ISA\\

    // I-1 TYPE INSTURCTIONS
    localparam 		ADDI = 		5'b01000;
    localparam 		SUBI = 		5'b01001;
    localparam		XORI = 		5'b01010;
    localparam 		ANDNI = 	5'b01011;
    localparam 		ROLI = 		5'b10100;
    localparam 		SLLI = 		5'b10101;
    localparam 		RORI = 		5'b10110;
    localparam 		SRLI = 		5'b10111;  

    //MEM INSTRUCTIONS (NOT ALU)
    localparam 		ST = 		5'b10000;
    localparam 		LD = 		5'b10001;
    localparam 		STU = 		5'b10011;
    
     //R-TYPE INSTRUCTIONS IN ORDER
    localparam 		BTR = 		5'b11001;
    localparam 		ALU1 = 		5'b11011; // Will use a mux to decide this: ADD, SUB, XOR, ANDN
    localparam 		ALU2 =	 	5'b11010; // covers: ROL, SLL, ROR, SRL,
    localparam 		SEQ = 		5'b11100;
    localparam 		SLT = 		5'b11101;
    localparam 		SLE = 		5'b11110;
    localparam 		SCO = 		5'b11111;

    
    //I-2 TYPE BRANCH INSTRUCTIONS
    localparam 		BEQZ = 		5'b01100;
    localparam 		BNEZ = 		5'b01101;
    localparam 		BLTZ = 		5'b01110;
    localparam 		BGEZ = 		5'b01111;
    localparam 		LBI = 		5'b11000;
    localparam 		SLBI = 		5'b10010;

    //J (JUMP) TYPE INSTRUCTIONS
    localparam 		J = 		5'b00100;
    localparam 		JR = 		5'b00101;
    localparam 		JAL = 		5'b00110;
    localparam 		JALR = 		5'b00111;

    // PROBLEM INSTRUCTIONS- NO LIKE
    localparam 		SIIC = 		5'b00010; // Produce llegalOp
    localparam 		RTI = 		5'b00011; //nop, pc <-Exisitng PC	
    localparam 		HALT = 		5'b00000;
    localparam 		NOP = 		5'b00001;


    localparam ADD = 2'h0;
    localparam SUB = 2'h1;
    localparam XOR = 2'h2;
    localparam ANDN = 2'h3;

    localparam ROL = 2'h0;
    localparam SLL = 2'h1;
    localparam ROR = 2'h2;
    localparam SRL= 2'h3;


/////////////////////////////////////////////////////BEGIN INSTRUCTION DECODINGS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
always@* begin
//AVOID UNINTENTIONAL LATCHES
	halt = 0;
    	sign = 1'h0;
    	pcOffSel = 1'h0;
    	reg_wrt = 0;
    	mem_write = 0;
    	memToReg = 0; // needed? only for pipeline?
    	mem_read = 0;
    	jump = 0;
    	jump_back  = 0;
    	invA = 0;
    	invB = 0;
    	RegDstSel = 0;
    	Sel_WBreg = 0;
    	ALUOp = 0;
    	err = 0;
        cin = 1'h0;
        ALUselB = 0;
        branchSel = 0;
	alu_result = 0;
   case(opCode)
//////////////////////////////////////////////////I-1  TYPE INSTRUCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!
	ADDI: begin//ADDI INSTRUCTION DOES	
		ALUselB = 3'h2;
                ALUOp = 4'h4;	
	 	sign = 1'h1;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

		end


	SUBI: begin//SUBI INSTRUCTION DOES
		ALUselB = 3'h2;
                ALUOp =4'h4;
		sign = 1'h1;
                invA = 1'h1;
                invB = 1'h0;
                cin = 1'h1;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
		jump = 1'h0;
                jump_back = 1'h0;

		end

	XORI: begin//XORI INSTRUCTION DOES
		ALUselB = 3'h3;
                ALUOp = 4'h6;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
		sign = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

				 end

	ANDNI: begin//ANDI INSTRUCTION DOES
		ALUselB = 3'h3;
                ALUOp = 4'h7;
		invA = 1'h0;
                invB = 1'h1;
                cin = 1'h0;
		sign = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

				 end

	ROLI: begin//ROLI INSTRUCTION DOES
		ALUselB = 3'h3;
                ALUOp = 4'h0;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
		//sign = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

				 end

	SLLI: begin//SLLI INSTRUCTION DOES
		ALUselB = 3'h3;
                ALUOp = 3'h1;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
		//sign = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

    
				 end

	RORI: begin//RORI INSTRUCTION DOES
		ALUselB = 3'h3;
                ALUOp = 4'h2;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
		//sign = 1'hx;

                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;

				 end

	SRLI: begin//SRLI INSTRUCTION DOES
	       ALUselB = 3'h3;
                ALUOp = 4'h3;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

		//sign = 1'hx;
                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;
               
				 end


//////////////////////////////////////////////////MEM INSTRUCTIONS LOAD, STORE, STORE UNSIGNED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

	ST: begin//ST INSTRUCTION DOES

		  ALUselB = 3'h2;
                  ALUOp = 4'h4;
		  invA = 1'h0;
                  invB = 1'h0;
                 cin = 1'h0;

		//sign = 1'h0;
                reg_wrt = 1'h0;
                RegDstSel = 2'hx;
                Sel_WBreg = 3'hx;
		alu_result = 0;
                mem_write = 1'h1;
                mem_read = 1'h1;

                jump = 1'h0;
                jump_back = 1'h0;
  

				 end

	LD: begin//LD INSTRUCTION DOES
		                
                ALUselB = 3'h2;
                ALUOp = 4'h4;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

		sign = 1'hx;
                reg_wrt = 1'h1;
                RegDstSel = 2'h0;
                Sel_WBreg = 3'h0;
		alu_result = 0;
                mem_write = 1'h0;
                mem_read = 1'h1;

                jump = 1'h0;
                jump_back = 1'h0;
				 end

	STU: begin//STU INSTRUCTION DOES
		 ALUselB = 3'h2;
                ALUOp = 4'h4;
		invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

		sign = 1'h1;
                reg_wrt = 1'h1;
                RegDstSel = 2'h1;
                Sel_WBreg = 3'h1;
		alu_result = 0;
                mem_write = 1'h1;
                mem_read = 1'h1;

                jump = 1'h0;
                jump_back = 1'h0;
  

				 end

					
///////////////////////////////////////////////////////////R TYPE INSTRUCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

	BTR: begin//BTR INSTRUCTION DOES
		ALUselB = 3'h4;
                ALUOp = 4'hC;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;
			
		reg_wrt = 1'h1;
                RegDstSel = 2'h2;
                Sel_WBreg = 3'h1;
                
                mem_write = 1'h0;
                mem_read = 1'h0;
		alu_result = 0;
                jump = 1'h0;
                jump_back = 1'h0;
				 end

	ALU1: begin//ALU1 // Will use a mux to decide this: ADD, SUB, XOR, ANDN

		case(func)
			    ADD : begin
				ALUselB = 3'h4;
                		ALUOp = 3'h4;
				sign = 1'h1;
			 	invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;

                		reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
                		cin = 1'h0;
               			 mem_write = 1'h0;
                		mem_read = 1'h0;
				alu_result = 0;
                		jump = 1'h0;
                		jump_back = 1'h0;
				 end

			  SUB: begin
				
                		ALUselB = 3'h4;
               		 	ALUOp = 4'h4;
                		invA = 1'h1;
                		invB = 1'h0;
               			cin = 1'h1;
				sign = 1'h1;

               			reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
               			mem_write = 1'h0;
                		mem_read = 1'h0;
                		jump = 1'h0;
               			jump_back = 1'h0;

				end

			XOR: begin
				ALUselB = 3'h4;
                		ALUOp = 4'h6;
				invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;
				sign = 1'hx;

                		reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
               			mem_write = 1'h0;
                		mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;
				end

			ANDN: begin
                		ALUselB = 3'h4;
                		ALUOp = 4'h7;
                		invA = 1'h0;
                		invB = 1'h1;
                		cin = 1'h0;

				 sign = 1'hx;
               		 	reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
               			 mem_write = 1'h0;
               			 mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;
				end
		endcase
		end			

	ALU2: begin//ALU2 // covers: ROL, SLL, ROR, SRL,

		case(func)
			ROL: begin
                		ALUselB = 3'h4;
                		ALUOp = 4'h0;
                		invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;
				sign = 1'hx;

               			reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
                		mem_write = 1'h0;
                		mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;
				end

			SLL: begin
                		ALUselB = 3'h4;
                		ALUOp = 4'h1;
				sign = 1'hx;
                		invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;

               			 reg_wrt = 1'h1;
               			 RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
               			 mem_write = 1'h0;
               			 mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;

				end

			ROR: begin
				ALUselB = 3'h4;
                		ALUOp = 4'h2;
				invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;
				sign = 1'hx;

                		reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
                		mem_write = 1'h0;
                		mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;
				end
		
			SRL: begin
                		ALUselB = 3'h4;
                		ALUOp = 4'h3;
                		invA = 1'h0;
                		invB = 1'h0;
                		cin = 1'h0;
				sign = 1'hx;

               			reg_wrt = 1'h1;
                		RegDstSel = 2'h2;
                		Sel_WBreg = 3'h1;
				alu_result = 0;
                		mem_write = 1'h0;
               			mem_read = 1'h0;
                		jump = 1'h0;
                		jump_back = 1'h0;

				end
			endcase
		end
			
	SEQ: begin//SEQ INSTRUCTION DOES
                ALUselB = 3'h4;
                ALUOp = 4'h8;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;
		sign = 1'h1;

                reg_wrt = 1'h1;
                RegDstSel = 2'h2;
                Sel_WBreg = 3'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
		alu_result = 0;
                jump = 1'h0;
                jump_back = 1'h0;
		end

	SLT: begin//SLT INSTRUCTION DOES
                ALUselB = 3'h4;
                ALUOp = 4'h9;
                invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;
		sign = 1'h1;

                reg_wrt = 1'h1;
                RegDstSel = 2'h2;
                Sel_WBreg = 3'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
		alu_result = 0;
                jump = 1'h0;
                jump_back = 1'h0;
                invA = 1'h0;
				 end

	SLE: begin//SLE INSTRUCTION DOES
		 ALUselB = 3'h4;
                ALUOp = 4'hA;
		invA = 1'h0;
                invB = 1'h1;
                cin = 1'h1;
		sign = 1'h1;

                reg_wrt = 1'h1;
                RegDstSel = 2'h2;
                Sel_WBreg = 3'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
		alu_result = 0;
                jump = 1'h0;
                jump_back = 1'h0;

				 end

	SCO: begin//SCO INSTRUCTION DOES
                ALUselB = 3'h4;
                ALUOp = 4'hB;
		sign = 1'h0;
                invA = 1'h0;
                invB = 1'h0;
                cin = 1'h0;

                reg_wrt = 1'h1;
                RegDstSel = 2'h2;
                Sel_WBreg = 3'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
		alu_result = 0;
                jump = 1'h0;
                jump_back = 1'h0;
				 end


////////////////////////////////////////////////////////////I-2 TYPE INSTRUCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

	BEQZ: begin//BEQZ INSTRUCTION DOES
		ALUselB = 3'h5;
                ALUOp = 4'h4;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

		alu_result = 0;
                pcOffSel = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;
                branchSel = 3'h1;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;
				 end

	BNEZ: begin//BNEZ INSTRUCTION DOES
		ALUselB = 3'h5;
                ALUOp = 4'h4;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

		alu_result = 0;
                pcOffSel = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;
                branchSel = 3'h2;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;
				 end

	BLTZ: begin//BLTZ INSTRUCTION DOES
		ALUselB = 3'h5;
                ALUOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

		alu_result = 0;
                pcOffSel = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;
                branchSel = 3'h3;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;			
				 end

	BGEZ: begin//BGEZ INSTRUCTION DOES
		ALUselB = 3'h5;
                ALUOp = 4'b100;
                invA = 1'h0;
                invB = 1'h0;
                sign = 1'h1;

		alu_result = 0;
                pcOffSel = 1'h0;
                jump = 1'h0;
                jump_back = 1'h0;
                branchSel = 3'h4;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;		 
		end

	LBI: begin//LBI INSTRUCTION DOES
		reg_wrt = 1'h1;
    		RegDstSel = 2'h1;
		Sel_WBreg = 3'h1;
		ALUselB = 3'h4;
		alu_result = 2'h1;
				 end

	SLBI: begin//SLBI INSTRUCTION DOES
		reg_wrt = 1'h1;
                RegDstSel = 2'h1;
		 Sel_WBreg = 3'h1;
		ALUselB = 3'h4;
		alu_result = 2'h2;

				 end
///////////////////////////////////////////////////////////J TYPE INSTRUCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!


	J: begin//J INSTRUCTION DOES
		pcOffSel = 1'h1;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h1;
                jump_back = 1'h0;
				 end

	JR: begin//JR INSTRUCTION DOES
		pcOffSel = 1'h0;
                reg_wrt = 1'h0;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h1;
                jump_back = 1'h1;
				 end

	JAL: begin//JAL INSTRUCTION DOES
                jump_back = 1'h0;
                RegDstSel = 2'h3;
                Sel_WBreg = 3'h2;
		 pcOffSel = 1'h1;
                reg_wrt = 1'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h1;
				 end

	JALR: begin//JALR INSTRUCTION DOES
                RegDstSel = 2'h3;
                Sel_WBreg = 3'h2;
		sign = 1'h0;
                pcOffSel = 1'h0;
                reg_wrt = 1'h1;
                mem_write = 1'h0;
                mem_read = 1'h0;
                jump = 1'h1;
                jump_back = 1'h1;
              	invA = 1'h0;
                invB = 1'h0;
		 end

///////////////////////////////////////////////////////////SIC/ NOP/ RTI/ HALT/  TYPE INSTRUCTIONS\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\!

	HALT: begin//HALT INSTRUCTION DOES
			 halt = 1;
				 end
	NOP: begin//NOP INSTRUCTION DOES
			halt = 0;
       			ALUselB = 3'h4;
       			branchSel = 3'h0;
				 end

	SIIC: begin //SIIC INSTRUCTION DOES
			halt = 0;
        		ALUselB = 3'h4;
        		branchSel = 3'h0;
				 end

	RTI: begin //RTI INSTRUCTION DOES
			halt = 0;
        		ALUselB = 3'h4;
        		branchSel = 3'h0;
				 end	
	default: err=1;
	endcase
end
endmodule
//END OF CONTROL UNIT


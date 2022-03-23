//JAL 2
 // Check that r7 doesnt change
    lbi r1, 0x22
    jal .JUMP2  // r7 becomes .jal2
.DONE:
        halt
.JUMP2:
	jal  .DONE    
	lbi r1, 0x33   
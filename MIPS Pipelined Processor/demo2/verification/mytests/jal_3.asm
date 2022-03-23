//JAL 3
// Basic use of jal, Test if values of r1 and r2 will be affected( they should stay 0 )
//Jump over the two instructions
// R7 should have address of the first instrucion 01
lbi r1, 0x01
jal 2			
lbi r1, 0x23			
lbi r2, 0x54		
halt			
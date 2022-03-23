//JALR 2

lbi r0, 0x00//r0 is addr
lbi r1, 0x00// loop 
addi r1, r1, 0x0A
bgez r1, .EXIT// check jump 10 times
jalr r0, 4
.EXIT:
halt
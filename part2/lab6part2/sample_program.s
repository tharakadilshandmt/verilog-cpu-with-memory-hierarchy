loadi 0 0x09           
loadi 1 0x01
swd 0 1 //    store  9 in address 1
swi 1 0x00 // store 1 in address 0
lwd 2 1 //    store to reg 2 from address 1(9)
lwd 3 1 //    load to reg 3 from address 1(9)
sub 4 0 1 //   4()= 9-1 =reg4 =8
swi 4 0x02 // store 8 to address 2
lwi 5 0x02 // load to reg 5 from address 2(8)
swi 4 0x20 // store 8 to address 20
lwi 6 0x20 // load  reg 6 to address 20(8)
	char *op_loadi 	= "00000000";
	char *op_mov 	= "00000001";
	char *op_add 	= "00000010";
	char *op_sub 	= "00000011";
	char *op_and 	= "00000100";
	char *op_or 	= "00000101";
	char *op_j		= "00000110";
	char *op_beq	= "00000111";
	char *op_lwd 	= "00001000";
	char *op_lwi 	= "00001001";
	char *op_swd 	= "00001010";
	char *op_swi 	= "00001011";
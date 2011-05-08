/*

	z26 cpu jam handlers

 z26 is Copyright 1997-2011 by John Saeger and contributors.  
 z26 is released subject to the terms and conditions of the 
 GNU General Public License Version 2 (GPL).  z26 comes with no warranty.
 Please see COPYING.TXT for details.
*/

/*
	jam handler 
*/

void jam(void){
	AddressBus = reg_pc - 1;
	(*ReadROMAccess)();
	if(Starpath && (DataBus == 0x52)) StarpathJAM();
	else{
		srv_Cleanup();
		sprintf(msg, "JAM instruction %02x @ %04x\n", DataBus, AddressBus);
		srv_print(msg);
		exit(0);
/* TODO: find better way to display messages without exiting emulator */
	}
}

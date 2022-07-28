# ARMv2a VLSI Project
***
### Made by
[Samy Attal](https://github.com/Samy-Attal) \
[Kevin Lastra](https://github.com/kevinlastra)
## Description 
The goal of this project is to describe in VHDL the "user" execution mode of a processor implementing the ARMv2a instruction set and to go as far as the synthesis and design of the chip masks.

## Outils
- Compiler : [GHDL](https://github.com/ghdl/ghdl)
- Wave viewer : [gtkwave](http://gtkwave.sourceforge.net/)
- Logic synthetiser, automatic place and route : [Suite Alliance/Coriolis](http://coriolis.lip6.fr/) 

## Global architecture
The processor core has a four-stage pipeline: fetch, decode, exec and mem:
![plot](./images/global_architecture.png?raw=true "global_architecture")


## Simulation 
We analyze and validate the processor core with an assembler (or C) program used by a testbench and an emulation of the instruction and data caches (written in C). Here is an example: 
```armasm
/*----------------------------------------------------------------
//           test add                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:                        
	mov r0, #0                  
	adds r1, r0, r0             
	bne _bad                    
	movs r0, #0x80000000        
	bpl _bad                    
	subs r0, r0, #1             
	bmi _bad                    
	b _good                   
_bad : 
	nop                         
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
```

We visualize the execution of the instructions with gtkwave: 
![plot](./images/testbench.png?raw=true "testbench") 

## Design of the masks 
The mask design of the chip below is not optimized (being pad limited), an optimization at the level of the pads is required.
![plot](./images/chip.png?raw=true "chip")

The implementation of other execution modes (FIQ, IRQ, Supervisor...), the implementation of multiplications as well as the addition of an instruction cache and a data cache are also elements that can be considered in order to optimize the potential used surface of the processor on the silicon. 

# ARMv2a VLSI Project
***
## Description 
Le but de ce projet est de décrire en VHDL le mode d'execution "user" d'un processeur implémentant le jeu d'instructions ARMv2a et d'aller jusqu'à la synthèse et le dessin des masques d'un chip intégrant ce dernier.

## Outils
- Compilateur : [GHDL](https://github.com/ghdl/ghdl)
- Visualisateur de signaux : [gtkwave](http://gtkwave.sourceforge.net/)
- Synthèse et placement routage : [Suite Alliance/Coriolis](http://coriolis.lip6.fr/) 

## Architecture globale 
Le core du processeur possède un pipeline de quatre étages : fetch, decod, exec et mem :
![plot](./images/global_architecture.png?raw=true "global_architecture")


## Simulation 
On analyse et valide le core du processeur à l'aide d'un programme en assembleur (ou C) utilisé par un testbench et une emulation des caches d'instruction et de données (écrit en C). Voici un exemple : 
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

On visualise l'execution des instructions avec gtkwave : 
![plot](./images/testbench.png?raw=true "testbench") 

## Dessin des masques 
Le dessin des masques du chip ci dessous n'est pas optimisé (étant pad limited), une optimisation au niveau des plots est requise.
![plot](./images/chip.png?raw=true "chip")

L'implémentation des autres modes d'execution (FIQ, IRQ, Supervisor...) ainsi que les instructions de multiplication sont également des pistes envisageable afin d'optimiser la potentielle surface utilisée du processeur sur le silicium. 


; This example program declares variables and manipulate them.
; Note: Atmega328p Microcontroller only suppot BTYE and WORD types variables 
; 		there is no DIV instruction in the AVR Assembly.
;		So to perform the division we will use the the a div macro. 

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"

.dseg
.org SRAM_START
	var1:	.byte	1	; Allocate 1 BYTE in RAM (Note: this is not the value of the register)
	var2:	.byte	1
	sum:	.byte	1

.cseg
.org 0x0000

	Serial_begin		; initilize UART serial communication
	
	ldi	r16, 5
	ldi	r17, 6

	sts	var1, r16		; store r16 in variable var1
	sts	var2, r17		; store r17 in variable var2

	lds	r18, var1		; load value of var1 into r18
	lds	r19, var1+1		; another way to access var2 by offset from var1

	add r18, r19
	sts	sum, r18		; store sum into sum variable


loop:
	Serial_writeReg_ASCII r18
	Serial_writeNewLine
	delay 1000
rjmp loop




; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
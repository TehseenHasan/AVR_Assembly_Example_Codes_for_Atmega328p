; This example program generates random number between 0 to 255.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"

.cseg
.org 0x0000

	Serial_begin

	ldi R16, 0			; Start the random generator with the first seed
	ldi R17, 255		; and with the second seed

loop:
	eor	R16, R17		; Exclusive-Or with the second seed
	swap R16			; Swap nibbles
	add R17, R16		; Add result to the second seed

	; r16 = random number (0-255)
	Serial_writeReg_ASCII r16
	Serial_writeNewLine
	delay 1000
rjmp loop


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
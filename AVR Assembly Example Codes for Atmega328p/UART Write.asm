
; This example program demonstrates different macros to send data to UART from Arduin Uno.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"
.cseg
.org 0x0000

Serial_begin			; initilize UART serial communication

loop:

	; send a single character to UART
	Serial_writeChar 'A'
	
	delay 500

	; send a register value to UART
	ldi r16, 123
	Serial_writeReg_ASCII r16		; this macro send the ASCII-encoded version of 123
	
	delay 500

	; send a register value to UART
	ldi r16, 123
	Serial_writeReg r16				; this macro send the raw value 123

	delay 500

	; send a null-terminated string to the UART
	LDI ZL, LOW (2 * hello_string)
	LDI ZH, HIGH (2 * hello_string)
	Serial_writeStr

	delay 500

	; send a newline character (\n) to the UART
	Serial_writeNewLine
	
	delay 500

	; send an constant (integer array) to the UART
	LDI ZL, LOW (2 * hello_buffer)
	LDI ZH, HIGH (2 * hello_buffer)
	LDI r20, hello_buffer_len
	Serial_writeBuffer
	
	delay 500

	; send an ASCII-encoded constant integer array to the UART
	LDI ZL, LOW (2 * hello_buffer)
	LDI ZH, HIGH (2 * hello_buffer)
	LDI r20, hello_buffer_len
	Serial_writeBuffer_ASCII

	
	delay 1000
rjmp loop


; it is recommanded to define the constants (arrays, strings, etc.) at the end of the code segment
; .db directive is used to decalre constants

hello_string:	.db	"Hello World",0x0D,0x0A,0

hello_buffer:	.db	1,2,3,4,5,6
len: .equ	hello_buffer_len   = 2 * (len - hello_buffer)


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
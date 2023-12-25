
; This example program demonstrates div macro to read perform division operation.
; Note: Atmega328p Microcontroller don't suppot hardware level division that is why 
; 		there is no DIV instruction in the AVR Assembly.
;		So to perform the division we will use the the a div macro. 

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"
.cseg
.org 0x0000

Serial_begin			; initilize UART serial communication

loop:
	
	; We want to divide 100 by 5
	ldi r16, 125 		; place dividend in r16
	ldi r17, 10			; place divisor in r17
	div					; div macro

	; After executing div macro,
	; the result (quotient) will be placed in r16 and remainder in r15

	Serial_writeReg_ASCII r16	; send quotient to UART
	Serial_writeNewLine
	Serial_writeReg_ASCII r15	; send remainder to UART
	Serial_writeNewLine

	delay 1000
rjmp loop



; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
; This example program read byte data received on UART on Arduin Uno.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"
.cseg
.org 0x0000

Serial_begin			; initilize UART serial communication

loop:
	LDI r16, 0
	; Check UART serial input buffer for any incoming data and place in r16
	Serial_read
	; If there is no data received in UART serial buffer (r16==0)
	; then don't send it to UART
	CPI r16, 0
	BREQ skip_UART

	Serial_writeReg r16		; send the received data back to UART
	
	skip_UART:
rjmp loop


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
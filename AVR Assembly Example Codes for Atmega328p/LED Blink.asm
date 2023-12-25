; This example program turn on/off an LED attached to the Arduino UNO on pin number 13 (PB5)

.include "m328pdef.inc"
.include "delay_Macro.inc"
.cseg
.org 0x0000
	
	SBI DDRB, PB5		; PB5 set as an OUTPUT pin
loop:
	SBI PORTB, PB5		; PB5 pin --> HIGH (5v) --> LED ON
	delay 1000
	CBI PORTB, PB5		; PB5 pin --> LOW  (0V) --> LED OFF
	delay 1000
rjmp loop			; stay in infinite loop


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
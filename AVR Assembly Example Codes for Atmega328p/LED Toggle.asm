; This example program turn on/off an LED attached to the Arduino UNO on pin number 13 (PB5)
; Toggle means if the LED is ON then turn it OFF and vice versa.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.cseg
.org 0x0000

	SBI DDRB, PB5		; PB5 set as an OUTPUT pin
	CLR r16				; r16 = 00000000

loop:
	LDI r17, (1<<PB5)	; Set bit number 5 of r17 register (r17 = 00100000)
	EOR r16, r17		; Exclusive OR operator
	OUT PORTB, r16		; PB5 pin toggles
	delay 1000			; Delay of 1 second
rjmp loop


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
; This example program reads the state of a push button
; if the push button is pressed then turn ON the LED
; if the putton is released then turn OFF the LED

.include "m328pdef.inc"
.include "delay_Macro.inc"
.cseg
.org 0x0000

	SBI DDRB, PB5		; PB5 set as OUTPUT Pin
	CBI PORTB, PB5		; LED OFF
	CBI DDRB, PB3		; PB3 set as INPUT pin
	SBI PORTB, PB3		; Enable internal pull-up resistor
loop:
	; check if push buttong is pressed
	SBIS PINB, PB3	; if not pressed, skip next line (if the PINB register's bit number 3 is 1) 
rjmp L1
	CBI PORTB, PB5	; LED OFF			
rjmp loop

L1:
	SBI PORTB, PB5	; LED ON
rjmp loop



; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
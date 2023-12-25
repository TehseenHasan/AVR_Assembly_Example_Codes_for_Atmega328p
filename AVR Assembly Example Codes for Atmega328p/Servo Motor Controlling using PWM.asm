
; This example program uses PWN to change the angle of
; a hobby servo motor (e.g. 9g servo) attached on PB1 pin.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "16bit_reg_read_write_Macro.inc"
.cseg
.org 0x0000

SBI DDRB, PB1	; Set pin PB1 as output for OC1A (for Servo Motor)
	
; Timer 1 setup PWM
; Set OC1A and WMG11.
LDI r16, 0b10100010 
STS TCCR1A, r16
; Set WMG12 and WMG13 and Prescalar to 8
LDI r16, 0b00011010
STS TCCR1B, r16
; clear counter
LDI r16, 0
STSw TCNT1H, r16, r16
; count of 40000 for a 20ms period or 50 Hz cycle
LDI r16, LOW(40000)
LDI r17, HIGH(40000)
STSw ICR1H,r17,r16

loop:
	; use value from 900 to 4900 to change the angle of the servo accordingly
	
	; 0 degree angle
	LDI r16, LOW(900)
	LDI r17, HIGH(900)
	STSw OCR1AH,r17,r16
	delay 1000

	; 90 degree angle
	LDI r16, LOW(2900)
	LDI r17, HIGH(2900)
	STSw OCR1AH,r17,r16	
	delay 1000

	; 180 degree angle
	LDI r16, LOW(4900)
	LDI r17, HIGH(4900)
	STSw OCR1AH,r17,r16		
	delay 1000
rjmp loop




; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
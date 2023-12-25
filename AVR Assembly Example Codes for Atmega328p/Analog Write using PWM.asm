
; This example program uses PWN to change the brightness of an LED attached on PD6 pin.
; Note: Atmega328p Microcontroller don't have DAC (Digital to Analog Converter)
;		that is why there is no Analog Out pin on the Arduino UNO.
;		But we can simulate the behaviour of analog output with the help of PWM.
;		to perform the division we will use the following macro. 

.include "m328pdef.inc"
.include "delay_Macro.inc"
.cseg

; Macro to calculate the value for PWM dutycycle and output it on PWM pin
.macro PWM_set_dutycycle
	PUSH r16
	PUSH r17

	; formula  = dutycycle * 256 / 100
	;	ldi r16, dutycycle * 256 / 100
	;	out OCR0A,r16
	; where dutycycle could be from 0 to 99

	; r17 contains the input value
	mov r17, @0
	ldi r16, 2			; 256/100=2.56
	mul r16, r17		; Multiply r16 by r17, result in r1:r0
	mov r16, r0			; Copy the low byte of the result to r16
	mov r17, r1			; Copy the high byte of the result to r17

	; At this point, r16 contains the result of the expression (dutycycle*256/100)
	; So set the PWM dutycycle
	out OCR0A,r16

	POP r17
	POP r16
.endmacro


.org 0x0000
; set output pin PD6
sbi DDRD,PD6			; OC0A (PD6 pin) as PWM output pin
	
; Timer 0 in Fast PWM mode, output A low at cycle start
ldi r16,(1<<COM0A1)|(1<<COM0A0)|(1<<WGM01)|(1<<WGM00) 
out TCCR0A,r16			; to timer control port A
	
; Start Timer 0 with prescaler = 1
ldi r16,1<<CS00			; Prescaler = 1
out TCCR0B,r16			; to timer control port B

loop:
	; set brightness value from 10 to 90 in r17
	; 10 gives ~maximum duty cycle (maximum LED brightness)
	; 90 gives ~minumum duty cycle (minumum LED brightness)
	ldi r16, 90
	PWM_set_dutycycle r16
	delay 500

	ldi r16, 80
	PWM_set_dutycycle r16
	delay 500

	ldi r16, 50
	PWM_set_dutycycle r16
	delay 500

	ldi r16, 30
	PWM_set_dutycycle r16
	delay 500

	ldi r16, 10
	PWM_set_dutycycle r16
	delay 500
rjmp loop



; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
; This example program read the analog value of a LDR sensor from the AO pin (PC0) of the Arduino UNO
; Then based on the value of the sensor it turn off and on an LED.
; The analog value we read will be from range 0 to 255 

.include "m328pdef.inc"
.include "delay_Macro.inc"

.def A  = r16			; just rename or attach a label to the register
.def AH = r17			; just rename or attach a label to the register

.org 0x0000
; I/O Pins Configuration
SBI DDRB, PB5			; Set PB5 pin for Output to LED
CBI PORTB, PB5			; LED OFF
	
; ADC Configuration
LDI   A,0b11000111		; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
STS   ADCSRA,A			
LDI   A,0b01100000		; [REFS1 REFS0 ADLAR – MUX3 MUX2 MUX1 MUX0]
STS   ADMUX,A			; Select ADC0 (PC0) pin
SBI   PORTC,PC0			; Enable Pull-up Resistor

loop:
	LDS 	A,ADCSRA		; Start Analog to Digital Conversion
	ORI 	A,(1<<ADSC)
	STS	ADCSRA,A		

	wait:
		LDS 	A,ADCSRA	; wait for ADC conversion to complete
		sbrc 	A,ADSC
	rjmp	wait

	LDS 	A,ADCL			; Must Read ADCL before ADCH
	LDS 	AH,ADCH
	delay 	100				; delay 100ms
	
	cpi 	AH,200			; compare LDR reading with our desired threshold value e.g. 200
	brsh 	LED_ON			; jump if AH >= 200
	CBI 	PORTB, PB5		; LED OFF
rjmp loop

LED_ON:
	SBI 	PORTB, PB5		; LED ON
rjmp loop


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
; This example program read the analog value of a LDR sensor from the AO pin (PC0) of the Arduino UNO
; Then based on the value of the sensor it also sends
; custom strings to UART when it is day or night times.
; This code send the values of the LDR sensor to the UART as well.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "UART_Macros.inc"
.include "div_Macro.inc"

.def A = r16
.def AH = r17

.cseg
.org 0x0000

	; ADC Configuration		
	LDI A,0b11000111		; [ADEN ADSC ADATE ADIF ADIE ADIE ADPS2 ADPS1 ADPS0]
	STS ADCSRA,A
	LDI A,0b01100000		; [REFS1 REFS0 ADLAR – MUX3 MUX2 MUX1 MUX0]
	STS ADMUX,A				; Select ADC0 (PC0) pin
	SBI PORTC,PC0			; Enable Pull-up Resistor

	Serial_begin			; initilize UART serial communication

; Reading Analog value from LDR Sensor 
loop:
	LDS A,ADCSRA			; Start Analog to Digital Conversion
	ORI A,(1<<ADSC)
	STS ADCSRA,A
	wait:
		LDS A,ADCSRA		; wait for conversion to complete
		sbrc A,ADSC
	rjmp wait
	LDS A,ADCL				; Must Read ADCL before ADCH
	LDS AH,ADCH
	delay 100				; delay 100ms
	
	Serial_writeReg_ASCII AH	; sending the received value to UART
	Serial_writeChar ':'		; just for formating (e.g. 180: Day Time or 220: Night Time)
	Serial_writeChar ' '

	cpi AH,200			; compare LDR reading with our desired threshold
	brsh LED_ON			; jump if same or higher (AH >= 200)
	CBI PORTB,5			; LED OFF
	; writes the string "Day Time" to the UART
	LDI ZL, LOW (2 * day_string)
	LDI ZH, HIGH (2 * day_string)
	Serial_writeStr
	delay 500	
rjmp loop

	LED_ON:
	SBI PORTB,5			; LED ON
	; writes the string "Night Time" to the UART
	LDI ZL, LOW (2 * night_string)
	LDI ZH, HIGH (2 * night_string)
	Serial_writeStr
	delay 500
rjmp loop


; it is recommanded to define the constants (arrays, strings, etc.) at the end of the code segment
; .db directive is used to decalre constants
; You should use CRLF (carriage return/line feed) characters 0x0D and 0x0A at the end of the string.
; The string should be terminated with 0.
; The overall length of the string (including CRLF and ending zero) must be even number of bytes.

day_string:		.db	"Day Time ",0x0D,0x0A,0
night_string:	.db	"Night Time ",0x0D,0x0A,0


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************

; This example program uses interrupts to detect the push buttons.
; Interruput PCINT0 is attached to a push button on pin D8 (PB0) of Arduino UNO.
; Interruput PCINT18 is attached to a push button on pin D2 (PD2) of Arduino UNO.

.include "m328pdef.inc"
.include "delay_Macro.inc"
.cseg

; Interrupt Vector
.org 0x0000				; Main program start
	jmp RESET
.org PCI0addr			; pin change interrupt on PB0 pin
	jmp PCINT0_ISR
.org PCI2addr			; pin change interrupt on PD2 pin
	jmp PCINT18_ISR

RESET: 
	LDI r16, high(RAMEND)	; Set Stack Pointer to end of the RAM	
	OUT SPH, r16			; it is necessary when using interrupt vectors
	LDI r16, low(RAMEND)
	OUT SPL, r16		

	;I/O pins configuration
	SBI DDRB, PB5		; PB5 set as OUTPUT Pin (LED)
	CBI DDRD, PD2		; PD2 set as INPUT pin (push button1)
	SBI PORTD, PD2		; Enable internal pull-up resistor
	CBI DDRB, PB0		; PB0 set as INPUT pin (push button2)
	SBI PORTB, PB0		; Enable internal pull-up resistor

	; configure pin change interrupts on PB0 and PD2 pins
	LDI r16, 0b00000101	 	; enabling PCIE0 and PCIE2 interrupts
	STS PCICR, r16
	LDI r16, 0b00000001		;enabling PCINT0 interrupt (PB0 Pin)
	STS PCMSK0, r16
	LDI r16, 0b00000100		;enabling PCINT18 interrupt (PD2 Pin)
	STS PCMSK2, r16
	
	sei				; Enable interrupts globally

loop:
	; your other code, etc.
	nop				; no operation (just waste 1 clock cycle)
rjmp loop

; Interrupt PCINT0 ISR function
PCINT0_ISR:
	SBI PORTB, PB5 	; LED ON
reti

; Interrupt PCINT18 ISR function
PCINT18_ISR:
	CBI PORTB, PB5 	; LED OFF
reti



; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
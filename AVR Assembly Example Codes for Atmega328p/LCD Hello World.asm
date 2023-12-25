; This example program display different type of data to 16x2 LCD.
;
;	Data Pin Connections for 16x2 LCD
; 	[LCD pins]          [Arduino UNO Pins]
;   	RS   ---------------  8 (PB0)
;		E    ---------------  9 (PB1)
;		D4   ---------------  4 (PD4)
;		D5   ---------------  5 (PD5)
;		D6   ---------------  6 (PD6)
;		D7   ---------------  7 (PD7)
;		A   ----------------  13 (PB5)	; Anode pin of LCD Backlight LED

.include "m328pdef.inc"
.include "delay_Macro.inc"
.include "1602_LCD_Macros.inc"
.cseg
.org 0x0000

LCD_init			; initilize the 16x2 LCD
LCD_backlight_OFF	; Turn Off the LCD Backlight
delay 500
LCD_backlight_ON	; Turn On the LCD Backlight

loop:
	; Display a Null-terminated constant string on LCD
	LDI ZL, LOW (2 * hello_string)
	LDI ZH, HIGH (2 * hello_string)
	LDI R20, string_len
	LCD_send_a_string
	delay 1000
	LCD_send_a_command 0x01 	; clear the LCD
	
	; Display an integer on LCD
	LDI r16, 123
	LCD_send_a_register r16
	delay 1000
	LCD_send_a_command 0x01 	; clear the LCD
	
	; Display a single character on LCD
	LCD_send_a_character 'T'
	delay 1000
	LCD_send_a_command 0x01 	; clear the LCD

	; Sending Hello World to LCD character-by-character
	LCD_send_a_character 'H'
	LCD_send_a_character 'E'
	LCD_send_a_character 'L'
	LCD_send_a_character 'L'
	LCD_send_a_character 'O'
	LCD_send_a_character ' ' 	;(space)
	LCD_send_a_character 'W'
	LCD_send_a_character 'O'
	LCD_send_a_character 'R'
	LCD_send_a_character 'L'
	LCD_send_a_character 'D'
	LCD_send_a_character '!'
	LCD_send_a_command 0xC0 	; move curser to next line
	LCD_send_a_character 'C'
	LCD_send_a_character 'O'
	LCD_send_a_character 'A'
	LCD_send_a_character 'L'
	LCD_send_a_command 0x14 	; move curser one step forward (another way to add space)
	LCD_send_a_character 'L'
	LCD_send_a_character 'A'
	LCD_send_a_character 'B'
	delay 1000
	LCD_send_a_command 0x01 ; clear the LCD
rjmp loop


; it is recommanded to define the constants (arrays, strings, etc.) at the end of the code segment
; .db directive is used to decalre constants
; The length of the string must be even number of bytes

hello_string:	.db	"Tehseen",0
len: .equ	string_len   = (2 * (len - hello_string)) - 1


; ***************************************************************************
; *	Code written by:														*
; *		Syed Tehseen ul Hasan Shah											*
; *		Lecturer, University of Engineering and Technology Lahore, Pakistan	*
; *		24-December-2023													*
; ***************************************************************************
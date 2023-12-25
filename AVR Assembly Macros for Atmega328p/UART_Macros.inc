;-------------------------------------------
; UART Serial Read/Write Macros
;-------------------------------------------

; [List of all the available macros in this file]
;	Serial_begin
;	Serial_writeChar
;	Serial_writeReg
;	Serial_writeReg_ASCII
;	Serial_writeNewLine
;	Serial_writeStr
;	Serial_writeBuffer
;	Serial_writeBuffer_ASCII
;	Serial_read
;	Serial_readStr		pending



; Macro to initializes the UART to 9600 BAUD at a frequency of 16 MHz (for Arduino UNO ATmega328p)
; Inputs: none
; Outputs: none
; Working: Initilize the UART protocol
; Registers modified: r16.r17
.macro Serial_begin
	.equ            F_CPU           = 16000000		; 16Mhz
	.equ            BAUD_RATE       = 9600
	.equ            BAUD_PRESCALER  = (F_CPU/(BAUD_RATE * 16)) - 1  ; 103
	; save the states of R16 and R17
	PUSH            R16
	PUSH            R17
	; initialize UART to 9600 baud
	LDI             R16, LOW(BAUD_PRESCALER)
	LDI             R17, HIGH(BAUD_PRESCALER)
	STS             UBRR0L, R16
	STS             UBRR0H, R17
	; enable transmitter and reciever modes
	LDI             R16, (1<<TXEN0)|(1<<RXEN0)
	STS             UCSR0B, R16
	; set parity to none and 8 data bits, etc.
	LDI             R16, (1<<UCSZ01)|(1<<UCSZ00)
	STS             UCSR0C, R16
	; restore the states of R16 and R17 and return
	POP             R17
	POP             R16
.endmacro


; Macro to writes a single character (single byte) to the UART
; Inputs: an ASCII character as argument
; Outputs: none
; Working: sends that ASCII value of the character to the UART
; Registers modified: r16
.macro Serial_writeChar
	; save the state of R16
	PUSH            R16
	Serial_writeChar_LOOP:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeChar_LOOP
	; copy the argument to the UDR0 register to be sent out
	LDI				R16, @0
	STS             UDR0, R16
	; restore the state of R16 and return
	POP             R16
.endmacro


; Macro to writes a single 8-bit register's raw value to the UART
; Inputs: register as argument
; Outputs: none
; Working: sends the raw value of the register to the UART
; Registers modified: r16
.macro Serial_writeReg
	PUSH r16
		
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	PUSH r16
	Serial_writeReg_LOOP_1:
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeReg_LOOP_1
	POP r16
	; Load r16 register value into data register (UDR0) to send to UART
	mov R16, @0	
	sts UDR0, R16
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	PUSH r16
	Serial_writeReg_LOOP_2:
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeReg_LOOP_2
	POP r16

	POP r16
.endmacro


; Macro to writes a single 8-bit register's ASCII-encoded value to the UART
; Inputs: register as argument
; Outputs: none
; Working: sends the ASCII-encoded value of the register to the UART
.macro Serial_writeReg_ASCII
	PUSH r15
	PUSH r16
	PUSH r17
	PUSH r18
	PUSH r19
	PUSH r28
	PUSH r29
	PUSH r30

	; Load the received value into r16
	mov R16, @0
	mov r19, r16	; take backup of origional value to r19

	PUSH r16
	Serial_writeReg_ASCII_LOOP:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeReg_ASCII_LOOP
	POP r16

	; Convert the 8-bit (0-255) integer to ASCII encoded integer
	; by simply spliting it and adding 48 to its individual digits then
	; send those individual digits to UART

	; Split the integer into individual digits
	ldi r28, 0          ; Initialize r28 (ones place) to 0
	ldi r29, 0          ; Initialize r29 (tens place) to 0
	ldi r30, 0          ; Initialize r30 (hundreds place) to 0

	; Ones place
	ldi r17, 10         ; Load divisor (10) into r17
	div					; Divide r16 by 10, result in r16, remainder in r15
	mov r28, r15        ; Move remainder (ones place) to r28

	; Tens place
	ldi r17, 10         ; Load divisor (10) into r17
	div			        ; Divide r16 by 10, result in r16, remainder in r15
	mov r29, r15        ; Move remainder (tens place) to r29

	; Hundreds place
	ldi r17, 10         ; Load divisor (10) into r17
	div			        ; Divide r16 by 10, result in r16, remainder in r15
	mov r30, r15        ; Move remainder (hundreds place) to r30

	; Now r28 has the ones place, r29 has the tens place, and r30 has the hundreds place
	; e.g. integer 235 will split into --> r30=2 , r29=3 , r28=5

	LDI r18, 0	; counter for the loop logic
	LDI r17, 48 ; 48 will be added to each digit to encode it to ASCII integer
	
	; loop to send all 3 register r30, r29 and r28 to UART one by one
	Serial_writeReg_ASCII_writing:	
	cpi r18, 0
	BREQ Serial_writeReg_ASCII_writing_L1
	cpi r18, 1
	BREQ Serial_writeReg_ASCII_writing_L2
	cpi r18, 2
	BREQ Serial_writeReg_ASCII_writing_L3
	rjmp Serial_writeReg_ASCII_writing_end

	; sending r30 to UART
	Serial_writeReg_ASCII_writing_L1:
	CPI r19,100
	BRLO Serial_writeReg_ASCII_writing_skip	; if the origional number was from 0 to 99, then skip sending r30 to UART
	add r30, r17
	mov r16, r30
	rjmp Serial_writeReg_ASCII_writing_start

	; sending r29 to UART
	Serial_writeReg_ASCII_writing_L2:
	CPI r19,10
	BRLO Serial_writeReg_ASCII_writing_skip	; if the origional number was from 0 to 9, then skip sending r29 as well
	add r29, r17
	mov r16, r29
	rjmp Serial_writeReg_ASCII_writing_start

	; sending r28 to UART
	Serial_writeReg_ASCII_writing_L3:
	add r28, r17
	mov r16, r28
	rjmp Serial_writeReg_ASCII_writing_start

	Serial_writeReg_ASCII_writing_start:
		; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
		PUSH r16
		Serial_writeReg_ASCII_LOOP_1:
		LDS             R16, UCSR0A
		SBRS            R16, UDRE0
		RJMP            Serial_writeReg_ASCII_LOOP_1
		POP r16
		; Load r16 register value into data register (UDR0) to send to UART
		sts UDR0, R16
		; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
		PUSH r16
		Serial_writeReg_ASCII_LOOP_2:
		LDS             R16, UCSR0A
		SBRS            R16, UDRE0
		RJMP            Serial_writeReg_ASCII_LOOP_2
		POP r16
	
	Serial_writeReg_ASCII_writing_skip:
	INC r18
	rjmp Serial_writeReg_ASCII_writing

	Serial_writeReg_ASCII_writing_end:
	POP r30
	POP r29
	POP r28
	POP r19
	POP r18
	POP r17
	POP r16
	POP r15
.endmacro


; Macro to writes a new line character to the UART
; Inputs: none
; Outputs: none
; Working: sends CRLF - carrage return (0x0D) and newline (0x0A) characters to the UART
; Registers modified: r16
.macro Serial_writeNewLine
	; save the state of R16
	PUSH            R16
	Serial_writeNewLine_LOOP1:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeNewLine_LOOP1
	; move value 0x0D (\r) to the UDR0 register to be sent out
	LDI				R16, 0x0D
	STS             UDR0, R16
	Serial_writeNewLine_LOOP2:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R16, UCSR0A
	SBRS            R16, UDRE0
	RJMP            Serial_writeNewLine_LOOP2
	; move value 0x0A (\n) to the UDR0 register to be sent out
	LDI				R16, 0x0A
	STS             UDR0, R16
	; restore the state of R16 and return
	POP             R16
.endmacro


; Macro to writes a NULL terminated string to the UART 
; Inputs: ZH:ZL - SRAM buffer address from where to the string is stored
; Outputs: none
; Working: sends the string via UART
; Registers modified: r16,r17,Z
;
;	For example:	
;		LDI ZL, LOW (2 * hello_string)
;		LDI ZH, HIGH (2 * hello_string)
;		Serial_writeStr
;	
;	It is recommanded to define the constent strings at the end of the code segment.
;	Optionally you can use CRLF (carriage return/line feed) characters 0x0D and 0x0A at the end of the string
;	the string should be terminated with 0.
;	The overall length of the string (including CRLF and ending zero) must be even number of bytes.
;	e.g.	
;			hello_string:	.db	"Hello World",0x0D,0x0A,0
;	
;	.db directive is used to decalre constants
;
;	Note: the string length should be in even numbers, if your string length is
;		  in odd numbers then add an extra space at the end of the string
;		  to make overall string length to even number.
;
.macro Serial_writeStr
	; save the states of R16 and R17
	PUSH            R16
	PUSH            R17
	Serial_writeStr_LOOP:
	; load the current byte/character pointed to be Z and increment the Z pointer
	LPM             R16, Z+
	; if the current character is 0/NULL, return from the routine since the string has been used
	CPI             R16, 0
	BREQ            Serial_writeStr_END
	Serial_writeStr_CHAR:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R17, UCSR0A
	SBRS            R17, UDRE0
	RJMP            Serial_writeStr_CHAR
	; copy the current character to the UDR0 register to send it out and jump back to the start
	STS             UDR0, R16
	RJMP            Serial_writeStr_LOOP
	Serial_writeStr_END:
	; restore the states of R16 and R17 and return
	POP             R17
	POP             R16
.endmacro


; Macro to writes a buffer (constant integer array, etc.) of a given length (<256 bytes) to the UART
; Inputs: ZH:ZL - SRAM buffer address from where to the sending data is placed
;		  r20 should have the length of the buffer
; Outputs: none
; Working: sends the buffer via UART
; Registers modified: r16,r17,r20,Z
;
;For example:	
;		LDI ZL, LOW (2 * hello_buffer)
;		LDI ZH, HIGH (2 * hello_buffer)
;		LDI r20, buffer_len
;	
;	it is recommanded to define the buffer at the end of the code segment
;		hello_buffer:	.db	1,2,3,4,5,6
;		len: .equ	buffer_len   = 2 * (len - hello_buffer)
;
;	.db directive is used to decalre constants
;
;	Note: the string length should be in even numbers, if your string length is
;		  in odd numbers then add an extra space at the end of the string
;		  to make overall string length to even number.
;
.macro Serial_writeBuffer
	; save the states of R16, R17 and r20
	PUSH            R16
	PUSH            R17
	PUSH			R20
	Serial_writeBuffer_LOOP:
	; load the current byte pointed to be Z and increment the Z pointer
	LPM             R16, Z+
	; check if the remaining size of the buffer is non-zero and return if it is
	CPI             R20, 0
	BREQ            Serial_writeBuffer_END
	Serial_writeBuffer_CHAR:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R17, UCSR0A
	SBRS            R17, UDRE0
	RJMP            Serial_writeBuffer_CHAR
	; copy the current character to the UDR0 register to send it out and jump back to the start
	STS             UDR0, R16
	DEC             R20
	RJMP            Serial_writeBuffer_LOOP
	Serial_writeBuffer_END:
	; restore the states of R16, R17 and r20
	POP				R20
	POP             R17
	POP             R16
.endmacro


; Macro to writes an ASCII-encoded buffer (constant integer array, etc.) of a given length (<256 bytes) to the UART
; Inputs: ZH:ZL - SRAM buffer address from where to the sending data is placed
;		  r20 should have the length of the buffer
; Outputs: none
; Working: sends the buffer via UART
; Registers modified: r16,r17,r20,Z
;
;For example:	
;		LDI ZL, LOW (2 * hello_buffer)
;		LDI ZH, HIGH (2 * hello_buffer)
;		LDI r20, buffer_len
;	
;	it is recommanded to define the buffer at the end of the code segment
;		hello_buffer:	.db	1,2,3,4,5,6
;		len: .equ	buffer_len   = 2 * (len - hello_buffer)
;
;	.db directive is used to decalre constants
;
;	Note: the string length should be in even numbers, if your string length is
;		  in odd numbers then add an extra space at the end of the string
;		  to make overall string length to even number.
;
.macro Serial_writeBuffer_ASCII
	; save the states of R16, R17 and r20
	PUSH            R16
	PUSH            R17
	PUSH			R18
	PUSH			R20

	LDI r18, 48 ; 48 will be added to each digit to encode it to ASCII integer

	Serial_writeBuffer_LOOP:
	; load the current byte pointed to be Z and increment the Z pointer
	LPM             R16, Z+
	add r16, r18		; convert to ASCII encoded integer
	; check if the remaining size of the buffer is non-zero and return if it is
	CPI             R20, 0
	BREQ            Serial_writeBuffer_END
	Serial_writeBuffer_CHAR:
	; wait for the write buffer to become empty (bit UDRE0 of UCSR0A register should be set)
	LDS             R17, UCSR0A
	SBRS            R17, UDRE0
	RJMP            Serial_writeBuffer_CHAR
	; copy the current character to the UDR0 register to send it out and jump back to the start
	STS             UDR0, R16
	DEC             R20
	RJMP            Serial_writeBuffer_LOOP
	Serial_writeBuffer_END:
	; restore the states of R16, R17 and r20
	POP				R20
	POP				R18
	POP             R17
	POP             R16
.endmacro


; Macro to read a single byte from the UART
; Inputs: register to hold the received byte
; Outputs: r16
; Working: receives byte via UART and stores in a r16 register
.macro Serial_read

	;Serial_read_WAIT:
	; wait till a byte is in the buffer
	LDS             R16, UCSR0A
	SBRS            R16, RXC0
	RJMP            Serial_read_Skip
	;RJMP            Serial_read_WAIT

	Serial_read_Start:
	; read the byte
	LDS             r16, UDR0

	rjmp Serial_read_END
	Serial_read_Skip:
	LDI				r16,0
	Serial_read_END:
.endmacro


; Macro to receive a string from the UART and store in variable (array)
; Inputs: ZH:ZL - SRAM buffer address for received string
; Outputs: r16 will contain 0 if no data received
; Working: receives string via UART and stores in data memory until carriage return (0x0D) received
; Registers modified: r16, r17, XL, XH
;
;	For example:
;		.dseg
;		.org SRAM_START
;			buffer:	.byte	20		; 20 bytes reserved
;		.cseg
;		.org 0x0000
;			LDI ZL, LOW (buffer)
;			LDI ZH, HIGH (buffer)
;			Serial_readStr
;
.macro Serial_readStr
	; save the state of R17
	PUSH			R17
	
	;Serial_readStr_WAIT:
	; wait till a byte is in the buffer
	LDS             r16, UCSR0A
	SBRS            r16, RXC0
	RJMP            Serial_readStr_Skip
	;RJMP            Serial_readStr_WAIT

	Serial_readStr_Start:
	lds		r16, UDR0				; get received character

	cpi		r16, 0x0D				; check if received char is CR
	breq	Serial_readStr_END		; branch if CR received

	st	Z+, r16						; store character to buffer
	rjmp Serial_readStr_Start		; get another character


	Serial_readStr_Skip:
	LDI				r16, 0			; set r16 to 0 if there is no data on UART
	rjmp Serial_readStr_Skip2
	Serial_readStr_END:
	LDI				r16, 1			; set r16 to 1 if data is received on UART
	Serial_readStr_Skip2:
	POP				R17
.endmacro




; ***************************************************************************
; *		Macros written by:													*
; *			Syed Tehseen ul Hasan Shah										*
; *			Lecturer, University of Engineering and Technology Lahore.		*
; *			24-December-2023												*
; ***************************************************************************
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-07
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 4
; Title: Task 4.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Serial communication with echo.
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: start, GetChar, Output_Local, Output_Remote
;
; Other information: Echoes serial input.
;
; Changes in program: 07/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.def temp = r17
.def char = r16
.equ ubrr_val = 12						; UBRR = 12 SET BAUD RATE to 4800bps

.org 0x00
	rjmp start

.org 0x72
start:
	ldi temp, 0xFF
	out DDRB, temp
	ldi temp, 0x55
	out PORTB, temp						; output
	
	ldi temp, ubrr_val					; store prescaler value in ubrr0l
	sts UBRR0L, temp					; set baud rate

	ldi temp, (1<<TXEN0) | (1<<RXEN0)	; set RXEN0 and TXEN0 to 1
	sts UCSR0B, temp					; set TX and RX enable flags
										; UCSR0B -> ENABLE THE FLAGS
										; and UCSR0A -> TransferComplete flags
										

GetChar:
	lds temp, UCSR0A					; LOAD status register UCSR0A to check flag.
	sbrs temp, RXC0						; IF RXC0 = 1, we have a new character in buffer
	rjmp GetChar
	lds char, UDR0						; Get character from buffer.

Output_Local:
	com char
	out PORTB, char
	com char

Output_Remote:
	lds temp, UCSR0A					; LOAD STATUS REGISTER
	sbrs temp, UDRE0					; Skip next if transmit buffer empty -> Ready to transmit
	rjmp Output_Remote					; Loop back and load from UCSR0A
	sts UDR0, char						; output char to buffer
	rjmp GetChar	

	
		

	

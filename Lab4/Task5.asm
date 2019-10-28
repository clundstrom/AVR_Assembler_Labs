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
; Function: Serial communication echoes using serial interrupts.
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: start, GetChar, Output_Local, Output_Remote, main_loop
;
; Other information: Echoes serial input.
;
; Changes in program: 07/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.def temp = r17
.def char = r16
.equ ubrr_val = 207						; UBRR = 12 SET BAUD RATE to 4800bps

.org 0x00
	rjmp start


.org URXCaddr
	rjmp GetChar
	

.org 0x72
start:
	ldi temp, 0xFF
	out DDRB, temp
	ldi temp, 0x55
	out PORTB, temp						; output
	
	ldi temp, ubrr_val					; store prescaler value in ubrr0l
	sts UBRR0L, temp					; set baud rate

	ldi temp, (1 << RXCIE0| 1<<TXEN0) | (1<<RXEN0)	; Enable Receive Interrupt, and enable transmit and recieve
	sts UCSR0B, temp					; set TX and RX enable flags
										; UCSR0B -> ENABLE THE FLAGS
										; and UCSR0A -> TransferComplete flags
										
	
	sei									; set global interrupt flag enable


main_loop:
	nop
	rjmp main_loop


GetChar:
	lds temp, UCSR0A					; LOAD status register UCSR0A to check flag.
	lds char, UDR0						; Get character from buffer.


Output_Local:
	com char
	out PORTB, char
	com char

Output_Remote:
	lds temp, UCSR0A					; LOAD STATUS REGISTER
	sts UDR0, char						; output char to buffer
	reti

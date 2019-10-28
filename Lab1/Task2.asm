;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-13
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 1
; Title: Task 2.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Lights LED using corresponding button.
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: init, loop
;
; Other information: We use the input bit as bitmask for output.
;
; Changes in program: 13/9 2019
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
init:
	ldi r16, 0x00 ; set r16 to 0
	ldi r17, 0xFF ; set r17 to 1
	out DDRD, r16 ; set DDRD to input
	out DDRB, r17 ; set DDRB to output

	loop:
	in r16, PIND ; read pin value to r16
	out PORTB, r16; output r16
	rjmp loop

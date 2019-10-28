;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-13
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 1
; Title: Task 3.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Lights LED using corresponding button.
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: init, loop, light
;
; Other information:
;
; Changes in program: 13/9 2019
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
init:
	ldi r16, 0b1111_0111 ; set r16 to 0
	ldi r17, 0xFF ; set r17 to 1 for later comparison
	ldi r18, 0x01 ; activation bit
	out DDRD, r16 ; set DDRD SW5 to input
	out DDRB, r17 ; set DDRB to output
	ldi r17, 0b0000_1000; set r17 to compare-bit

loop:
	in r16, PIND ; read pin value to r16
	cp r16,r17
	breq light
	rjmp loop

light:
	out PORTB, r18
	reti 
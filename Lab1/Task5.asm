;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-13
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 1
; Title: Task 5.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: This program lights 6 LEDs in using 500ms delay (ring counter).
;
; Input ports: No input in this task.
;
; Output ports: PORTB used to light leds.
;
; Subroutines: init, main, compare, delay
;
; Other information:
;
; Changes in program: 13/9 2019
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ldi r20, HIGH(RAMEND) ; high part of ram
out SPH,r20
ldi r20, LOW(RAMEND) ; low part of ram
out SPL, r20
;;;;;;
ldi r16, 0xFF; load 11 to r16
out DDRB, r16; set output on
	
init:
	ldi r16, 0b0000_0001
	ldi r17, 0b0100_0000; RESET BIT

main: 
	out PORTB, r16; light led 1
	rcall delay
	lsl r16 ; shift r16 one to the left and output
	rcall compare
	rjmp main

compare:
	cp r16,r17
	breq init ; if registers are equal branch
	reti

delay:; delay routine
	ldi  r21, 41 ; load temp value1
	ldi  r22, 150; load temp value2
	ldi  r23, 128; load temp value3
	L1: 
	dec  r23 
	brne L1
	dec  r22
	brne L1
	dec  r21
	brne L1
	reti
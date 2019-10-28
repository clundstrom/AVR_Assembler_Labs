;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-13
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 1
; Title: Task 6.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: This program lights LED 1-6 with 500ms delay and turns off leds in reverse order.
;
; Input ports: No input in this task.
;
; Output ports: PORTB used to light leds.
;
; Subroutines: init, main_loop, reset and delay
;
; Other information: 
; init: Responsible for setting up stack, data directions and initial register values.
; main loop: Shifts bits, adds 0x01 to shifted bit and pushes to stack before outputting to PORTB.
; reset: Reverses actions made by main loop by popping stack and outputting values.
; delay: 500ms delay.
; Changes in program: 13/9 2019
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

init:
	ldi r20, high(ramend)
	out sph, r20
	ldi r20, low(ramend)
	out spl, r20
	ldi r16, 0xFF
	out DDRB, r16 ; Set to output
	ldi r17, 0b0011_1111 ; Full bit
	ldi r18, 0x00
	ldi r19, 0x01
	ldi r21, 0x00
	push r21

main_loop:
	rcall delay
	lsl r18 ; shift 18 left
	add r18, r19; add 19 to 18
	push r18 ;copy to stack
	out PORTB, r18
	cp r18, r17
	breq reset
	rjmp main_loop

reset:
	pop r18
	rcall delay
	out PORTB, r18
	cp r18, r21
	breq init
	rjmp reset


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
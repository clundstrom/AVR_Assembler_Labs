
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-23
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 2
; Title: Task 2.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Simulates a random number generator and lights LED according to outcome.
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: main_loop, isPressed, increment_loop, reset_dice, fetch_value, light_1-6
;
; Other information:
;
; Changes in program: 25/9 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.DEF counter = r18
.DEF compare = r17
.DEF MAX_VALUE = r19
.DEF tmp = r20
.DEF LIGHT_VAL = r21
.DEF FETCH_FLAG = r22
.DEF CP_FETCH = r23

ldi FETCH_FLAG, 0x01
ldi CP_FETCH, 0x00

ldi r20, HIGH(RAMEND)
out SPH, r20
ldi r20, LOW(RAMEND)
out SPL, r20

ldi r16, 0b0011_1111
out DDRB, r16					; output
ldi r16, 0b1101_1111
out DDRD, r16					; input 

ldi counter, 0x00
ldi compare, 0b0010_0000
ldi MAX_VALUE, 0x06


main_loop:						; Program main loop.
	rcall increment_loop		; Runs the increment routine.
	rjmp main_loop				; Loop back to main.

isPressed:
	in r16, PIND				; Read input from PIND
	andi r16, 0b00100000		; Verifies input.
	cp compare, r16				; Make comparison of Input
	breq fetchValue				; If key is pressed, fetch dice value.
	ret							; else return

increment_loop:
	rcall isPressed				; Calls isPressed routine which checks if a key is pressed.
	inc counter					; Increments counter.
	cp MAX_VALUE, counter		; Compares if counter to MAX_VALUE of dice.
	breq reset_dice				; if equal to MAX -> Reset.
	ret							; Else return.

reset_dice:						; Resets our dice and jumps back to Increment loop.
	ldi counter, 0x00
	rjmp increment_loop


fetchValue:						; Checks the counter value to call the correct Light-function.
	ldi tmp, 0x00
	cp counter, tmp
	breq light1
	ldi tmp, 0x01
	cp counter, tmp
	breq light2
	ldi tmp, 0x02
	cp counter, tmp
	breq light3
	ldi tmp, 0x03
	cp counter, tmp
	breq light4
	ldi tmp, 0x04
	cp counter, tmp
	breq light5
	ldi tmp, 0x05
	cp counter, tmp
	breq light6
	ret




; Represents LED 1-6, Lights corresponding LED and returns.
light1:
	ldi LIGHT_VAL, 0b0000_0001
	out PORTB, LIGHT_VAL
	ret

light2:
	ldi LIGHT_VAL, 0b0000_0011
	out PORTB, LIGHT_VAL
	ret

light3:
	ldi LIGHT_VAL, 0b0000_0111
	out PORTB, LIGHT_VAL
	ret

light4:
	ldi LIGHT_VAL, 0b0000_1111
	out PORTB, LIGHT_VAL
	ret

light5:
	ldi LIGHT_VAL, 0b0001_1111
	out PORTB, LIGHT_VAL
	ret

light6:
	ldi LIGHT_VAL, 0b0011_1111
	out PORTB, LIGHT_VAL
	ret
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-03
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 3
; Title: Task 2.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Uses interrupt to switch between Ring counter and Johnson counter.
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: init_stack, interrupt_0, initialize_ring_counter, ring_main, ring_compare, init_johnson_counter, main_loop, reset_johnson, delay
; check_input, switch_counter
;
; Other information: 
;
; Changes in program: 03/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.org 0x00
rjmp init_stack

.org INT0addr
rjmp interrupt_0


init_stack:
    ldi r20, HIGH(RAMEND)
	out SPH, r20
	ldi r20, LOW(RAMEND)
	out SPL, r20
	ldi r16, 0b1101_1111				; set input
	out DDRD, r16
	ldi r16, 0b1111_1111
	out DDRB, r16						; set output
	ldi r20,  0b0010_0000				; is button pressed bit
	ldi r24, 0							; SET BASELINE FOR COMPARE SWITCHER
	ldi r16, 0b10
	sts EICRA, r16						; Activity on this will trigger an interrupt request
	ldi r16, 0b01						; set bit 0 to 1 in EIMSK
	out EIMSK, r16						; External interrupt mask register 0-7 corresponding external pin interrupt is enabled
	ldi r27, 0

	sei									; makes sure next instruction is run before interrupt

initialize_ring_counter:
	ldi r27, 0							; RESET CHANGE BIT
	ldi r25, 0
	ldi r16, 0b0000_0001
	ldi r17, 0b0100_0000				; RESET BIT

ring_main: 
	out PORTB, r16						; light led 1
	rcall delay
	lsl r16								; shift r16 one to the left and output
	rcall ring_compare
	rjmp ring_main

ring_compare:
	cp r16,r17
	breq initialize_ring_counter		; if registers are equal go to ring counter.
	ret

init_johnson_counter:
	ldi r25, 1							; set compare bit
	ldi r27, 0							; RESET CHANGE BIT
	ldi r17, 0b0011_1111				; Full bit
	ldi r18, 0x00						; varied bit
	ldi r19, 0x01
	ldi r21, 0x00
	push r21

main_loop:
	rcall delay
	lsl r18								; shift 18 left
	add r18, r19						; add 19 to 18
	push r18							; copy to stack
	out PORTB, r18
	cp r18, r17							; 
	breq reset_johnson					; if equal -> reset johnson loop
	rjmp main_loop						; loop back to main_loop

reset_johnson:							; Pops the stack and outputs previous values.
	pop r18
	rcall delay
	out PORTB, r18
	cp r18, r21
	breq init_johnson_counter			; If the johnson is complete, reinitialize the counter
	rjmp reset_johnson					; else continue to pop and output

delay:									; delay set at 1000ms
	rcall check_input
	ldi  r21, 41						; load temp value1
	ldi  r22, 150						; load temp value2
	ldi  r23, 128						; load temp value3
	L1: 
	dec  r23 
	brne L1
	dec  r22
	brne L1
	dec  r21
	brne L1
	ret


check_input:
	cpi r27, 1							; compare input to our button mask 0b0010_0000
	breq switch_counter					; if button pressed down, go to switch routine
	ret

switch_counter: 
	cp r24, r25							; Check compare bit to see which routine to choose
	breq init_johnson_counter			; if equal run johnson
	rjmp initialize_ring_counter		; else run ring counter
	
interrupt_0:
	ldi r27, 1							;set change flag
	reti
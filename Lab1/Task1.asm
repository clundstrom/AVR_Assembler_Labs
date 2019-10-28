;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-13
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 1
; Title: Task 1.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: This program lights LED 2.
;
; Input ports: No input in this task.
;
; Output ports: PORTB used to light led.
;
; Subroutines: Start. Main entry point of application.
;
; Other information:
;
; Changes in program: 13/9 2019
;
; Results: Leds are lit by first setting data direction and then setting PORTB to output with bitmask. 
; The minimum amount of instructions to light the leds are 3 instructions. One ldi register, one set ddr and one output.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
start:
	ldi r16, 0b0000_0010 ; Load Bit to Register 16
	out DDRB, r16; Set data direction from register 16
	out PORTB, r16; Output bitmask to portb
    
   

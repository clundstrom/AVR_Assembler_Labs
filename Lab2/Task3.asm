;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-24
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 2
; Title: Task 3.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Simulates a random number generator and lights LED according to outcome.
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: init_values, start, isPressed, isUsed, setAsUsed, isReleased, reset
;
; Other information:
;
; Changes in program: 25/9 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.DEF READ = r16
.DEF GLOBAL = r17
.DEF LOCAL = r18
.DEF PRESSED_COMPARE = r19
.DEF VALUE = r20

ldi r20, HIGH(RAMEND)
out SPH, r20
ldi r20, LOW(RAMEND)
out SPL, r20
ldi r16, 0b1101_1111				; set input
out DDRD, r16
ldi r16, 0b1111_1111
out DDRB, r16						; set output

init_values:
	ldi PRESSED_COMPARE, 0b0010_0000
	ldi GLOBAL, 0x00
	ldi LOCAL, 0x00
	ldi VALUE, 0x00

start:
	rcall isPressed
	rjmp start

isPressed:
	in READ, PIND					; read value from pin
	andi READ, 0b0010_0000			; verify input
	cp PRESSED_COMPARE, READ		; compare input with InputMASK
	breq isUsed						; if key is pressed goto isUsed
	ret								; else return

isUsed:
	cp GLOBAL, LOCAL				; compare Global zero mask to local bit
	breq setAsUsed					; if equal that means value has not been increased -> goto setAsUsed
	rjmp isReleased					; else skip and check if key is released

setAsUsed:
	inc VALUE						; Increments value
	out PORTB, VALUE				; outputs value PortB
	ldi LOCAL, 0x01					; Mark Local variable as Used (0x01)
	rjmp isUsed						; Go back to isUsed function

isReleased:							
	in r22, PIND					; Read input from PIND
	cp GLOBAL, r22					; compare with Global variable
	breq reset						; if key is released, goto reset
	rjmp isReleased					; if key is not released, loop back

reset:
	inc VALUE						; increment value
	out PORTB, VALUE				; output value
	ldi LOCAL, 0x00					; reset local "used" variable
	rjmp isPressed					; loop back to isPressed


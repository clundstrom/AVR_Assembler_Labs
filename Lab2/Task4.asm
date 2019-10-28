;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-09-25
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 2
; Title: Task 4.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: A ring counter with specified delay time.
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: init, main, compare, wait_millisecond, isHIGH, isLOW, return, delay
;
; Other information:
;
; Changes in program: 25/9 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.DEF delayHIGH = r25
.DEF delayLOW = r24
.DEF compareMASK = r23

ldi r20, HIGH(RAMEND)					; high part of ram
out SPH,r20
ldi r20, LOW(RAMEND)					; low part of ram
out SPL, r20
ldi r16, 0xFF					
out DDRB, r16							; set output on

init:
	ldi compareMASK, 0x00
	ldi r16, 0b0000_0001
	ldi r17, 0b0100_0000				; RESET BIT


main: 
	out PORTB, r16
	ldi delayHIGH, HIGH(100)			; Set x milliseconds to register.
	ldi delayLOW, LOW(100)				; X-max: 0-65536
	rcall wait_millisecond				; Call custom millisecond function.
	lsl r16								; Shift bit left.
	rcall compare						; Call compare function.
	rjmp main							; Loop back to main.

compare:
	cp r16,r17
	breq init							; if registers are equal re-initialize registers
	ret


wait_millisecond:

	isHIGH:
		cp delayHIGH, compareMASK		; if high != empty jump to delay
		breq isLOW						; if high == empty go to low byte check
		rjmp delay						; high byte not empty ,

	isLOW:
		cp delayLOW, compareMASK		; compare low byte with zero-mask.
		breq return						; if low == empty return from function
		rjmp delay						; low byte not empty -> delay and decrement

	return:								; Delay completed -> return from function
		ret

	delay:								; preset to 1ms using http://www.bretmulvey.com/avrdelay.html
		sbiw r24, 1						; decrement number on each delay call
		ldi  r18, 21
		ldi  r19, 199
		L1: dec  r19
			brne L1
			dec  r18
			brne L1
			rjmp wait_millisecond		; continue loop
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-07
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 4
; Title: Task 1.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Square wave generator.
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: start, switch_led, timer0int, main
;
; Other information: Default: Duty cycle 50% fixed.
;
; Changes in program: 07/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.EQU timerValue = 100						; 256 - 16mhz/1024		-> 2ms
.EQU counterValue = 50						; run interrupt x times -> 50ms
.DEF compareBitReg = r17
.DEF timerReg = r19
.DEF counter = r18

.org 0x00
rjmp start


.org OVF0addr
rjmp timer0int


.org 0x72
start:
	ldi r20, HIGH(RAMEND)	
	out SPH, r20			
	ldi r20, LOW(RAMEND)	
	out SPL, r20
	ldi r16, 0x01
	out DDRB, r16
	ldi comparebitReg, 0
	ldi counter, counterValue				; set timercounter

	ldi r16, 0x05							; set prescaler to 0b0000_0101 which sets prescaler to 1024
	out TCCR0B, r16							; prescaler
	ldi timerReg, timerValue				;  for 500ms
	out TCNT0, timerReg						; set counter to 256 - 31cycles so interrupt is called at 500ms
	ldi r16, 0x01							; set bit 0 to 1 in TIMSK to enable overflow interrupt
	sts TIMSK0, r16							; Enable timer interrupt
	
	sei										; set global interrupt


main:
	cpi counter, 0
	breq switch_led
	rjmp main
		

timer0int:
	push timerReg							; save state to stack
	in timerReg, SREG						; save sreg to stack
	push timerReg							; save
	ldi timerReg, timerValue				; start value for counter
	out TCNT0, timerReg						; Output to counter register so it 
	pop timerReg				
	out SREG, timerReg						; restore sreg
	pop timerReg							; restore counter
	dec counter								; decrease counter
	reti									; return interrupt


switch_led:
	ldi counter, counterValue
	com compareBitReg
	out PORTB, compareBitReg
	rjmp main



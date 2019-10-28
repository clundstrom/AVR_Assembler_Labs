;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-07
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 4
; Title: Task 2.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Pulse-Width Modulator
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: init_stack, default, setMinValue timer0int, ledOFF, increase, decrease, reset, btn_delay
;
; Other information: Changes duty cycle using interrupts with 5% increments/decrements.
;
; Changes in program: 07/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.EQU timerValue = 177				; Fixed timer value. 5ms x 100 = 500ms
.EQU counterValue = 100				; Number of interrupts to run. 25ms = 5% -> 5 interrupts = 5%
/////////////////////
/////////////////////
.DEF timerRegister = r16
.DEF timerCounter = r17
////////////////////
////////////////////
.DEF lightSyncReg = r18
.DEF numberOfInterrupts = r19
.DEF dutyCycleRegister = r20
.EQU defaultDutyCycleVal = 50
.EQU maxDutyCycleVal = 101
.EQU minDutyCycleVal = 0
////////////////////
.DEF lightRegister = r21


///////////////////////////////////////			TABLE OF INTERRUPTS			///////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////		DUTY CYCLE	-	NR OF INTERRUPTS - TIME	///////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////				0% - 0 interrupts		- 0 ms		///////////////////////////////////////
///////////////////////////////////////				5% - 5 interrupts		- 25 ms		///////////////////////////////////////
///////////////////////////////////////				10% - 10 interrupts		- 50 ms		///////////////////////////////////////
///////////////////////////////////////				15% - 15 interrupts		- 75 ms		///////////////////////////////////////
///////////////////////////////////////				20% - 20 interrupts		- 100 ms	///////////////////////////////////////
///////////////////////////////////////				25% - 25 interrupts		- 125 ms	///////////////////////////////////////
///////////////////////////////////////				30% - 30 interrupts		- 150 ms	///////////////////////////////////////
///////////////////////////////////////				35% - 35 interrupts		- 175 ms	///////////////////////////////////////
///////////////////////////////////////				40% - 40 interrupts		- 200 ms	///////////////////////////////////////
///////////////////////////////////////				45% - 45 interrupts		- 225 ms	///////////////////////////////////////
///////////////////////////////////////				50% - 50 interrupts		- 250 ms	///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



.org 0x00
rjmp init_stack

.org INT0addr
rjmp increase

.org INT1addr
rjmp decrease

.org OVF0addr
rjmp timer0int



.org 0x72
init_stack:
	///////////////////////////////////////////
	ldi r20, HIGH(RAMEND)						; Set r20 to HIGH ADDRESS OF RAMEND
	out SPH, r20								; STACK POINTER HIGH
	ldi r20, LOW(RAMEND)						; r20 to LOW ADDRESS OF RAMEND
	out SPL, r20								; STACK POINTER LOW
	
	///////////////////////////////////////////
	ldi r16, 0x01								; Set output on 1 LED
	out DDRB, r16								; Set output
	ldi r16, 0b1111								; Set activity to rising edge
	sts EICRA, r16								; 
	ldi r16, 0b11								; 
	out EIMSK, r16								; External Interrupt Request 1 and 2 Enable
	///////////////////////////////////////////
	ldi timerCounter, counterValue				; set timercounter
	ldi numberOfInterrupts, 0					; Reset number of interrupts
	ldi dutyCycleRegister, defaultDutyCycleVal	; SET DEFAULT DUTY CYCLE

	///////////////////////////////////////////

	ldi r16, 0x05								; set prescaler to 0b0000_0101 which sets prescaler to 1024
	out TCCR0B, r16								; prescaler
	ldi timerRegister, timerValue				;  for 500ms
	out TCNT0, timerRegister					; set counter to 256 - 31cycles so interrupt is called at 500ms
	ldi r16, 0x01								; set bit 0 to 1 in TIMSK to enable overflow interrupt
	sts TIMSK0, r16								; Enable timer interrupt
	
	ldi lightRegister, 0xFF						; TURN ON LIGHT
	out PORTB, lightRegister
	sei											; set global interrupt



default:	
	cp numberOfInterrupts, dutyCycleRegister
	breq ledOFF									; IF EQUAL, TURN OFF LED 
	cpi dutyCycleRegister, maxDutyCycleVal
	brsh setMinValue							

	cpi numberOfInterrupts, counterValue		; IF EQUAL, RESET numberOfInterrupts and start over.
	breq reset
	rjmp default


// Makes sure duty cycle doesn't go from 0x00 -> 0xFF when lowering stepping.
setMinValue:
	ldi dutyCycleRegister, 0
	rjmp default

/////////////////////////////////
////////////////////////////////
// Runs 5ms interrupt x times /
//////////////////////////////
/////////////////////////////
timer0int:
	push timerRegister							; save state to stack
	in timerRegister, SREG						; save sreg to stack
	push timerRegister							; save
	out TCNT0, timerRegister					; Output to counter register so it 
	pop timerRegister				
	out SREG, timerRegister						; restore sreg
	pop timerRegister							; restore counter
	inc numberOfInterrupts						; Number of interrupts
	reti										; return interrupt

ledOFF:
	ldi lightRegister, 0x00
	out PORTB, lightRegister					; TURN OFF LED
	rjmp default


increase:
	rcall btn_delay
	inc dutyCycleRegister
	inc dutyCycleRegister
	inc dutyCycleRegister
	inc dutyCycleRegister
	inc dutyCycleRegister
	reti
	
// Decreasing by 5 represents a 5% decrease of duty cycle
decrease: 
	rcall btn_delay
	dec dutyCycleRegister
	dec dutyCycleRegister
	dec dutyCycleRegister
	dec dutyCycleRegister
	dec dutyCycleRegister
	reti

reset:
	ldi numberOfInterrupts, 0
	ldi lightRegister, 0xFF
	out PORTB, lightRegister
	rjmp default



; 20ms delay for button
btn_delay:
	ldi  r18, 21
    ldi  r19, 192
L3: dec  r19
    brne L3
    dec  r18
    brne L3
    nop
	ret
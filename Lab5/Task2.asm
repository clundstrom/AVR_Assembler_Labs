;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-11
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 5
; Title: Task 2.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Bingo number generator (0-75)
;
; Input ports: PINB
;
; Output ports: PORTD
;
; Other information: 
;
; Changes in program: 11/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m328pdef.inc"
.def	Temp	= r16
.def	Data	= r17
.def	RS	= r18
.equ	BITMODE4	= 0b00000010		; 4-bit operation
.equ	CLEAR	= 0b00000001			; Clear display
.equ	DISPCTRL	= 0b00001111		; Display on, cursor on, blink on.
.def	NIBBLE1 = r19					; Nibble1 represents the first number.
.def	NIBBLE2 = r20					; Nibble2 second number.
.def	TABLEMASK = r21					; Register used for masking the number column of the characters.
.def	INPUT = r22						; Input from button.

.cseg
.org	0x0000				; Reset vector
	jmp reset

.org	0x0072
reset:	

	ldi Temp, HIGH(RAMEND)	; Temp = high byte of ramend address
	out SPH, Temp			; sph = Temp
	ldi Temp, LOW(RAMEND)	; Temp = low byte of ramend address
	out SPL, Temp			; spl = Temp
	ser Temp				; r16 = 0b11111111
	out DDRD, Temp			; port D = outputs ( Display JHD202A)
	clr Temp				; r16 = 0
	out PORTD, Temp	

	ldi r16, 0x00			
	out DDRB, r16						;
	ldi TABLEMASK, 0b0000_0011			; TABLEMASK used for getting correct characters.


; **
; ** init_display
; **
init_disp:	
	rcall power_up_wait		; wait for display to power up
	rcall power_up_wait
	rcall power_up_wait
	rcall power_up_wait
	rcall power_up_wait
	ldi Data, BITMODE4		; 4-bit operation
	rcall write_nibble		; (in 8-bit mode)
	rcall short_wait		; wait min. 39 us
	ldi Data, DISPCTRL		; disp. on, blink on, curs. On
	rcall write_cmd			; send command
	rcall short_wait		; wait min. 39 us

	ldi NIBBLE1, 0b0000_0000			; set nibbles to 0 from start.
	ldi NIBBLE2, 0b0000_0000
	rcall clr_disp						; and clear display

loop:
	cpi NIBBLE1, 0b0000_0111			; IF nibble1 == 7 && nibble2 => 6 -> Set nibble2 = 0
	breq check_nibble2max				;----------------------------------------------------

	in INPUT, PINB						; Input from button
	andi INPUT, 0b1111_1100				; Verify input
	cpi INPUT, 0b0000_0100				; Check for button press
	breq load_output					; If button pressed -> Load to output

	inc NIBBLE1							; else increase nibble 1
	cpi NIBBLE1, 0b0000_0111			
	breq resetNibble1					; make sure nibble1 <= 7
	inc NIBBLE2							; and increase nibble 2
	cpi NIBBLE2, 0b0000_1001			; make sure nibble2 <= 9
	breq resetNibble2

    nop
	rjmp loop			

; Makes sure nibble 2 is never greater than 5 if nibble1 is 7
check_nibble2max:
	cpi NIBBLE2, 0b0000_0110
	brsh resetNibble2
	ret	

; Formats nibble into corresponding number and write output.
load_output:
	rcall clr_disp
	swap NIBBLE1
	or NIBBLE1, TABLEMASK
	mov Data, NIBBLE1
	rcall write_char
	rcall short_wait
	swap NIBBLE2
	or NIBBLE2, TABLEMASK
	mov Data, NIBBLE2
	rcall write_char
	rcall short_wait
	ret

; functions to reset NIBBLE1 & 2
resetNibble1:
	clr NIBBLE1
	rjmp loop

resetNibble2:
	clr NIBBLE2
	rjmp loop

clr_disp:	
	ldi Data, CLEAR			; clr display
	rcall write_cmd			; send command
	rcall long_wait			; wait min. 1.53 ms
	ret

; **
; ** write char/command
; **

write_char:		
	ldi RS, 0b00100000		; RS = high
	rjmp write
write_cmd: 	
	clr RS					; RS = low
write:	
	mov Temp, Data			; copy Data
	andi Data, 0b11110000	; mask out high nibble
	swap Data				; swap nibbles
	or Data, RS				; add register select
	rcall write_nibble		; send high nibble
	mov Data, Temp			; restore Data
	andi Data, 0b00001111	; mask out low nibble
	or Data, RS				; add register select

write_nibble:
	rcall switch_output		; Modify for display JHD202A, port E
	nop						; wait 542nS
	sbi PORTD, 5			; enable high, JHD202A
	nop
	nop						; wait 542nS
	cbi PORTD, 5			; enable low, JHD202A
	nop
	nop						; wait 542nS
	ret

; **
; ** busy_wait loop
; **
short_wait:	
	clr zh					; approx 50 us
	ldi zl, 255
	rjmp wait_loop
long_wait:	
	ldi zh, HIGH(16000)		; approx 2 ms
	ldi zl, LOW(16000)
	rjmp wait_loop
dbnc_wait:	
	ldi zh, HIGH(65536)		; approx 10 ms
	ldi zl, LOW(65536)
	rjmp wait_loop
power_up_wait:
	ldi zh, HIGH(65536)		; approx 20 ms
	ldi zl, LOW(65536)

wait_loop:	
	sbiw z, 1				; 2 cycles
	brne wait_loop			; 2 cycles
	ret

; **
; ** modify output signal to fit LCD JHD202A, connected to port E
; **

switch_output:
	push Temp
	clr Temp
	sbrc Data, 0				; D4 = 1?
	ori Temp, 0b00000100		; Set pin 2 
	sbrc Data, 1				; D5 = 1?
	ori Temp, 0b00001000		; Set pin 3 
	sbrc Data, 2				; D6 = 1?
	ori Temp, 0b00000001		; Set pin 0 
	sbrc Data, 3				; D7 = 1?
	ori Temp, 0b00000010		; Set pin 1 
	sbrc Data, 4				; E = 1?
	ori Temp, 0b00100000		; Set pin 5 
	sbrc Data, 5				; RS = 1?
	ori Temp, 0b10000000		; Set pin 7 (wrong in previous version)
	out PORTD, Temp
	pop Temp
	ret
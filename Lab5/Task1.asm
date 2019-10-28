;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-11
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 5
; Title: Task 1.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Print % on display.
;
; Input ports: null
;
; Output ports: PORTD
;
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
.equ	PERCENT = 0b0010_0101			; percent sign

.cseg
.org	0x0000							; Reset vector
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

;this is where your code starts



rcall clr_disp				; Clears the display.
ldi Data, PERCENT			; Load percent sign into Data.
rcall write_char			; Write char to display.

loop:
    nop
rjmp loop			



;this is where your code ends



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
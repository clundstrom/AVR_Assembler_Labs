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
; Function: Uses interrupt to blink left and blink right. Simulates blinkers on a car.
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: init_stack, blink_left, blink_right, default, delay500, delay100, btn_delay, return
;
; Other information: 
;
; Changes in program: 03/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.EQU normal = 0b0011_0011
.EQU turnRight = 2						; Used for comparison
.EQU turnLeft = 1						; Used for comparison
.DEF turnAddr = r22						; If 1 -> blink left  if 2 -> blink right
.DEF blinkAddr = r17
.DEF counter = r21

.org 0x00
rjmp init_stack

.org INT0addr
ldi blinkAddr, 1
rjmp blink_left

.org INT1addr
ldi blinkAddr, 2
rjmp blink_right


init_stack:
	ldi r20, HIGH(RAMEND)	
	out SPH, r20			
	ldi r20, LOW(RAMEND)	
	out SPL, r20			
	ldi r16, 0xFF			
	out DDRB, r16						; Set output
	ldi r16, 0b1111						; Set activity to rising edge
	sts EICRA, r16						; 
	
	ldi r16, 0b11						; 
	out EIMSK, r16						; External Interrupt Request 1 and 2 Enable
	ldi counter, 2
	sei									; Enable global interrupt.


; Specifies the default behavior when not blinking a light.
default:
	ldi counter, 2
	ldi r16, normal	; normal light
	out PORTB, r16			
	rjmp default
	
;Interrupt routine for blinking right.
;It runs the blink routine twice before returning to default light setup.
blink_left:	
	rcall btn_delay					; Blink for 2 cycles then return to DEFAULT.
	cpi counter, 0					; If counter is 0 return
	breq return		
	ldi r18, 0b0011_0011			; Light normal		
	out PORTB, r18					;
	rcall delay500					; Delay 500 before each loop
	ldi r18, 0b0000_1011			
	out PORTB, r18					; Light 1
	rcall delay100					; Delay 100
	ldi r18, 0b0001_1011			
	out PORTB, r18					; Light 2
	rcall delay100					; Delay 100
	ldi r18, 0b0011_1011
	out PORTB, r18					; Light 3
	rcall delay100					; Delay 100
	ldi r18, 0b1111_1011
	out PORTB, r18					; Light 4
	rcall delay100					; Delay 100
	dec counter
	rjmp blink_left
	

;Interrupt routine for blinking right.
;It runs the blink routine twice before returning to default light setup.
blink_right:
	rcall btn_delay
	cpi counter, 1					; If counter is 2 return
	breq return
	ldi r18, 0b0011_0011			; Light normal
	out PORTB, r18
	rcall delay500					; Delay 500 before
	ldi r18, 0b0011_0100			
	out PORTB, r18					; Light 1
	rcall delay100					; Delay 100
	ldi r18, 0b0011_0110			;
	out PORTB, r18					; Light 2
	rcall delay100					; Delay 100
	ldi r18, 0b0011_0111
	out PORTB, r18					; Light 3
	rcall delay100					; Delay 100
	ldi r18, 0b0011_0111		
	out PORTB, r18					; Light 4
	rcall delay100					; Delay 100
	dec counter						; increase counter
	rjmp blink_right				; Loop back



; Function called to return to default light setup.
return: 
ldi counter, 2
reti


; 500ms delay
delay500:
    ldi  r18, 17
    ldi  r19, 60
    ldi  r20, 204
L2: dec  r20
    brne L2
    dec  r19
    brne L2
    dec  r18
    brne L2
	ret

; 100ms delay
delay100:
    ldi  r18, 9
    ldi  r19, 30
    ldi  r20, 229
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	ret

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
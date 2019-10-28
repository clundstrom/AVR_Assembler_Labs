;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2019-10-03
; Author:
; Christoffer Lundström
; Marcus Johansson
;
; Lab number: 3
; Title: Task 1.
;
; Hardware: Arduino UNO Rev 3, CPU ATmega328P
;
; Function: Switch LED On/Off
;
; Input ports: null
;
; Output ports: PORTB
;
; Subroutines: start, ledSwitch, main
;
; Other information: Uses interrupt to invert an output bitmask.
;
; Changes in program: 03/10 2019
;
; 
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.DEF LED_OFF = r18

.org 0x00
rjmp start

.org INT0addr								; interrupt vector. Used when interrupted.
rjmp ledSwitch

.org 0x72

start:										;setup program and stack
ldi r20, HIGH(RAMEND)
out SPH, r20
ldi r20, LOW(RAMEND)
out SPL, r20
ldi r18, 0x00

ldi r16, 0x01
out DDRB, r16
out PORTB, LED_OFF							; output nothing


ldi r16, 0b10
sts EICRA, r16								; Activity on this will trigger an interrupt request

ldi r16, 0b01								; set bit 0 to 1 in EIMSK
out EIMSK, r16								; External interrupt mask register 0-7 corresponding external pin interrupt is enabled

sei											; makes sure next instruction is run before interrupt

main: 
nop
rjmp main

ledSwitch:
com LED_OFF
out PORTB, LED_OFF
reti										; return interrupt flag
;*************************************************************** 
;* Feladat: 
;* Rövid leírás:
; 
;* Szerzõk: 
;* Mérõcsoport: <merocsoport jele>
;
;***************************************************************
;* "AVR ExperimentBoard" port assignment information:
;***************************************************************
;*
;* LED0(P):PortC.0          LED4(P):PortC.4
;* LED1(P):PortC.1          LED5(P):PortC.5
;* LED2(S):PortC.2          LED6(S):PortC.6
;* LED3(Z):PortC.3          LED7(Z):PortC.7        INT:PortE.4
;*
;* SW0:PortG.0     SW1:PortG.1     SW2:PortG.4     SW3:PortG.3
;* 
;* BT0:PortE.5     BT1:PortE.6     BT2:PortE.7     BT3:PortB.7
;*
;***************************************************************
;*
;* AIN:PortF.0     NTK:PortF.1    OPTO:PortF.2     POT:PortF.3
;*
;***************************************************************
;*
;* LCD1(VSS) = GND         LCD9(DB2): -
;* LCD2(VDD) = VCC         LCD10(DB3): -
;* LCD3(VO ) = GND         LCD11(DB4): PortA.4
;* LCD4(RS ) = PortA.0     LCD12(DB5): PortA.5
;* LCD5(R/W) = GND         LCD13(DB6): PortA.6
;* LCD6(E  ) = PortA.1     LCD14(DB7): PortA.7
;* LCD7(DB0) = -           LCD15(BLA): VCC
;* LCD8(DB1) = -           LCD16(BLK): PortB.5 (1=Backlight ON)
;*
;***************************************************************

.include "m128def.inc" ; Definition file for ATmega128 
;* Program Constants 
.equ const =$00 ; Generic Constant Structure example  
;* Program Variables Definitions 
.def temp =r16 ; Temporary Register example 

;*************************************************************** 
;* Reset & Interrupt Vectors  
.cseg 
.org $0000 ; Define start of Code segment 
	jmp RESET ; Reset Handler, jmp is 2 word instruction 
	jmp DUMMY_IT	; Ext. INT0 Handler
	jmp DUMMY_IT	; Ext. INT1 Handler
	jmp DUMMY_IT	; Ext. INT2 Handler
	jmp DUMMY_IT	; Ext. INT3 Handler
	jmp DUMMY_IT	; Ext. INT4 Handler (INT gomb)
	jmp DUMMY_IT	; Ext. INT5 Handler
	jmp DUMMY_IT	; Ext. INT6 Handler
	jmp DUMMY_IT	; Ext. INT7 Handler
	jmp DUMMY_IT	; Timer2 Compare Match Handler 
	jmp DUMMY_IT	; Timer2 Overflow Handler 
	jmp DUMMY_IT	; Timer1 Capture Event Handler 
	jmp TIMER_IT	;asddasads Timer1 Compare Match A Handler 
	jmp DUMMY_IT	; Timer1 Compare Match B Handler 
	jmp DUMMY_IT	; Timer1 Overflow Handler 
	jmp PERGES_IT	; Timer0 Compare Match Handler 
	jmp DUMMY_IT	; Timer0 Overflow Handler 
	jmp DUMMY_IT	; SPI Transfer Complete Handler 
	jmp DUMMY_IT	; USART0 RX Complete Handler 
	jmp DUMMY_IT	; USART0 Data Register Empty Hanlder 
	jmp DUMMY_IT	; USART0 TX Complete Handler 
	jmp DUMMY_IT	; ADC Conversion Complete Handler 
	jmp DUMMY_IT	; EEPROM Ready Hanlder 
	jmp DUMMY_IT	; Analog Comparator Handler 
	jmp DUMMY_IT	; Timer1 Compare Match C Handler 
	jmp DUMMY_IT	; Timer3 Capture Event Handler 
	jmp DUMMY_IT	; Timer3 Compare Match A Handler 
	jmp DUMMY_IT	; Timer3 Compare Match B Handler 
	jmp DUMMY_IT	; Timer3 Compare Match C Handler 
	jmp DUMMY_IT	; Timer3 Overflow Handler 
	jmp DUMMY_IT	; USART1 RX Complete Handler 
	jmp DUMMY_IT	; USART1 Data Register Empty Hanlder 
	jmp DUMMY_IT	; USART1 TX Complete Handler 
	jmp DUMMY_IT	; Two-wire Serial Interface Handler 
	jmp DUMMY_IT	; Store Program Memory Ready Handler 

.org $0046

;****************************************************************
;* DUMMY_IT interrupt handler -- CPU hangup with LED pattern
;* (This way unhandled interrupts will be noticed)

;< többi IT kezelõ a fájl végére! >

DUMMY_IT:	
	ldi r16,   0xFF ; LED pattern:  *-
	out DDRC,  r16  ;               -*
	ldi r16,   0xA5	;               *-
	out PORTC, r16  ;               -*
DUMMY_LOOP:
	rjmp DUMMY_LOOP ; endless loop

;< többi IT kezelõ a fájl végére! >

;*************************************************************** 
;* MAIN program, Initialisation part
.org $004B;
RESET: 
;* Stack Pointer init, 
;  Set stack pointer to top of RAM 
	ldi temp, LOW(RAMEND) ; RAMEND = "max address in RAM"
	out SPL, temp 	      ; RAMEND value in "m128def.inc" 
	ldi temp, HIGH(RAMEND) 
	out SPH, temp 

M_INIT:
;< ki- és bemenetek inicializálása stb > 

	;** regiszterek **
	.def btn_crnt 	= r17
	.def btn_prev 	= r18
	.def start_seq 	= r19
	.def sw_crnt	= r20
	.def sw_prev	= r21
	.def led		= r22
	.def time_it    = r23
	.def perg_it  	= r24
	.def perg_7ms	= r25

	;** I/O init **
	ldi temp, 0xFF
	out DDRC, temp ; LED kimenet
	ldi temp, 0x00
	out DDRE, temp ; BTN bemenet
	sts DDRG, temp ; SW bemenet

	;** regiszterek kezdoertek **
	in btn_prev, PINE
	lds sw_prev, PING
	ldi start_seq, 0
	ldi led, 0b00000001
	ldi perg_7ms, 7
	ldi perg_it, 0

	;** PERG_IT ***
	ldi temp, 3		; 10800/108 = 100Hz --> 0.01s (6-ot fogunk szamolni 6ms)
	out OCR0, temp
	ldi temp, 0b00001111 ; CTC mod es 1024 eloosztas
	out TCCR0, temp
	ldi temp, 0
	out TCNT0, temp

;	ldi temp, 0b00000010 ; megszakitas, ha TCNT == OCR
;	out TIMSK, temp	
;	sei
	
	;** TIMER_IT **
	ldi temp, 0b00000000 ; CTC mód és 1024 eloosztás
	out TCCR1A, temp
	ldi temp, 0b00001101
	out TCCR1B, temp
	ldi temp, HIGH(100) ; a 16 bites OCR reg. közül az OCRA-t választjuk
	out OCR1AH, temp
	ldi temp, LOW(100)
	out OCR1AL, temp
	ldi temp, 0 ; nullázzuk a 16 bites számlálót
	out TCNT1H, temp
	out TCNT1L, temp


	ldi temp, 0b00010010 ; megszakítás, ha TCNT == OCR
	out TIMSK, temp
	sei ; globális IT engedélyezé

;*************************************************************** 
;* MAIN program, Endless loop part
 
M_LOOP: 

;< fõciklus >
	out PORTC, led				; PORTC = led
	cpi perg_it, 0xFF			; if (perges_it == 1)
	brne VILLOGTATAS			; {
	ldi perg_it, 0x00			;	perges_it = 0
	call GOMB_KEZELES			;   GOMB_KEZELES()
	call SW_KEZELES				;   SW_KEZELES()
VILLOGTATAS:					; }
	cpi start_seq, 0xFF			; if (start_seq == 1)
	brne M_LOOP					; {
	cpi time_it, 0xFF			;	if (time_it == 1)
	brne M_LOOP					;	{
	call INC_LED				;	  INC_LED()
	ldi time_it, 0x00			;	  time_it = 0
	jmp M_LOOP ; Endless Loop  


;*************************************************************** 
;* Subroutines, Interrupt routines

;*** TIMER 1 *********
TIMER_IT:
	push temp
	in temp, SREG
	push temp

	ldi time_it, 0xFF

	pop temp
	out SREG, temp
	pop temp
	reti
;*** TIMER 0 ********
PERGES_IT:
	push temp
	in temp, SREG
	push temp

	dec perg_7ms
	brne NEM_JART_LE
	ldi perg_it, 0xFF
	ldi perg_7ms, 7

NEM_JART_LE:
	pop temp
	out SREG, temp
	pop temp
	reti

;*** SW kezeles ***

SW_KEZELES:
	mov sw_prev, sw_crnt		; sw_prev = sw_crnt		
	lds sw_crnt, PING			; sw_crnt = PING
	cp sw_prev, sw_crnt			; equals = (sw_prev == sw_crnt)
	breq SW_KEZELES_RET			; if (!equals)
	sbrs sw_crnt, 0				; 	if (sw_crnt[0] == 0) // le van nyomva
	jmp SET_SW_2_SEC			;		SET_SW_2_SEC() return;
	sbrs sw_crnt, 1				;   if (sw_crnt[1] == 0)
	jmp SET_SW_1_SEC			;		SET_SW_1_SEC() return;
	sbrs sw_crnt, 4				;   if (sw_crnt[4] == 0)
	jmp SET_SW_05_SEC			;		SET_SW_05_SEC() return;
	sbrs sw_crnt, 3				;   if (sw_crnt[3] == 0)
	jmp SET_SW_025_SEC			;		SET_SW_025_SEC() return;

SW_KEZELES_RET:
	ret

SET_SW_2_SEC:
	ldi temp, HIGH(400) ; 21600 --> 2 sec
	out OCR1AH, temp
	ldi temp, LOW(400)
	out OCR1AL, temp
	ldi temp, 0 ; nullázzuk a 16 bites számlálót
	out TCNT1H, temp
	out TCNT1L, temp
	jmp SW_KEZELES_RET

SET_SW_1_SEC:
	ldi temp, HIGH(200) ; 10800 --> 1 sec
	out OCR1AH, temp
	ldi temp, LOW(200)
	out OCR1AL, temp
	ldi temp, 0 ; nullázzuk a 16 bites számlálót
	out TCNT1H, temp
	out TCNT1L, temp
	jmp SW_KEZELES_RET

SET_SW_05_SEC:
	ldi temp, HIGH(100) ; 5400 --> 0,5 sec
	out OCR1AH, temp
	ldi temp, LOW(100)
	out OCR1AL, temp
	ldi temp, 0 ; nullázzuk a 16 bites számlálót
	out TCNT1H, temp
	out TCNT1L, temp
	jmp SW_KEZELES_RET

SET_SW_025_SEC:
	ldi temp, HIGH(50) ; 2700 --> 0,25 sec
	out OCR1AH, temp
	ldi temp, LOW(50)
	out OCR1AL, temp
	ldi temp, 0 ; nullázzuk a 16 bites számlálót
	out TCNT1H, temp
	out TCNT1L, temp
	jmp SW_KEZELES_RET

;*** BTN kezeles ****

GOMB_KEZELES:
	mov btn_prev, btn_crnt		; btn_prev = btn_crnt
	in btn_crnt, PINE			; btn_crnt = PINE
	cpi btn_crnt, 0				; if (btn_crnt == 0)
	brne GOMB_KEZELES_RET		; {
	cpi btn_prev, 0b01000000	; 	if (btn_prev == 1)
	brne GOMB_KEZELES_RET		;   {
	com start_seq				; 	  start_seq = !start_seq
	
GOMB_KEZELES_RET:
	ret

;*** LED kezeles **

INC_LED:
	cpi led, 1        ; nulladik LED-nel jarunk-e
	brne ELSO_LED
	ldi led, 2
VISSZATERES:
	ret

ELSO_LED:
	cpi led, 2        ; elso LED-nel jarunk-e
	brne MASODIK_LED
	ldi led, 4
	jmp VISSZATERES

MASODIK_LED:
	cpi led, 4
	brne HARMADIK_LED ; masodik LED-nel jarunk-e
	ldi led, 8
	jmp VISSZATERES

HARMADIK_LED:
	cpi led, 8
	brne HETEDIK_LED  ; harmadik LED-nel jarunk-e
	ldi led, 128
	jmp VISSZATERES

HETEDIK_LED:
	cpi led, 128
	brne HATODIK_LED ; hetedik LED-nel jarunk-e
	ldi led, 64
	jmp VISSZATERES

HATODIK_LED:
	cpi led, 64
	brne OTODIK_LED  ; hatodik LED-nel jarunk-e
	ldi led, 32
	jmp VISSZATERES

OTODIK_LED:
	cpi led, 32
	brne NEGYEDIK_LED ; otodik LED-nel jarunk-e
	ldi led, 16
	jmp VISSZATERES

NEGYEDIK_LED:
	cpi led, 16
	brne INC_LED
	ldi led, 1
	jmp VISSZATERES












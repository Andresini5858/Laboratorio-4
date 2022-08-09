;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Andrés Lemus 21634
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Laboratorio 4
;Creado: 08/08/2022
;Última Modificación: 08/08/22
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc>
;*******************************************************************************
;Palabra de Configuración
;*******************************************************************************

;CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

;CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)


;*******************************************************************************
;Variables
;*******************************************************************************
PSECT udata_shr
    cont: DS 1
    W_TEMP: DS 1
    STATUS_TEMP: DS 1
    
;*******************************************************************************
;Vector Reset
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto main
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
PUSH:
    MOVWF W_TEMP	    ; guardamos el valor de w
    SWAPF STATUS, W	    ; movemos los nibles de status en w
    MOVWF STATUS_TEMP	    ; guardamos el valor de w en variable. 
			    ; temporal de status
ISR:  
    BTFSS INTCON, 0	    ; Está encendido el bit T0IF?
    GOTO POP
    BCF INTCON, 0
    BTFSC PORTB, 0
    INCF PORTA, F
    BTFSC PORTB, 1
    DECF PORTA, F
    BCF INTCON, 0
    GOTO POP
  
POP:
    SWAPF STATUS_TEMP, W    ; movemos los nibles de status de nuevo y los
			    ; cargamos a W
    MOVWF STATUS	    ; movemos el valor de W al registro STATUS
    SWAPF W_TEMP, F	    ; Movemos los nibles de W en el registro temporal
    SWAPF W_TEMP, W	    ; Movemos los nibles de vuelta para tenerlo en W
    RETFIE		    ; Retornamos de la interrupción

;*******************************************************************************
;Código Principal
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0100
 
tabla:
    CLRF PCLATH
    BSF PCLATH, 0
    ANDLW 0x0F     ;Se pone límite de 15
    ADDWF PCL      ;suma entre pcl y w
    RETLW 00111111B;0
    RETLW 00000110B;1
    RETLW 01011011B;2
    RETLW 01001111B;3
    RETLW 01100110B;4
    RETLW 01101101B;5
    RETLW 01111101B;6
    RETLW 00000111B;7
    RETLW 01111111B;8
    RETLW 01100111B;9
    
main:
    
    BANKSEL ANSEL  ;Puertos como digitales
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISA
    CLRF TRISA	      ;PUERTO A COMO SALIDA 
    CLRF TRISC	      ;PUERTO B COMO SALIDA
    CLRF TRISD        ;PUERTO C COMO SALIDA
    CLRF TRISE	      ;PUERTO E COMO SALIDA
    
    BANKSEL TRISB
    BSF TRISB, 0      ;RB0 COMO ENTRADA
    BSF TRISB, 1      ;RB1 COMO ENTRADA
    BSF TRISB, 2      ;RB1 COMO ENTRADA
    BSF TRISB, 3      ;RB1 COMO ENTRADA
    
    BANKSEL PORTA     ;LIMPIAR PUERTOS
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC 
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL WPUB
    BSF WPUB, 0
    BSF WPUB, 1
    BSF WPUB, 2
    BSF WPUB, 3
    
    BANKSEL IOCB
    BSF IOCB, 0
    BSF IOCB, 1
    BSF IOCB, 2
    BSF IOCB, 3
    
    BANKSEL INTCON
    BSF INTCON, 7
    BSF INTCON, 3
    BCF INTCON, 0
    
loop:
    goto loop
    
END
    
    




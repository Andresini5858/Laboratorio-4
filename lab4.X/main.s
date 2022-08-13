;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Andrés Lemus 21634
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Laboratorio 4
;Creado: 08/08/2022
;Última Modificación: 13/08/22
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
  CONFIG  BOREN = OFF            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

;CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)


;*******************************************************************************
;Variables
;*******************************************************************************
PSECT udata_shr
    cont: DS 1
    cont1: DS 1
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
    
TIMER:
    BTFSS INTCON, 2
    GOTO ISR
    BCF INTCON, 2
    INCF cont1, F
    MOVLW 217
    BANKSEL TMR0
    MOVWF TMR0	      ;CARGAMOS EL VALOR DE N = DESBORDE 100mS
    
ISR:  
    BTFSS INTCON, 0	    ; Está encendido el bit T0IF?
    GOTO POP
    BANKSEL PORTB
    BTFSS PORTB, 6
    INCF PORTA, F
    BTFSS PORTB, 7
    DECF PORTA, F
    BCF INTCON, 0
  
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
 
;tabla:
    ;CLRF PCLATH
    ;BSF PCLATH, 0
    ;ANDLW 0x0F     ;Se pone límite de 15
    ;ADDWF PCL      ;suma entre pcl y w
    ;RETLW 00111111B;0
    ;RETLW 00000110B;1
    ;RETLW 01011011B;2
    ;RETLW 01001111B;3
    ;RETLW 01100110B;4
    ;RETLW 01101101B;5
    ;RETLW 01111101B;6
    ;RETLW 00000111B;7
    ;RETLW 01111111B;8
    ;RETLW 01100111B;9
       
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
    BSF TRISB, 6
    BSF TRISB, 7
    BCF TRISB, 0
    BCF TRISB, 1
    BCF TRISB, 2      ;RB0 COMO ENTRADA
    BCF TRISB, 3      ;RB1 COMO ENTRADA
    
    BANKSEL PORTA     ;LIMPIAR PUERTOS
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC 
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL WPUB
    BCF WPUB, 0
    BCF WPUB, 2
    BCF WPUB, 3
    BSF WPUB, 6
    BSF WPUB, 7
    
    BANKSEL IOCB
    BCF IOCB, 0
    BCF IOCB, 2
    BCF IOCB, 3
    BSF IOCB, 6
    BSF IOCB, 7
    ;MOVLW 11000000B
    ;MOVWF WPUB
    ;MOVWF IOCB
    ;CLRW
    
    BANKSEL INTCON
    BSF INTCON, 7
    BSF INTCON, 5
    BSF INTCON, 3
    BCF INTCON, 0
    
    BANKSEL OSCCON
    BSF OSCCON, 6  ;Configuramos la frecuencia de oscilación a 2 MHz
    BCF OSCCON, 5
    BSF OSCCON, 4
    
    BSF OSCCON, 0  ;Utilizar oscilador interno
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7
    BCF OPTION_REG, 5 ;Usar el Timer0 con el oscilador interno 
    BCF OPTION_REG, 3 ;Utilizar el prescaler con el Timer0
    
    BSF OPTION_REG, 2 ;Utilizar prescaler de 256
    BSF OPTION_REG, 1
    BSF OPTION_REG, 0
    
    CLRF cont1
    BANKSEL TMR0
    MOVWF TMR0	      ;CARGAMOS EL VALOR DE N = DESBORDE 100mS
    
    
loop:
    INCF PORTB, F
    ;INCF cont, F
    ;MOVF cont, W
    ;call table
    ;MOVWF PORTB
    MOVF cont1, W
    SUBLW 50
    BTFSS STATUS, 2	; verificamos bandera z
    GOTO $-3
    CLRF cont1
    GOTO loop
    
END
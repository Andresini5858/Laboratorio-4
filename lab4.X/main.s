;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Andrés Lemus 21634
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Laboratorio 4
;Creado: 08/08/2022
;Última Modificación: 14/08/22
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
  CONFIG  MCLRE = OFF            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

;CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)


;*******************************************************************************
;Variables
;*******************************************************************************
PSECT udata_shr
    ban: DS 1
    cont1: DS 1
    cont2: DS 1
    cont3: DS 1
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
    MOVWF W_TEMP	    ;GUARDAR EL VALOR DE W (EN UNA VARIABLE)
    SWAPF STATUS, W	    ;MOVER EL VALOR DE STATUS A W (VOLTEADOS)
    MOVWF STATUS_TEMP	    ;MOVER EL VALOR DE STATUS (AHORA EN W) A UNA VARIABLE
    
ISR:  
    BTFSC INTCON, 0	    ;REVISAR EL BIT DE INTERRUPCIONES DEL PUERTO B
    CALL PRTB		    ;IR A LA FUNCIóN DE LEDS DEL PUERTO B
    BTFSC INTCON, 2	    ;REVISAR EL BIT DE INTERRUPCIONES DEL Timer0
    CALL TIMER		    ;IR A LA FUNCIóN DEL Timer0
  
POP:
    SWAPF STATUS_TEMP, W    ;MOVER EL VALOR DE STATUS GUARDADO EN UNA VARIABLE A W
    MOVWF STATUS	    ;MOVER EL VALOR DE STATUS (AHORA EN W) A STATUS
    SWAPF W_TEMP, F	    ;VOLTEAR LOS NIBBLES PARA QUE AL MOVERLOS A W ESTEN EN ORDEN 
    SWAPF W_TEMP, W	    ;MOVER EL VALOR DE W GUARDADO A W
    RETFIE		    ;REGRESAR DE LA INTERRUPCIóN
    
PRTB:
    BTFSS INTCON, 0	    ;REVISAR EL BIT DE INTERRUPCIONES DEL PUERTO B
    RETURN		    ;REGRESAR
    BANKSEL PORTB	    ;IR AL BANCO DONDE SE ENCUENTRA EL REGISTRO DE LOS PUERTOS
    BTFSC PORTB, 6	    ;REVISAR SI EL BOTóN DE INCREMENTAR FUE PRESIONADO
    CALL anti1		    ;LLAMAR AL ANTIRREBOTE
    BTFSS PORTB, 6	    ;REVISAR SI SE DEJO DE PRESIONAR EL BOTON
    CALL inc1
    BTFSC PORTB, 7	    ;REVISAR SI EL BOTóN DE DECREMENTAR FUE PRESIONADO
    CALL anti2
    BTFSS PORTB, 7
    CALL dec1
    BCF INTCON, 0	    ;LIMPIAR BIT DE INTERRUPCIóN DEL PUERTO B
    RETURN		    ;REGRESAR
    
TIMER:
    MOVLW 217		    ;MOVEMOS EL VALOR PARA DELAY DE 20ms A W
    BANKSEL TMR0	    ;IR AL BANCO DEL Timer0
    MOVWF TMR0		    ;CARGAMOS EL VALOR DE N = DESBORDE 20mS
    BCF INTCON, 2	    ;LIMPIAR BIT DE INTERRUPCIóN DEL Timer0
    INCF cont1, F	    ;INCREMENTAMOS CONTADOR PARA DELAY DE 1s
    MOVF cont1, W	    ;MOVEMOS EL CONTADOR DE 1s W
    SUBLW 50		    ;RESTAMOS 50 DE W
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA DE 0
    RETURN		    ;SI NO ES 0, RETORNAR
    INCF PORTB		    ;INCREMENTAR PUERTO B CADA SEGUNDO
    CLRF cont1		    ;SI ES 0 LIMPIAR EL CONTADOR DE 1s
    GOTO veri1		    ;IR A FUNCIóN PARA AUMENTAR CONTADOR DE DISPLAY 1
    
veri1:
    INCF cont2, F	    ;INCREMENTAR CONTADOR DE UNIDADES DE SEGUNDO
    MOVF cont2, W	    ;MOVER EL VALOR DEL CONTADOR A W
    SUBLW 10		    ;RESTAR 10 DE W
    BTFSS STATUS, 2	    ;REVISAR SI LA RESTA ES 0
    RETURN		    ;SI LA RESTA NO ES 0, RETORNAR
    CLRF cont2		    ;SI ES 0, REINCIAR EL CONTADOR
    GOTO veri2		    ;IR A LA FUNCIóN DE DECENAS DE SEGUNDOS
    
veri2:
    INCF cont3, F	    ;INCREMENTAR CONTADOR DE DECENAS DE SEGUNDO
    MOVF cont3, W	    ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 6		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    RETURN		    ;SI NO ES 0, RETORNAMOS
    CLRF cont2		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF cont3              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    RETURN		    ;RETORNAR, PARA LUEGO IR A POP

inc1:			    ;FUNCION DE INCREMENTAR
    BTFSS ban, 0
    RETURN
    INCF PORTD, F
    CLRF ban
    RETURN

dec1:
    BTFSS ban, 1	    ;FUNCION DE DECREMENTAR
    RETURN
    DECF PORTD, F
    CLRF ban
    RETURN

anti1:			    ;ANTIRREBOTE 1
    BSF ban, 0
    RETURN
    
anti2:			    ;ANTIRREBOTE 2
    BSF ban, 1
    RETURN

;*******************************************************************************
;Código Principal
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0100
 
tabla:			    ;TABLA DE VALORES PARA DISPLAY
    CLRF PCLATH
    BSF PCLATH, 0
    ANDLW 0x0F		    ;SE PONE UN LíMITE DE 15
    ADDWF PCL		    ;SUMA ENTRE PCL Y W
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
    RETLW 01110111B;A
    RETLW 01111100B;B
    RETLW 00111001B;C
    RETLW 01011110B;D
    RETLW 01111001B;E
    RETLW 01110001B;F

main:
    
    BANKSEL ANSEL	    ;PONER PUERTOS COMO DIGITALES
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISA
    CLRF TRISA		    ;PUERTO A COMO SALIDA 
    CLRF TRISC		    ;PUERTO B COMO SALIDA
    CLRF TRISD		    ;PUERTO C COMO SALIDA
    CLRF TRISE		    ;PUERTO E COMO SALIDA
    
    BANKSEL TRISB	    
    BSF TRISB, 6	    ;RB6 COMO ENTRADA	    
    BSF TRISB, 7	    ;RB7 COMO ENTRADA
    BCF TRISB, 0	    ;RB0 COMO SALIDA
    BCF TRISB, 1	    ;RB1 COMO SALIDA
    BCF TRISB, 2	    ;RB2 COMO SALIDA
    BCF TRISB, 3	    ;RB3 COMO SALIDA
    
    BANKSEL PORTA	    ;LIMPIAR PUERTOS, PARA INICIARLOS VACIOS
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC 
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL WPUB	    ;DETERMINAR PINES QUE VAN A LLEVAR PULL-UPS
    BCF WPUB, 0		    ;NO PULL-UP
    BCF WPUB, 2		    ;NO PULL-UP
    BCF WPUB, 3		    ;NO PULL-UP
    BSF WPUB, 6		    ;SI PULL-UP
    BSF WPUB, 7		    ;SI PULL-UP
    
    BANKSEL IOCB	    ;DETERMINAR PINES QUE VAN A LLEVAR INTERRUPCIóN ON-CHANGE    
    BCF IOCB, 0		    ;NO INTERRUPCIóN
    BCF IOCB, 2		    ;NO INTERRUPCIóN
    BCF IOCB, 3		    ;NO INTERRUPCIóN
    BSF IOCB, 6		    ;SI INTERRUPCIóN
    BSF IOCB, 7		    ;SI INTERRUPCIóN
    
    BANKSEL INTCON	    ;ACTIVAR INTERRUPCIONES
    BSF INTCON, 7	    ;ACRIVAR BIT DE INTERRUPCIONES GLOBALES
    BSF INTCON, 5	    ;ACTIVAR BIT DE INTERRUPCIONES DEL TIMER0
    BSF INTCON, 3	    ;ACTIVAR BIT DE INTERRUPCIONES DEL PUERTO B

    BANKSEL OSCCON
    BSF OSCCON, 6	    ;CONFIGURAR OSCILADOR INTERNO A 2MHz
    BCF OSCCON, 5
    BSF OSCCON, 4
    
    BSF OSCCON, 0	    ;DETERMINAR QUE SE UTLIZARá OSCILADOR INTERNO
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ;LIMPIAR BIT PARA QUE SE PUEDAN USAR PULL-UPS DEL PUERTO B
    BCF OPTION_REG, 5	    ;UTILIZAR EL Timer0 CON EL OSCILADOR INTERNO 
    BCF OPTION_REG, 3	    ;UTILIZAR PRESCALER CON EL Timer0
    
    BSF OPTION_REG, 2	    ;PRESCALER DE 256
    BSF OPTION_REG, 1	    
    BSF OPTION_REG, 0
    
    CLRF cont3		    ;LIMPIAR VARIBLE DE DECENAS DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF cont2		    ;LIMPIAR VARIBLE DE UNIDADES DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF cont1		    ;LIMPIAR VARIBLE DE CONTADOR PARA DELAY DE 1s PARA QUE INICIE EN 0
    BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    MOVLW 217		    ;MOVER VALOR PARA DELAY DE 20ms a W
    MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0
   
loop:
    MOVF cont2, W	    ;MOVER VALOR DE CONTADOR DE UNIDADES DE SEGUNDOS A W
    CALL tabla		    ;DAR EL NUMERO DE INSTRUCCION A LA TABLA PARA QUE ESTA REGRESE LA INSTRUCCION EN TERMINOS DEL DISPLAY A W
    MOVWF PORTC		    ;MOVER DE INSTRUCCIóN DE LA TABLA AL PUERTO C (DISPLAY 1)
    MOVF cont3, W	    ;MOVER VALOR DE CONTADOR DE DECENAS DE SEGUNDOS A W
    CALL tabla		    ;DAR EL NUMERO DE INSTRUCCION A LA TABLA PARA QUE ESTA REGRESE LA INSTRUCCION EN TERMINOS DEL DISPLAY A W
    MOVWF PORTA		    ;MOVER DE INSTRUCCIóN DE LA TABLA AL PUERTO A (DISPLAY 2)	    
    GOTO loop
    
END
.data
.align 4
secreto:          .asciz "raspberry"
longitud_secreto: .word 9
limite_fallos:    .word 6
fallos_actuales:  .word 0
letras_acertadas: .word 0

mensaje_bienvenida: .asciz "\n\n*** AHORCADO - JUEGO DE PALABRAS ***\n\n"
mensaje_mostrar:    .asciz "Palabra a descubrir: "
mensaje_fallos:     .asciz "Errores cometidos: %d/%d\n"
mensaje_letra:      .asciz "Escribe una letra: "
mensaje_repetida:   .asciz "Esta letra ya fue utilizada.\n"
mensaje_acierto:    .asciz "¡Bien hecho!\n"
mensaje_error:      .asciz "Letra incorrecta.\n"
mensaje_victoria:   .asciz "\n¡FELICIDADES! Has descubierto la palabra: %s\n"
mensaje_derrota:    .asciz "\n¡GAME OVER! La palabra secreta era: %s\n"
salto_linea:        .asciz "\n"

letras_probadas:  .zero 26
entrada:          .space 16
palabra_visible:  .space 20
formato_entrada:  .asciz " %c"

.text
.global main

main:
    push {lr}
    bl preparar_juego
    ldr r0, =mensaje_bienvenida
    bl printf
ciclo_juego:
    bl imprimir_estado
    ldr r0, =mensaje_letra
    bl printf
    ldr r0, =formato_entrada
    ldr r1, =entrada
    bl scanf
    ldr r0, =entrada
    ldrb r0, [r0]
    bl evaluar_letra
    bl comprobar_estado
    cmp r0, #0
    beq ciclo_juego
    pop {lr}
    bx lr

preparar_juego:
    push {r4-r6, lr}
    ldr r4, =longitud_secreto
    ldr r4, [r4]
    ldr r5, =palabra_visible
    mov r6, #0
bucle_iniciar:
    cmp r6, r4
    beq fin_iniciar
    mov r0, #'_'
    strb r0, [r5, r6]
    add r6, r6, #1
    b bucle_iniciar
fin_iniciar:
    mov r0, #0
    strb r0, [r5, r6]
    pop {r4-r6, lr}
    bx lr

imprimir_estado:
    push {lr}
    ldr r0, =mensaje_fallos
    ldr r1, =fallos_actuales
    ldr r1, [r1]
    ldr r2, =limite_fallos
    ldr r2, [r2]
    bl printf
    ldr r0, =mensaje_mostrar
    bl printf
    ldr r0, =palabra_visible
    bl printf
    ldr r0, =salto_linea
    bl printf
    pop {lr}
    bx lr

evaluar_letra:
    push {r4-r8, lr}
    mov r4, r0
    cmp r4, #'A'
    blt revisar_letra
    cmp r4, #'Z'
    bgt revisar_letra
    add r4, r4, #32
revisar_letra:
    cmp r4, #'a'
    blt letra_no_valida
    cmp r4, #'z'
    bgt letra_no_valida
    sub r5, r4, #'a'
    ldr r6, =letras_probadas
    ldrb r7, [r6, r5]
    cmp r7, #1
    beq letra_ya_usada
    mov r7, #1
    strb r7, [r6, r5]
    ldr r6, =secreto
    ldr r7, =palabra_visible
    mov r8, #0
    mov r5, #0
buscar_coincidencia:
    ldrb r0, [r6, r8]
    cmp r0, #0
    beq fin_buscar
    cmp r0, r4
    bne continuar_busqueda
    strb r0, [r7, r8]
    mov r5, #1
continuar_busqueda:
    add r8, r8, #1
    b buscar_coincidencia
fin_buscar:
    cmp r5, #1
    beq letra_acertada
    ldr r0, =fallos_actuales
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    ldr r0, =mensaje_error
    bl printf
    b letra_no_valida
letra_acertada:
    ldr r0, =letras_acertadas
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    ldr r0, =mensaje_acierto
    bl printf
    b letra_no_valida
letra_ya_usada:
    ldr r0, =mensaje_repetida
    bl printf
letra_no_valida:
    pop {r4-r8, lr}
    bx lr

comprobar_estado:
    push {r4-r7, lr}
    ldr r4, =palabra_visible
    mov r5, #0
verificar_completa:
    ldrb r6, [r4, r5]
    cmp r6, #0
    beq juego_ganado
    cmp r6, #'_'
    beq verificar_fallos
    add r5, r5, #1
    b verificar_completa
juego_ganado:
    ldr r0, =mensaje_victoria
    ldr r1, =secreto
    bl printf
    mov r0, #1
    b fin_comprobar
verificar_fallos:
    ldr r0, =fallos_actuales
    ldr r0, [r0]
    ldr r1, =limite_fallos
    ldr r1, [r1]
    cmp r0, r1
    blt seguir_jugando
    ldr r0, =mensaje_derrota
    ldr r1, =secreto
    bl printf
    mov r0, #1
    b fin_comprobar
seguir_jugando:
    mov r0, #0
fin_comprobar:
    pop {r4-r7, lr}
    bx lr
    

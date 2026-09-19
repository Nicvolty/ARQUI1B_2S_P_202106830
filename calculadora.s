.data

msg_menu:
    .ascii "Seleccione una opción:\n1. Suma\n2. Resta\n3. Multiplicacion\n4. Division Entera\n5. Potencia\n6. Factorial\n7. Salir\n"
    msg_menu_len = . - msg_menu

msg_opcion:
    .ascii "Ingrese una opción: "
    msg_opcion_len = . - msg_opcion

msg_error:
    .ascii "Opción inválida\n"
    msg_error_len = . - msg_error

msg_primer:
    .ascii "Ingrese el primer número: "
    msg_primer_len = . - msg_primer

msg_segundo:
    .ascii "Ingrese el segundo número: "
    msg_segundo_len = . - msg_segundo

msg_error_division_cero:
    .ascii "[ERROR division] -> No se puede dividir entre cero"
    msg_error_division_cero_len = . - msg_error_division_cero

msg_error_exponente:
    .ascii "[ERROR exponente] -> El exponente debe ser entero no negativo\n"
    msg_error_exponente_len = . - msg_error_exponente

newline:
    .ascii "\n"

.bss

input_buffer:
    .skip 64

output_buffer:
    .skip 64

.text
.global _start

.include "atoi.s"
.include "itoa.s"

_start:
    // imprimir el menu
    ldr x1, =msg_menu
    mov x2, msg_menu_len
    bl print

    // imprimir mensaje de opcion
    ldr x1, =msg_opcion
    mov x2, msg_opcion_len
    bl print

    bl read

    // cargar el dato
    ldr x1, =input_buffer
    ldrb w0, [x1]           // cargar el primer byte del buffer

    // Comparar
    cmp w0, '1'
    beq suma

    cmp w0, '2'
    beq resta
    
    cmp w0, '3'
    beq multi

    cmp w0, '4'
    beq Division

    cmp w0, '5'
    beq potencia

    cmp w0, '7'
    beq exit

    b _start


suma:
    mov x22, #0
    b read_numbers

resta:
    mov x22, #1
    b read_numbers
multi:
    mov x22, #3
    b read_numbers

Division:
    mov x22, #4    
    b read_numbers
    
potencia:
    mov x22, #5

read_numbers:
    // imprimir mensaje de primer numero
    ldr x1, =msg_primer
    mov x2, msg_primer_len
    bl print

    bl read

    ldr x21, =input_buffer
    bl atoi    
    mov x20, x10    // se guarda el primer numero en x20
    
    // imprimir mensaje de segundo numero
    ldr x1, =msg_segundo
    mov x2, msg_segundo_len
    bl print

    bl read

    ldr x21, =input_buffer
    bl atoi
    mov x21, x10    // se guarda el segundo numero en x21

    cmp x22, #3     // comparar registro x22 con el numero segun operacion. "3" significa sera multiplicacion
    beq multiplicar

    cmp x22, #4   // comparar registro x22 con el numero 4 ya que ese es el asignado para la division
    beq dividir

    cmp x22, #5   // Comparar registro x22 para ver si es potencia
    beq calcular_potencia

    cbnz x22, subtract
    add x20, x20, x21
    b print_result

subtract:
    sub x20, x20, x21
    b print_result

multiplicar:
    mul x20, x20, x21
    b print_result

dividir:
    cbz x21, error_division_cero
    sdiv x20 , x20, x21
    b print_result

calcular_potencia:
    // Validar que el exponente no sea negativo
    cmp x21, #0
    blt error_exponente_negativo

    // Inicializar el acumulador x9 en 1
    mov x9, #1

loop_potencia:
    // Si el exponente llegó a 0, terminamos
    cbz x21, fin_potencia

    // Multiplicar acumulador por la base: x9 = x9 * x20
    mul x9, x9, x20

    // Decrementar el exponente: x21 = x21 - 1
    sub x21, x21, #1

    // Volver a iterar
    b loop_potencia

fin_potencia:
   // se carga en x20 el resultado
    mov x20, x9
    b print_result

print_result:
    // imprimir el resultado
    mov x0, x20
    ldr x1, =output_buffer
    add x1, x1, #64
    bl itoa
    bl print

    // imprimir nueva linea
    ldr x1, =newline
    mov x2, #1
    bl print
    b _start

read:
    // read(stdin, input_buffer, 64)
    mov x0, #0              // stdin
    ldr x1, =input_buffer   // dirección del buffer
    mov x2, #64             // tamaño a leer
    mov x8, #63             // syscall read
    svc #0                  // hacer la llamada al sistema

    // comparación
    cmp x0, #0
    blt error

    ret

exit:
    mov x0, #0
    mov x8, #93             // syscall exit
    svc #0

print:
    mov x0, #1              // stdout
    mov x8, #64             // syscall de escritura
    svc 0
    ret

error:
    ldr x1, =msg_error
    mov x2, msg_error_len
    bl print
    b _start

error_division_cero:
    ldr x1, =msg_error_division_cero
    mov x2, msg_error_division_cero_len
    bl print
    ldr x1, =newline
    mov x2, #1
    bl print
    b _start

 
error_exponente_negativo:
    ldr x1, =msg_error_exponente
    mov x2, msg_error_exponente_len
    bl print
    b _start   
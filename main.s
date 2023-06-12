# Integrantes del grupo : Torrazza, Virginia F. - Avila, Ivan E.

            .data       0x10001000
slist:      .word       0       # puntero a nodos eliminados
cclist:     .word       0       # puntero a la ultima catagoria creada
fclist:     .word       0       # puntero a la primer categoria creada
wclist:     .word       0       # categoria activa
colist:     .word       0       # puntero a la lista de objetos
option:     .word       0       # opcion seleccionada menu principal y sub menu
caracter:   .word       0       # caracter
texto1:     .asciiz     "Introduzca el nombre de la categoría: \n"
            .align 2
texto2:     .asciiz     "Introduzca el nombre del objeto: \n"
            .align 2
texto3:     .asciiz     "No existen objetos en esta categoria. \n"
            .align 2
texto4:     .asciiz     "No se encontro el ID en esta categoria. \n"
            .align 2
texto5a:     .asciiz    "El ID "
            .align 2
texto5b:     .asciiz    " corresponde a "
            .align 2
t_menu:     .asciiz     "Menu Principal:\n
            1- Crear Categoria.\n
            2- Seleccion de Categoria.\n
            3- Listar Categorias.\n
            4- Borrar Categoria.\n
            5- Anexar un objeto a la Categoria seleccionada.\n
            6- Borrar un objeto de la categoria seleccionada.\n
            7- Listar todos los objetos de la categoria en curso.\n
            0- Salida.\n"
            .align 2
t_subcat:   .asciiz     "Seleccion de Categoria:\n
            1- Categoria anterior.\n
            2- Categoria siguiente.\n
            0- Cancelar.\n"
            .align 2
t_enter:    .asciiz     "\n"
            .align 2
t_opt:      .asciiz     "Ingrese una opcion: "
            .align 2
t_opt_e:    .asciiz     "Por favor ingrese una opcion dentro del rango. \n"
            .align 2
t_opt_id:   .asciiz     "Ingrese el ID a eliminar: "
            .align 2
t_no_cat:   .asciiz     "No existen categorias para listar.\n"
            .align 2
buffer:     .space 20   # buffer para el ingreso de cadenas de caracteres
#### .text #################################################################
            .text
main:       
            addi    $sp, $sp, -4    # apilar dir. ret.
            sw      $ra, 0($sp)
loop:
            jal printMenu           # llamo a la funcion que me muestra el menu
            jal print_option        # funcion que pide un valor entero y lo retorna
            sw $v0, option          # guardo en "option" lo que me devuelve la funcion print_option
            lw $t0, option          # cargo el entero en $t0 para ver en que opcion ingreso del menu

            # switch menu principal #          
            li $t1, 1               # cargo un valor para comparar este con el valor ingresado por el usuario
            bne $t0, $t1, opcion2   # realizo la comparacion si no es la ingresada salto a la siguiente
            # Opcion 1 Crear Categoria
            jal newCategory
j		    finswitch				# salto a finswitch

opcion2:    li $t1, 2
            bne $t0, $t1, opcion3
            # Opcion 2 Seleccion de Categoria
            jal selCategory
j		    finswitch				# salto a finswitch

opcion3:    li $t1, 3
            bne $t0, $t1, opcion4
            # Opcion 3 Listar Categoria
            jal listCategory
j		    finswitch				# salto a finswitch

opcion4:    li $t1, 4
            bne $t0, $t1, opcion5
            # Opcion 4 Borrar Categoria
            jal DelCategory
j		    finswitch				# salto a finswitch

opcion5:    li $t1, 5
            bne $t0, $t1, opcion6
            # Opcion 5 Agregar objeto
            jal NewObject
j		    finswitch				# salto a finswitch

opcion6:    li $t1, 6
            bne $t0, $t1, opcion7
            # Opcion 6 Borrar objeto por ID
            jal EliminarObjeto
j		    finswitch				# salto a finswitch

opcion7:    li $t1, 7
            bne $t0, $t1, opcion0
            # Opcion 7 Imprimir todos los objetos de una categoria
            jal listObject
j		    finswitch				# salto a finswitch

opcion0:    li $t1, 0
            bne $t0, $t1, no_opcion

j		    finswitch				# salto a finswitch

no_opcion:
            jal print_incorrect_opt

            # Fin:  switch menu principal #
finswitch:
            lw      $t0, option  
            bnez    $t0, loop
            # fin loop principal

            lw      $ra, 0($sp)     # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra
# fin: main
#################################################


# Funcion newnode: crea un nodo vacio para categoria
newnode:    
            addi    $sp, $sp, -4    # apilar dir. ret.
            sw      $ra, 0($sp)

            jal smalloc             # llamamos a smalloc para obtener uan direccion de memoria para nuestro nodo

            sw $t0, 8($v0)          
            lw $t1, cclist          # cargo las direcciones de cclist y fclist para saber si es el primer nodo
            lw $t2, fclist          # en $t2 almaceno la dir de la primera categoria
            beq $t1, $0, first      # si la lista es vacia salto a first
            sw $t2, 12($v0)         # inserta new node por el frente
            sw $t1, 0($v0)          # guardo la dirección anterior en el nuevo nodo.
            sw $v0, 12($t1)
            sw $v0, 0($t2)          # grabo la dir del ultimo agregado en el anterior del primero
            sw $v0, cclist          # actualiza el puntero de la lista
            
            lw      $ra, 0($sp)     # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra

first:      sw      $0, 0($v0)      # primer nodo inicializado a null
            sw      $0, 4($v0)      # primer nodo inicializado a null
            sw      $0, 12($v0)     # primer nodo inicializado a null
            sw      $v0, cclist     # cclist apunta al primer nodo.
            sw      $v0, fclist     # cclist apunta al primer nodo.

            lw      $ra, 0($sp)     # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra

################################################

# funcion smalloc: reserva un espacio de memoria dinamica y devuelve dicha direccion
smalloc:
            lw      $t0, slist      # guardo la direccion contenido en slist en $t0
            beqz    $t0, sbrk       # si el contenido de $t0 es null salto y guardo un nuevo espacio de memoria.
            move    $v0, $t0
            lw      $t0, 12($t0)
            sw      $t0, slist      # actualizo slist   
            jr $ra
sbrk:
            li $a0, 16              # reservo 16 bytes
            li $v0, 9
            syscall                 # retorna la direccion en $v0
            jr $ra

##################################################################

# funcion sfree: libera el espacio de memoria apuntado por el argumento
sfree:      
            addi    $sp, $sp, -4    # apilar dir. ret.
            sw      $ra, 0($sp)
            
            lw      $t0, slist      # cargo la direccion contenida en slist, para trabajarla mediante $t0
            sw      $t0, 12($a0)    # guardo la dirección del último elemento de slist en a->sig
            sw      $a0, slist      # agrego $a0 a slist, porque es un nodo eliminado
            
            lw      $ra, 0($sp)     # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra


##################################################################

# funcion newCategory: crea una categoria se enlaza a las demas y pide el nombre de la categoria
newCategory:
                addi    $sp, $sp, -4            # apilar dir. ret.
                sw      $ra, 0($sp)

                jal     newnode

                li      $v0, 4                  # código imprimir cadena
                la      $a0, texto1             # dirección de la cadena
                syscall                         # Llamada al sistema
                li      $v0, 8                  # código de leer el string
                la      $a0, buffer             # dirección lectura cadena
                li      $a1, 20                 # espacio máximo cadena
                syscall                         # Llamada al sistema

                li      $a0, 20                 
                li      $v0, 9                  # creo un nuevo nodo para el dato
                syscall                         
                
                move    $t4, $v0                # guardo la direccion de v0 para no perderlo cuando lo recorra guardando los caracteres
                la      $t1, buffer             # cargo direccion de la cadena
                andi    $t2, $t2, 0             # $t2 = 0
while:          lb      $t3, 0($t1)             # almaceno el byte en $t3
                sb      $t3, 0($v0)
                addi    $v0, $v0, 1             # $v0 = $v0 + 1
                addi    $t1, $t1, 1             # $t1 = $t1 + 1
                beq     $t3, $0, finwhile       # si el caracter == nulo salto a finwhile
                j       while                   # salto a while
finwhile:       
                lw      $t0, cclist
                sw      $t4, 8($t0)             # cargo la direccion del nodo dato en en la categoria adecuada

                lw      $t1, 0($t0)
                bnez    $t1, salto
                sw      $t0, wclist
salto:
                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra

###############################################################

# funcion NextCategory: selecciona como categoria activa a la siguiente de la lista.
NextCategory:
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

                lw      $t0, wclist     # direccion de la categoria activa
                beqz    $t0, ifzero     # si no existe categorias aun salto
                lw      $t1, 12($t0)
                beqz    $t1, ifzero
                sw      $t1, wclist     # actualizo wclist

ifzero:
                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra


###############################################################

# funcion NextCategory: selecciona como categoria activa a la anterior de la lista.
PrevCategory:
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)
                
                lw      $t0, wclist     # direccion de la categoria activa actual
                beqz    $t0, ifzero1
                lw      $t1, 0($t0)
                beqz    $t1, ifzero1
                sw      $t1, wclist     # actualizo wclist
ifzero1:
                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra

###############################################################

# funcion DelCategory: elimina una categoria reenlaza las demas categorias
DelCategory:    addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

                lw      $t0, wclist
                lw      $t4, 12($t0)    # backup de la siguiente dir
                lw      $t3, fclist     # cargo la direccion de la primer categoria

                lw      $t1, 0($t0)     # dir anterior de wclist
                
                lw      $t2, 12($t0)    # dir siguiente de wclist
                sw      $t2, 12($t1)
                sw      $t1, 0($t2)

                lw      $t3, fclist     # cargo la direccion de la primer categoria
                lw      $a0, wclist                 
                jal     sfree           # libero el espacio de memoria
                lw      $t0, wclist     # agregue para no perder el puntero a wclist
                
                beq		$t0, $t3, else	# if $t0 == $t3 then "else"
                # si wclist != fclist
                lw      $t1, 0($t2)     # dir anterior de wclist
                sw      $t1, wclist
                j		endif		    # salto a endif     
else:           # si wclist == fclist
                move    $t1, $t4
                sw      $t1, wclist     # si es la primer categoria actualizo ambas (wclist y fclist)
                sw      $t1, fclist
endif:          
                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra

######################################################################

# funcion NewObject: crea un nuevo objeto y lo enlaza a la categoria activa
NewObject:
                addi    $sp, $sp, -4            # apilar dir. ret.
                sw      $ra, 0($sp)

                lw		$t0, wclist		
                lw		$t1, 4($t0)		        # cargo la direccion del primer objeto
                
                beq     $t1, $0, salto_new      # en $t1 contengo la direccion del objeto
                # recorro hasta alcanzar el ultimo objeto dela lista
                lw      $t2, 12($t1)            # en $t2 guardo el contenido de dir sig del objeto
while3:         
                beqz    $t2, finwhile3
                lw      $t3, 12($t2)            # guardo el contido del sig en $t2 para poder llegar al ultimo
                lw      $t3, 4($t3)             # guardo el valor del id del siguiente para compararlo
                lw      $t4, 4($t2)             # guardo el valor del id del objeto donde estoy parado 
                blt     $t3, $t4, finwhile3     # branch to label if (r1) < (r2)
                lw      $t2, 12($t2)            # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
                j       while3                  # salto a while3
finwhile3:
                jal     smalloc

                beqz $t2, signull
                sw      $v0, 12($t2)            # guardo la dir de v0 en sig de $t2
                sw      $t2, 0($v0)             # guardo la dir de t2 en ant de $v0
                sw      $t1, 12($v0)            # guardo la dir de t1 en sig de $v0
                lw      $t5, 4($t2)
                addi	$t5, $t5, 1			    # $t5 = $t5 + 1
                sw      $t5, 4($v0)             # guardo el nuevo id 
                j		salto1				    
signull:
                sw      $v0, 12($t1)            # guardo la dir de v0 en sig de $t1
                sw      $t1, 0($v0)             # guardo la dir de t1 en ant de $v0
                sw      $t1, 12($v0)            # guardo la dir de t1 en sig de $v0
                sw      $v0, 0($t1)             # guardo la dir de t1 en sig de $v0
                lw      $t5, 4($t1)
                addi	$t5, $t5, 1			    # $t5 = $t5 + 1
                sw      $t5, 4($v0)             # guardo el nuevo id 
            
                # etapa buffer de texto (cargo dato y creo su objeto)               
salto1:         move    $v1, $v0                # guardo la dir de v0 en v1
                li      $v0, 4                  # código de imprimir cadena
                la      $a0, texto2             # dirección de la cadena
                syscall                         # Llamada al sistema
                
                li      $v0, 8                  # código de leer el string
                la      $a0, buffer             # dirección lectura cadena
                li      $a1, 20                 # espacio máximo cadena
                syscall                         # Llamada al sistema

                li      $a0, 20                 # node size fixed 4 words
                li      $v0, 9               
                syscall                         # return node address in v0

                move    $t4, $v0                    
                la      $t1, buffer             # cargo direccion de cadena1 en $t0
                andi    $t2, $t2, 0             # $t2 = 0
while2:         lb      $t3, 0($t1)             # almaceno el byte de cadena1 en $t1
                sb      $t3, 0($v0)
                addi    $v0, $v0, 1             # $v0 = $v0 + 1
                addi    $t1, $t1, 1             # $t1 = $t1 + 1 (i = i + 1)
                beq     $t3, $0, finwhile2      # si $t3 == nulo salto a finwhile2
                j       while2                  # salto a while2
finwhile2:      
                sw      $t4, 8($v1)
                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra
salto_new:      
                jal     smalloc
                lw		$t0, wclist		        
                sw		$v0, 4($t0)		        
                sw      $0, 0($v0)              # primer nodo inicializado a null
                sw      $0, 4($v0)              # primer nodo inicializado a null
                lw		$t1, 4($v0)		 
                addi	$t1, $t1, 1			    # $t1 = $t1 + 1
                sw      $t1, 4($v0)
                sw      $0, 12($v0)             # primer nodo inicializado a null
                sw      $v0, colist             # colist apunta al primer nodo.

                move    $v1, $v0                # guardo la dir de v0 en v1
                li      $v0, 4                  # código de imprimir cadena
                la      $a0, texto2             # dirección de la cadena
                syscall                         # Llamada al sistema
                
                li      $v0, 8                  # código de leer el string
                la      $a0, buffer             # dirección lectura cadena
                li      $a1, 20                 # espacio máximo cadena
                syscall                         # Llamada al sistema

                li      $a0, 20                 # node size fixed 4 words
                li      $v0, 9               
                syscall                         # return node address in v0
                
                move    $t4, $v0
                la      $t1, buffer             # cargo direccion de cadena1 en $t0
                andi    $t2, $t2, 0             # $t2 = 0
while6:         lb      $t3, 0($t1)             # almaceno el byte de cadena1 en $t1
                sb      $t3, 0($v0)
                addi    $v0, $v0, 1             # $t2 = $t2 + 1
                addi    $t1, $t1, 1             # $t0 = $t0 + 1 (i = i + 1)
                beq     $t3, $0, finwhile6      # si $t1 == nulo salto a finwhile
                j       while6                  # salto a while
finwhile6: 
                move    $t0, $v1
                sw      $t4, 8($t0)             # cargo la direccion del nodo dato en en la categoria adecuada

                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

######################################################################
# funcion DelObject: Elimina un objeto segun la categoria activa y el id ingresado por el usuario
# argumento $a0 = ID a eliminar
DelObject:      addi    $sp, $sp, -4            # apilar dir. ret.
                sw      $ra, 0($sp)

                move $t0, $a0                   # preserva arg 1 en $t0
                lw      $t1, wclist
                lw      $t2, 4($t1)             # dir del primer objeto
                beqz    $t2, obnull     
while4:         lw		$t5, 12($t2)		 
                beqz    $t5, compare
                lw      $t4, 4($t2)             # guardo el valor del id del objeto donde estoy parado
                lw      $t3, 12($t2)            # guardo el contido del sig en $t2 para poder llegar al ultimo
                lw      $t3, 4($t3)             # guardo el valor del id del siguiente para compararlo

                beq		$t4, $t0, idOk	        # if $t4 == $t1 then target
                blt     $t3, $t4, notfound      # branch to label if (r1) < (r2)
                lw      $t2, 12($t2)            # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
                j       while4                   # salto a while4
compare:        lw      $t3, 4($t2)
                bne		$t3, $t0, notfound	    # if $t3 == $t1 then notfound si no es el id buscado
idOk:
                lw      $t4, 0($t2)             # dir anterior
                beqz    $t4, antnull            # comparo si $t4(dir anterior es null) de ser asi se que es el primer objeto
                sw      $t4, 0($t3)
                sw      $t3, 12($t4)
                move    $a0, $t2          
                jal     sfree                   # libero el espacio
                
                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra
antnull:        
                li      $t4, 0
                sw      $t4, 4($t1)
                move    $a0, $t2          
                jal     sfree                   # libero el espacio

                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra
notfound:
                li      $v0, 4                  # código de imprimir cadena
                la      $a0, texto4             # dirección de la cadena
                syscall                         # Llamada al sistema

                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra
obnull:         
                li      $v0, 4                  # código de imprimir cadena
                la      $a0, texto3             # dirección de la cadena
                syscall                         # Llamada al sistema

                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

######################################################################

# funcion printCat: imprime el nombre de la categoria recibida como argumento
# $a0 = dir de categoria
printCat:       
                addi    $sp, $sp, -4        # apilar dir. ret.
                sw      $ra, 0($sp)

                move    $t0, $a0            # guardo el contenido de a0 en t0
                li      $v0, 4              # código de imprimir cadena
                lw      $t1, 8($t0)         # dirección de la cadena
                move      $a0, $t1          # dirección de la cadena
                syscall                     # Llamada al sistema

                lw      $ra, 0($sp)         # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

######################################################################

# funcion printObj: imprime el nombre del objeto segun la cat recibida como argumento y un id
# $a0 = dir de categoria # $a1 = ID
printObj:       addi    $sp, $sp, -4        # apilar dir. ret.
                sw      $ra, 0($sp)

                move    $t0, $a0            # preserva arg 1 en $t0 = wclist
                move    $t1, $a1            # preserva arg 2 en $t1 = ID
                lw      $t2, 4($t0)         # dir del primer objeto
                beqz    $t2, obnull2
                
while5:         lw		$t5, 12($t2)
                beqz    $t5, compare2
                lw      $t4, 4($t2)         # guardo el valor del id del objeto donde estoy parado
                lw      $t3, 12($t2)        # guardo el contido del sig en $t2 para poder llegar al ultimo
                lw      $t3, 4($t3)         # guardo el valor del id del siguiente para compararlo
                beq		$t4, $t1, idOk2	
                blt     $t3, $t4, notfound2 # branch to label if (r1) < (r2)
                lw      $t2, 12($t2)        # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
                j       while5              # salto a while5
compare2:       
                lw      $t3, 4($t2)
                bne		$t3, $t1, notfound2	
idOk2:
                li      $v0, 4              # código de imprimir cadena
                la      $a0, texto5a        # dirección de la cadena
                syscall                     # Llamada al sistema

                li      $v0, 1              # código de imprimir entero
                lw      $a0, 4($t2)         # entero a imprimir
                syscall                     # Llamada al sistema

                li      $v0, 4              # código de imprimir cadena
                la      $a0, texto5b        # dirección de la cadena
                syscall     

                li      $v0, 4              # código de imprimir cadena
                lw      $t1, 8($t2)         # dirección de la cadena
                move    $a0, $t1            # dirección de la cadena
                syscall                     # Llamada al sistema

                li      $v0, 4              # código de imprimir cadena
                la      $a0, t_enter        # dirección de la cadena
                syscall 

                lw      $ra, 0($sp)         # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra
notfound2:
                li      $v0, 4              # código de imprimir cadena
                la      $a0, texto4         # dirección de la cadena
                syscall                     # Llamada al sistema

                lw      $ra, 0($sp)         # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra
obnull2:         
                li      $v0, 4              # código de imprimir cadena
                la      $a0, texto3         # dirección de la cadena
                syscall                     # Llamada al sistema

                lw      $ra, 0($sp)         # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

#######################################################################

# funcion printMenu: imprime el menu principal
printMenu:      
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

                li      $v0, 4          # código de imprimir cadena
                la      $a0, t_menu     # dirección de la cadena
                syscall  

                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

####################################################################

# funcion print_option: pide al usuario que ingrese una opcion
print_option:
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

                li      $v0, 4          # código de imprimir cadena
                la      $a0, t_opt      # dirección de la cadena
                syscall 

                li      $v0, 5          # código para leer un entero
                syscall 

                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

####################################################################

# funcion selCategory: imprime el submenu de seleccion de categoria activa y lleva acabo el cambio de la categoria antiva
selCategory:
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

loop_SC:       
                jal     print_opt_cat   # imprimo opciones del submenu
                jal     print_option
                sw      $v0, option     # guardo en "option" lo que me devuelve la funcion print_option 
                lw      $t0, option

                # switch submenu de categoria #          
                li      $t1, 1
                bne     $t0, $t1, SCopcion2
                # Opcion 1 Categoria anterior
                jal     PrevCategory
j		        SCfinswitch

SCopcion2:      li      $t1, 2
                bne     $t0, $t1, SCopcion0
                # Opcion 2 Categoria siguiente
                jal     NextCategory
j		        SCfinswitch

SCopcion0:      li $t1, 0
                bne $t0, $t1, no_opcionSC
                # cancelar
j		        SCfinswitch		

no_opcionSC:
                jal print_incorrect_opt   
                # Fin:  switch submenu categoria #
SCfinswitch:
                bnez    $t0, loop_SC
                li      $t1, 3
                sw $t1, option

                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra

####################################################################

# funcion print_oopt_cat: imprime las opciones del submenu de categoria
print_opt_cat:
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)
                
                li      $v0, 4          # código de imprimir cadena
                la      $a0, t_subcat   # dirección de la cadena
                syscall 
                
                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr      $ra

####################################################################

# funcion print_incorrect_opt: imprime el mensaje de opcion incorrecta
print_incorrect_opt:     
                addi    $sp, $sp, -4    # apilar dir. ret.
                sw      $ra, 0($sp)

                li      $v0, 4          # código de imprimir cadena
                la      $a0, t_opt_e    # dirección de la cadena
                syscall  

                lw      $ra, 0($sp)     # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

####################################################################

# funcion listCategory: recorre e imprime las categorias existentes e indica cual es la activa
listCategory:
                addi    $sp, $sp, -4            # apilar dir. ret.
                sw      $ra, 0($sp)

                lw      $t0, wclist             # contiene la direccion de la categoria activa
                lw      $t1, fclist             # contiene la direccion de la primer categoria
                move    $t4, $t1                # backup de fclist
                beqz    $t0, nullcat
while7:         
                lw		$t5, 12($t1)		 
                beqz    $t5, comp_null
                bne     $t0, $t1, sel_char
                li      $v0, 11                 # código de imprimir cadena
                li      $a0, 42                 # "*"
                syscall
                j		finif1				    # salta finif1
sel_char:       
                li      $v0, 11                 # código de imprimir cadena
                li      $a0, 32                 # " "
                syscall
finif1:         # imprimo nombre de categoria.
                move    $t2, $t1
                move    $t3, $t0
                move    $a0, $t1
                jal     printCat
                move    $t1, $t2
                move    $t0, $t3
                beq		$t4, $t5, finish	    # if $t4 == $t5 then finish
                lw      $t1, 12($t1)            # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
                j       while7                  # salto a while7
comp_null:      # imprimo nombre de categoria.
                move    $a0, $t1
                jal     printCat
                syscall
                j		finish				    # salto a finish
nullcat:                    
                li      $v0, 4                  # código de imprimir cadena
                la      $a0, t_no_cat           # dirección de la cadena
                syscall 
fin_cat:
finish:
                lw      $ra, 0($sp)             # desapilar dir. ret.
                addi    $sp, $sp, 4
                jr $ra

####################################################################

# funcion EliminarObjeto: elimina un objeto segun la categoria y el id ingresado
EliminarObjeto:

            addi    $sp, $sp, -4        # apilar dir. ret.
            sw      $ra, 0($sp)
            
            li      $v0, 4              # código de imprimir cadena
            la      $a0, t_opt_id       # dirección de la cadena
            syscall 

            li      $v0, 5              # código para leer un entero
            syscall 
            # argumento $a0 = ID a eliminar
            move $a0, $v0
            jal DelObject               # llamo a DelObject para elimiar el objeto

            lw      $ra, 0($sp)         # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra

####################################################################

# funcion listObjet: imprime la lista de objetos existentes segun la categoria activa
listObject:
            addi    $sp, $sp, -4        # apilar dir. ret.
            sw      $ra, 0($sp)

            lw      $t0, wclist
            beqz    $t0, ifnull         # si es null no hay categoria ni objetos
            # dir del primer objeto
            lw      $t2, 4($t0)         # cargo en t1 la direccion del primer objeto
            beqz    $t2, obnull3        # veo si existe al menos un objeto                    
while8:     
            lw      $t5, 12($t2)                                         
            beqz    $t5, compare3                        
            lw      $t4, 4($t2)         # guardo el valor del id del objeto donde estoy parado
            lw      $t3, 12($t2)        # guardo el contido del sig en $t2 para poder llegar al ultimo
            lw      $t3, 4($t3)         # guardo el valor del id del siguiente para compararlo
            # $a0 = dir # $a1 = ID
            lw      $a0, wclist
            move    $a1, $t4
            jal     printObj            # imprimo el objeto
            # fin imprimir objeto
            blt     $t3, $t4, notfound3 # branch to label if (r1) < (r2)
            lw      $t2, 12($t2)        # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
            j       while8              # salto a while8
            #si es solo un objeto
compare3:
            # $a0 = dir # $a1 = ID
            lw      $a0, wclist
            lw      $a1, 4($t2)
            jal     printObj            # imprimo el objeto
            # fin imprimir objeto
            j		notfound3
ifnull:     # no existe categorias
            li      $v0, 4              # código de imprimir cadena
            la      $a0, t_no_cat       # dirección de la cadena
            syscall                     # Llamada al sistema      
            j       notfound3                      
obnull3:# no existe objeto
            lw      $a0, wclist
            li      $a1, 1
            jal     printObj            # imprimo objeto
notfound3: # termine de recorrer
            lw      $ra, 0($sp)         # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr $ra

####################################################################

# funcion EliminarTodosObjetos: elimina todos los objetos de una categoria
EliminarTodosObjetos:
            addi    $sp, $sp, -4        # apilar dir. ret.
            sw      $ra, 0($sp)

            lw      $t0, wclist
            # dir del primer ojbeto
            lw      $t2, 4($t0)         # cargo en t2 la direccion del primer objeto
            beqz    $t2, obnull4        # veo si existe al menos un objeto
while9:     
            lw      $t5, 12($t2)                                         
            beqz    $t5, compare4                        
            lw      $t4, 4($t2)         # guardo el valor del id del objeto donde estoy parado
            lw      $t3, 12($t2)        # guardo el contido del sig en $t2 para poder llegar al ultimo
            lw      $t3, 4($t3)         # guardo el valor del id del siguiente para compararlo
            # argumento $a0 = ID a eliminar
            move    $a0, $t4
            jal     DelObject           # elimino objeto
            blt     $t3, $t4, notfound4 # branch to label if (r1) < (r2)
            lw      $t2, 12($t2)        # si no es null o si id actual < id sig guardo el contido del sig en $t2 para poder llegar al ultimo
            j       while9              # salto a while9
            #si es solo un objeto
compare4:   # argumento $a0 = ID a eliminar
            li      $a0, 1
            jal     DelObject           # elimino el objeto
            j		notfound4
obnull4:
notfound4:
            lw      $ra, 0($sp)         # desapilar dir. ret.
            addi    $sp, $sp, 4
            jr      $ra

####################################################################
//Ben Foster UCID: 30094638
//Date: 12/07/2021
//Assignment 6 code, reads values from file specified in command line, calculates arctan of the value read.
//Demonstrate understanding of file i/o, floating points formats, floating point calculations, and floating point comparisons
.data
min_m:      .double 0r1.0e-13

.balign 4
.text
tableTop:   .string "x val \t\t\t arctan(x)\n"
tableLine:  .string "%.2f  \t\t\t %.10f\n"
failed1:    .string "Incorrect amount of arguments given.\n"
failed2:    .string "Unable to open the file: %s.\n"
.balign     4
.global     main


double_offset = 16
double_s = 8
fd_o = double_offset+double_s
fd_s = 4
arctanDouble_o = fd_o+fd_s
arctanDouble_s = 8
exponent_o = arctanDouble_o+arctanDouble_s
exponent_s = 8
alloc = -(16+double_s+fd_s+arctanDouble_s+exponent_s) & -16
dealloc = -alloc

main:
    stp     x29, x30, [sp, alloc]! 
    mov     x29, sp

    mov     w19, w0                     //argc in w19
    mov     x20, x1                     //argv address in x20
    mov     w21, 1                      //argv[1] should contain file name. argv[0] is the program name

argTest:                                //checks if the correct amount of args has been given
    mov     w22, 2
    cmp     w22, w19
    b.eq    argPass
    adrp    x0, failed1
    add     x0,x0, :lo12:failed1        //prints string stating program failed if not enough args given
    bl      printf
    b       mainEnd

argPass:
    mov     w0, -100
    ldr     x1, [x20, w21, SXTW 3]      //loads address of file name into x1
    mov     w2, 0                       //read only
    mov     w3, 0                       //not used
    mov     x8, 56                      //openat i/o request     
    
    svc     0                           //call system function
    str     w0, [x29, fd_o]             //store the handle

    cmp     w0, 0                       //error check -1 on error
    
    b.ge    open_ok
    
    adrp    x0, failed2                 //code to handle error, program ends.
    add     x0, x0, :lo12:failed2         
    bl      printf                      //prints fail message
    mov     x0, -1                      //returns error
    b       mainEnd                     //ends program

open_ok:
    adrp    x0, tableTop
    add     x0, x0, :lo12:tableTop
    bl      printf
    
read:
    ldr     w0, [x29, fd_o]             //w0 = fd
    add     x1, x29, double_offset      // x1  = address to store double at
    mov     w2, 8                       //read 8 bytes

    mov     x8, 63                      //x8 = read call
    svc     0                           //read(fd, &double, 8) read 8 bytes from fd, stores it at address of double

    cmp     w0, 8  
    b.ne    mainEnd                     //ends if EOF, ie not 8 bytes read


    ldr     d19, [x29, double_offset]  //loads d19 with x
    str     d19, [x29, arctanDouble_o] //stores x for initial term
    fabs    d19, d19                   //check absolute value of x
    adrp    x10, min_m
    add     x10, x10, :lo12:min_m
    ldr     d20, [x10] 
    fcmp    d19, d20                   //check if term is lt
    b.lt    print

    fmov    d9, 1.0 
    str     d9, [x29, exponent_o]      //stores exponent

sub:
    ldr     d0, [x29, double_offset]   //loads x
    ldr     d1, [x29, exponent_o]      //loads exponent
    fmov    d9, 2.0
    fadd    d1, d1, d9                 //increments exponent
    str     d1, [x29, exponent_o]      //stores exponent

    bl      termCalc

    fabs    d10, d0
    adrp    x10, min_m
    add     x10, x10, :lo12:min_m
    ldr     d20, [x10]
    fcmp    d10, d20
    b.lt    print

    ldr     d9, [x29, arctanDouble_o]  //calculated value into d9
    fsub    d9, d9, d0                 //subtracts term
    str     d9, [x29, arctanDouble_o]  //stores current arctan(x)


add:
    ldr     d0, [x29, double_offset]   //loads x
    ldr     d1, [x29, exponent_o]      //loads exponent
    fmov    d9, 2.0
    fadd    d1, d1, d9                 //increments exponent
    str     d1, [x29, exponent_o]      //stores exponent   

    bl      termCalc
    fabs    d10, d0
    adrp    x10, min_m
    add     x10, x10, :lo12:min_m
    ldr     d20, [x10]
    fcmp    d10, d20
    b.lt    print

    ldr     d9, [x29, arctanDouble_o]  //calculated value into d9
    fadd    d9, d9, d0                 //adds term
    str     d9, [x29, arctanDouble_o]  //stores current arctan(x)

    b       sub


print:
    adrp    x0, tableLine
    add     x0, x0, :lo12:tableLine    //sets up print arg1 (the string)
    ldr     d0, [x29, double_offset]   //sets up print arg2 (x value from file)
    ldr     d1, [x29, arctanDouble_o]  //sets up print arg3 (arctan(x))
    bl      printf

    mov     x0, xzr                     //setup return value 0
    b       read                        //loops

    mainEnd:
    ldr     w0, [x29, fd_o]             //x0 = fd
    mov     x8, 57                      // close
    svc     0                           //file closed

    ldp     x29, x30, [sp], dealloc
    ret



termCalc:   
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    fmov    d2, 1.0
    fmov    d3, 1.0
    b       calcTest 

calcTop:
    fmul    d3, d3, d0
    fmov    d9, 1.0
    fadd    d2, d2, d9

calcTest:
    fcmp    d1, d2
    b.ge    calcTop

    fdiv    d0, d3, d1

    ldp     x29, x30, [sp], 16
    ret


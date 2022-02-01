//Ben Foster 30094638
//2021/11/24
//Implement Functions for a5Main.c in assembly

MAXOP = 20
NUMBER = '0'
TOOBIG = '9'
BUFSIZE = 100
MAXVAL = 100
	.global sp_m
	.global val
	.global buf
	.global bufp

.bss
	sp_m: .skip 4
	val: .skip MAXVAL*4
	buf: .skip BUFSIZE
	bufp: .skip 4

.balign 8
.data
 	stack_full: .string "error: stack full\n"
 	stack_empty: .string "error: stack empty\n"
 	toomanychar: .string "ungetch: too many characters\n"

 .balign 4
 .text

  	.global push
push:									//takes one argument (int f) returns int
  	stp		x29, x30, [sp,-16]!
  	mov		x29, sp


  	b 		pushTest
pushIf:
  	adrp	x9, sp_m
  	add 	x9, x9, :lo12:sp_m			//loads address of sp into w9
  	ldr 	w10, [x9]					//loads value of sp into w10

  	add 	w11, w10, 1					//increments sp
  	str 	w11, [x9]					//stores incremented sp back in memory

 	adrp 	x9, val	
  	add 	x9, x9, :lo12:val			//sets up val address in w9
  	str 	w0, [x9, w10, SXTW 2]		//stores f in val[sp] (pre-increment)
  	b 		pushBot						//branches to EOF

pushElse:
  	adrp 	x0, stack_full				//sets up overflow argument
  	add 	x0, x0, :lo12:stack_full	//prints over flow
  	bl 		printf

  	bl 		clear
  	mov 	w0, 0						//moves 0 to be returned
  	b 		pushBot						//branches to EOF


pushTest:
 	adrp 	x9, sp_m					//loads address of sp into w9
  	add 	x9, x9, :lo12:sp_m
  	ldr 	w10, [x9]					//loads value of sp into w10
 	cmp 	w10, MAXVAL
  	b.lt 	pushIf						//branches to if portion if less than maxVal
  	b 		pushElse					//else brances to else

pushBot:
 	ldp 	x29, x30, [sp], 16
  	ret






  	.global pop
pop:									//takes null, returns int
  	stp		x29, x30, [sp, -16]!
  	mov		x29, sp

  	b 		popTest

 popIf:
  	adrp 	x9, sp_m
  	add 	x9, x9, :lo12:sp_m			//address of sp in x9
  	ldr 	w10, [x9]					//sp in w10
  	sub 	w10, w10, 1					//decrements sp
  	str 	w10, [x9]					//stores updated sp

  	adrp 	x9, val
  	add 	x9, x9, :lo12:val			//val address in x9
  	ldr 	w0, [x9, w10, SXTW 2]		//loads val[--sp] into w0 to be returned
  	b 		popBot						//branche to EOF

popElse:
  	adrp 	x0, stack_empty
  	add 	x0, x0, :lo12:stack_empty	//sets up empty argument
 	bl 		printf						//prints empty arg error

 	bl 		clear						//branches to clear function

  	mov 	w0, 0						//sets up return 0
  	b 		popBot						//branches to EOF

popTest:
  	adrp	x9, sp_m
  	add		x9, x9, :lo12:sp_m			//address of sp in x9
  	ldr 	w10, [x9]					//sp in w10
  	cmp 	w10, wzr					//compares to zero
  	b.gt 	popIf						//if sp > 0 -> if
  	b 		popElse						//else -> else

popBot:
  	ldp 	x29, x30, [sp], 16
  	ret





	.global clear
clear:									//takes null, returns null
  	stp 	x29, x30, [sp, -16]!
	mov 	x29, sp

	adrp 	x9, sp_m
  	add 	x9, x9, :lo12:sp_m			//address of sp in x9
	mov 	w10, 0
  	str 	w10, [x9]					//stores 0 in sp

	ldp 	x29, x30, [sp], 16
	ret


i_s = 4
c_s = 4
s_s = 8
lim_s = 4
i_offset = 16
c_offset = i_offset+i_s
s_offset = c_offset +c_s
lim_offset = s_offset+s_s

getop_alloc = -(16+i_s+c_s+s_s+lim_s) & -16
getop_dealloc = -getop_alloc
	.balign 4
  	.global getop
getop:									//takes char *s and int lim, returns int (int s always seems to be MAXOP so why necessary?)
   	stp		x29, x30, [sp, getop_alloc]!//allocating extra space for ints i and c
   	mov		x29, sp

  	str 	x0, [x29, s_offset]			//stores s address to be accessed later
	str 	w1, [x29, lim_offset]		//stores lim to be used later

getOpWhile1:
   	bl 		getch						//branch to getch function (returns an int)
 	str 	w0, [x29, c_offset]			//stores result at c's correct location
	
  	ldr 	w9, [x29, c_offset]			//loads c into temp register for compares
  	cmp 	w9, ' '						//compares c to ' '
	b.eq 	getOpWhile1					//if equal, get next char
  	cmp 	w9, '\t'					//compares c to '\t'
   	b.eq	getOpWhile1					//if equal get next char
   	cmp 	w9, '\n'					//compares c to '\n'
   	b.eq 	getOpWhile1					//if equal get next char
	
 	b		getOpIfTest1
getOpIf1:
	ldr 	w0, [x29, c_offset]			//loads c to return
 	b		getOpBot

getOpIfTest1:
 	ldr 	w9, [x29, c_offset]			//loads c
 	cmp 	w9, NUMBER					//compares c to '0'
 	b.lt 	getOpIf1				

 	cmp 	w9, TOOBIG					//compares c to '9'
 	b.gt 	getOpIf1

 	ldr 	x9, [x29, s_offset]			//x9 holds s address base (s[0])
 	ldr 	w10, [x29, c_offset]		//c in w10
 	strb	w10, [x9]					//stores c in s[0]

 	mov 	w9, 1						
 	str		w9, [x29, i_offset]			//i =1
 	b	getOpForTest
getOpFor:
 	ldr 	w9, [x29, lim_offset]		//loads lim into w9
 	ldr 	w10, [x29, i_offset]		//loads i into w10
 	cmp 	w10, w9						//compare i to lim
 	b.ge    getOpForInner				//logic to skip s[i] = c

 	ldr 	x9, [x29, s_offset]			//loads s base into x9
 	ldr 	w11, [x29, c_offset]		//loads c into w11
	ldr 	w10, [x29, i_offset]		//loads i into w10
 	strb 	w11, [x9, w10, SXTW]		//store c at s[i]
getOpForInner: 
 	ldr 	w9, [x29, i_offset]			//loads i
 	add 	w9, w9, 1					//i++
 	str 	w9, [x29, i_offset]			//stores updated i

getOpForTest:
	bl 		getchar
 	str 	w0, [x29, c_offset]			//stores c
 	cmp 	w0, '0'						//compare new c to '0'
 	b.lt	getOpForEnd					//logic to end for loop
 	cmp 	w0, '9'						//compares new c to '9'
 	b.gt	getOpForEnd					//logic to end for loop

 	b 		getOpFor					//&& check passed, operate for inside

getOpForEnd:
 	b		getOpIfTest2

getOpIf2:
 	ldr 	w0, [x29, c_offset]			//loads c into w0 for ungetch
 	bl		ungetch

 	ldr 	w9, [x29, i_offset]			//loads i into w9
 	ldr 	x10, [x29, s_offset]		//loads s base into x10
 	mov 	w11, 0						//w11 = '\0'
 	strb 	w11, [x10, w9, SXTW]		//s[i] = '\0'

 	mov 	w0, NUMBER
 	b 		getOpBot

getOpIfTest2:
 	ldr 	w9, [x29, i_offset]			//loads i into w9
 	ldr 	w10, [x29, lim_offset]		//loads lim into w10
	cmp 	w9, w10						//compare the two
 	b.lt 	getOpIf2					//if (i < lim)

 	b 		getOpWhile2Test				//else statement this way

getOpWhile2Test:
	ldr 	w9, [x29, c_offset]			//c in w9
 	cmp 	w9, '\n'
 	b.eq 	getOpWhile2End				//logic to end while loop
 	cmp 	w9, -1						
 	b.eq 	getOpWhile2End				//logic to end while loop

 	bl 		getchar						//execute while loop if get this far
 	str 	w0, [x29, c_offset]			//update c with new char from get char
 	b 		getOpWhile2Test				//do it again

getOpWhile2End:
 	ldr 	w9, [x29, lim_offset]		//w9 = lim
 	sub 	w9, w9, 1					//w9 = lim-1 
 	ldr 	x10, [x29, s_offset]		//s base in x10
 	mov 	w11, 0						//w11 = '\0'
 	strb 	w11, [x10, w9, SXTW]		//s[lim-1] = '\0'
 	mov 	w0, TOOBIG 

getOpBot:
   	ldp 	x29, x30, [sp], getop_dealloc
   	ret





 	.global getch
getch:									//takes null, returns int
 	stp 	x29, x30, [sp, -16]!
 	mov 	x29, sp
	
 	adrp	x9, bufp
 	add 	x9, x9, :lo12:bufp			//bufp address in x9
 	ldr 	w10, [x9]					//loads bufp int into w10

 	cmp 	w10, wzr
 	b.le	getchElse					//if bufp != > 0 skip

 	sub		w10, w10, 1					//decrement bufp by 1
 	str		w10, [x9]					//stores bufp

 	adrp 	x9, buf						//buf address in x9
 	add 	x9, x9, :lo12:buf
 	ldr		w0, [x9, w10, SXTW]			//loads w0 with buf[--bufp] to be returned
 	b		getchBot

 getchElse:
 	bl 		getchar						//else get a new char and return it

getchBot:
 	ldp 	x29, x30, [sp], 16
 	ret





 	.global ungetch
ungetch:
 	stp 	x29, x30, [sp, -16]!
 	mov 	x29, sp

 	b 		ungetTest

ungetIf:
	adrp 	x0, toomanychar
 	add 	x0, x0, :lo12:toomanychar
 	bl		printf

 	b 		ungetBot

ungetTest:
	adrp 	x9, bufp
 	add 	x9, x9, :lo12:bufp
 	ldr 	w10, [x9]					//loads bufp into w10

 	cmp 	w10, BUFSIZE				//compares bufp to BUFSIZE
 	b.gt	ungetIf

 	adrp 	x9, buf						
 	add 	x9, x9, :lo12:buf			//buf address in x9

 	strb	w0, [x9, w10, SXTW]			//stores c in buf[bufp]
 	add		w10, w10, 1					//increments bufp by 1
 	adrp	x9, bufp
 	add		x9, x9, :lo12:bufp
 	str		w10, [x9]					//stores bufp after incremening

ungetBot:
 	ldp 	x29, x30, [sp], 16
 	ret

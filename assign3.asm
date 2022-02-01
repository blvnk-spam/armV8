//Ben Foster 30094638
//Date:10/22/2021

			array_s = 100						//size of our array
			int_s = 4						//size of an int
			alloc = -(16+(int_s*array_s)+16) & -16			//specifying how much memory stack memory to be allocated and deallocated
			dealloc = -alloc					//opposite of amount allocated to begin, allows easy deallocation
			a_base = 16						//base index of array
			i_loc = a_base+400					//index in memory where i is located (FP+i_loc)
			j_loc = i_loc+4						//index in memory where j is located (FP+j_loc)
			gap_loc = j_loc+4					//index in memory where gap is located (FP+gap_loc)
			temp_loc = gap_loc+4					//index in memory where temp is located (FP+temp_loc)
define(i_r, w19)								//w register for holding i as we load and store it from stack memory
define(arrayOffset, x20)							//x register for keep track of the array offset
define(arrayBase, x25)								//x register for keeping track of the arraybase

output_string1:		.string "Unsorted array:\n"
output_string2:		.string "v[%d] = %d\n"					//all 3 output strings needed for print statements.
output_string3:		.string "\nSorted array:\n"
			.balign 4						//aligns memory
			.global main

main:
			stp 	x29, x30, [sp, alloc]!				//stores prior x29, x30 in frame record, allocates specified amount of memory in stack below
			mov 	x29, sp

			add 	arrayBase, x29, a_base				//stores a_base+x29 in arrayBase
			mov 	arrayOffset, a_base				//stores a_base in arrayOffset
			mov 	i_r, 0						//stores 0 in w19 register
			str	i_r, [x29, i_loc]				//stores w19 register in x29 (FP) + i_loc

			adrp	x0, output_string1
			add 	x0, x0 , :lo12:output_string1			//prepares string for printing
			bl 	printf						//prints string

initialize:
			ldr 	i_r, [x29,i_loc]				//loads the register w19 with the contents of FP+i_loc
			cmp	i_r, array_s					//compares loaded contents of w19 register to array_s (array size)
			b.ge	loopOneEnd					//if greater than or equal to size, branches to loopOneEnd

			bl	rand						//linked branch to rand function in C (returned result stored in lower half of x0)
			and	w0, w0, 0x1FF 					//ands the result of the rand function with 0x1FF gauranteeing it is mod 512, stores it in w0
			str	w0, [x29, arrayOffset]				//stores the result of the rand function mod 512 in array_base+[i*int_size]

			adrp	x0, output_string2
			add	x0, x0, :lo12:output_string2			//specifies to print string2
			ldr	w1, [x29, i_loc]				//specifies first %d to be printed (i value)
			ldr	w2, [x29, arrayOffset]				//specifies second %d to be printed (v[i] value)
			bl 	printf						//prints string

			add	arrayOffset, arrayOffset, int_s			//incerements w21 register by 4, the size of an int to prepare for next store instruction
			add 	i_r, i_r, 1					//increments w19 register by 1
			str	i_r, [x29, i_loc]				//stores updated w19 register into x29+i_loc

			b	initialize					//unconditional branch back to the top of loop to be tested.

loopOneEnd:

			mov 	w20, array_s					//stores array_s (SIZE) in w20
			lsr 	w20, w20, 1					//logical shift right to divide size by 2
			str	w20, [x29, gap_loc]				//stores w20 register in the local variable gap

loopTwoStart:
			ldr 	w20, [x29, gap_loc]				//loads gap into w20
			cmp	w20, wzr					//compares gap to 0
			b.le 	loopExit					//if gap is less than or equal to 0, branch to print statement

			ldr	i_r, [x29, gap_loc]				//i_r is set to gap_loc
			str 	i_r, [x29, i_loc]				//stores i_r into i location on the stack
loopTwoIn:
			ldr	i_r, [x29, i_loc]				//loads i_loc from stack into i_r
			cmp 	i_r, array_s					//compares i to Size
			b.ge 	loopTwoInEnd					//if i greater than or equal to size, branches to loop two in end

			ldr	i_r, [x29, i_loc]				//loads i value
			ldr	w20, [x29, gap_loc]				//loads gap value
			sub 	w20, i_r, w20					//w20 = i-gap
			str	w20, [x29, j_loc]				//j = i-gap
innerMost:
			ldr	w20, [x29, j_loc]				//loads j into w20
			cmp 	w20, wzr					//compares j to zero
			b.lt 	innerMostEnd					//if j less than zero branch to end of loop

			ldr	w20, [x29, j_loc]				//w20 = j
			ldr 	w21, [x29, gap_loc]				//w21 = gap
			add 	w21, w21, w20					//w21 = gap+j
			ldr 	w20, [arrayBase, w20, SXTW 2] 			//w20 = v[j]
			ldr 	w21, [arrayBase, w21, SXTW 2]			//w21 = v[j+gap]
			cmp	w20, w21					//compares v[j] to v[j+gap]
			b.ge 	innerMostEnd					//if w20 greater than or equal to w21 branch to innermostend

			str 	w20, [x29, temp_loc]				//temp = v[j]
			ldr 	w20, [x29, j_loc]				//loads j to w20
			str 	w21, [arrayBase, w20, SXTW 2] 			//v[j] = v[j+gap]
			ldr 	w21, [x29, gap_loc]				//loads gap to w21
			add 	w21, w21, w20					//w21 = j+gap
			ldr 	w20, [x29, temp_loc]				//w20 = temp
			str 	w20, [arrayBase, w21, SXTW 2]			//v[j+gap] = temp


			ldr 	w20, [x29, j_loc]				//loads j into w20
			ldr 	w21, [x29, gap_loc]				//loads gap into w21
			sub 	w20, w20, w21					//j = j-gap
			str 	w20, [x29, j_loc]				//stores j into stack
			b 	innerMost
innerMostEnd:
			ldr 	i_r, [x29,i_loc]				///loads i_r from stack
			add 	i_r, i_r, 1					//increments i_r by one
			str 	i_r, [x29, i_loc]				//stores i value back in stack
			b 	loopTwoIn					//branches to top of second loop
loopTwoInEnd:
			ldr 	w20, [x29, gap_loc]				//loads gap to w20 register
			lsr	w20, w20, 1					//logical shift right to divide gap by 2
			str 	w20, [x29, gap_loc]				//stores w20 back into gap
			b	loopTwoStart

loopExit:

			mov 	i_r, 0						//sets i to 0
			str 	i_r, [x29, i_loc]				//stores i on stack
			mov 	arrayOffset, a_base				//sets arrayOffset to 16

			adrp 	x0, output_string3
			add 	x0, x0, :lo12:output_string3			//prints "Sorted array:\n"
			bl 	printf

print:
			ldr 	i_r, [x29, i_loc]				//loads i into i_r
			cmp 	i_r, array_s					//compares i to SIZE
			b.ge	exit						//if i >= size branch to exit


			adrp 	x0, output_string2
			add	x0, x0, :lo12:output_string2
			ldr 	w2, [x29, arrayOffset]				//print statement
			ldr	w1, [x29, i_loc]
			bl	printf

			add 	i_r, i_r, 1					//increments i by one
			str 	i_r, [x29, i_loc]				//stores i in stack
			add 	arrayOffset, arrayOffset, 4			//increments offset by 4

			b	print						//branches to print


exit:			ldp	x29, x30, [sp], dealloc
			ret

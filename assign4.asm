//Ben Foster UCID:30094638
//Date: 11/01/2021
//Assignment 4 code, pyramids (demonstrate understanding of structs and subroutines)

FALSE = 0
TRUE = 1

coord_b = 0								//size = 8, offset = 0
size_b = 8								//size = 8, offset = 8
height_b = 16								//size = 4, offset = 16
volume_b = 20								//size = 4, offset = 20
pyramid_struct_size = 24						//total size of a single pyramid


size_width = 0								//size = 4, offset = 0
size_length = 4								//size = 4, offset = 4
size_struct_size = 8							//total size of size struct


coord_x = 0								//size = 4, offset = 0
coord_y = 4								//size = 4, offset = 4
coord_struct_size = 8							//total size of a single coord struct


khafre_offset = 16							//offset for khafre
cheops_offset = khafre_offset + pyramid_struct_size			//offset for cheops


alloc = -(16+pyramid_struct_size+pyramid_struct_size)&-16
dealloc = -alloc
newAlloc = -(16+pyramid_struct_size)&-16
newdeAlloc = -newAlloc

string1: .string "Initial pyramid values:\n"				//string1
string2: .string "\nNew pyramid values:\n"				//string2
cheops: .string "cheops"						//cheops
khafre: .string "khafre"						//khafre
string3: .string "Pyramid %s\n"						//string3
string4: .string "\tCenter = (%d, %d)\n"				//string4
string5: .string "\tBase width = %d  Base length = %d\n"		//string5
string6: .string "\tHeight = %d\n"					//string6
string7: .string "\tVolume = %d\n\n"

		.balign 4						//memory is word aligned
		.global main						//start label to main


main:
		stp 	x29, x30, [sp, alloc]!				//alocates stack memory
		mov	x29, sp

		add	x8, sp, khafre_offset				//makes x8 point at khafre
		mov 	w0, 10						//stores 10 into w0
		mov 	w1, 10						//stores 10 into w1
		mov	w2, 9						//stores 9 into w2

		bl 	newPyramid					//branch link to newPyramid Function (creates khafre)

		add 	x8, sp, cheops_offset				//makes x8 point at cheops
		mov 	w0, 15						//stores 15 in w0
		mov 	w1, 15						//stores 15 in w1
		mov 	w2, 18						//stores 18 in w2

		bl 	newPyramid					//branch link to new pyramid function (creates cheops)

		adrp	x0, string1					//print statement
		add 	x0, x0, :lo12:string1
		bl 	printf

		adrp 	x0, khafre
		add 	x0, x0, :lo12:khafre
		add	x8, sp, khafre_offset
		bl 	printPyramid					//printPyramid for Khafre

		adrp 	x0, cheops
		add 	x0, x0, :lo12:cheops
		add 	x8, sp, cheops_offset
		bl 	printPyramid					//printPyramid for cheops

		add 	x1, sp, khafre_offset
		add	x2, sp, cheops_offset
		bl	equalSize					//compares sizes of khafre and cheops
		cmp 	w0, wzr						//checks returned value against 0 register, eq = false
		b.ne	jump						//if the two are equal skips to jump
		add 	x8, sp, cheops_offset
		mov 	w0, 9
		bl 	expand						//expands cheops by a factor of 9

		mov 	w0, 27
		mov     w1, -10
		add 	x8, sp, cheops_offset
		bl 	relocate					//relocates cheops to 27, -10

		mov 	w0, -23
		mov  	w1, 17
		add 	x8, sp, khafre_offset
		bl 	relocate					//relocates khafre to -23, 17

jump:
		adrp	x0, string2					//print statement
		add	x0, x0, :lo12:string2
		bl 	printf

		adrp 	x0, khafre
		add	x0, x0, :lo12:khafre
		add 	x8, sp, khafre_offset
		bl 	printPyramid					//printPyramid for khafre

		adrp 	x0, cheops
		add	x0, x0, :lo12:cheops
		add 	x8, sp, cheops_offset
		bl 	printPyramid					//printPyramid for cheops


exit:
		ldp 	x29, x30, [sp], dealloc
		ret							//returns to calling code


newPyramid:
		stp	x29, x30, [sp, newAlloc]!
		mov 	x29, sp

		str 	wzr, [x29, 16+coord_b+coord_x]			//stores 0 in p.center.x
		str	wzr, [x29, 16+coord_b+coord_y]			//stores 0 in p.center.y
		str	w0, [x29, 16+size_b+size_width]			//stores w0 in p.base.width
		str 	w1, [x29, 16+size_b+size_length]		//stores w1 in p.base.length
		str 	w2, [x29, 16+height_b]				//stores w2 in p.height
		mul 	w3, w0, w1					//w3 = w0*w1 = width*length
		mul 	w3, w3, w2					//w3 = w0*w1*w2 = width*length*height
		mov	w4, 3						//move 3 into w4 for a div operation
		sdiv	w3, w3, w4					//divides w3 by 3
		str 	w3, [x29, 16+volume_b]				//stores w3 into p.volume

		ldr 	w9, [x29, 16+coord_b+coord_x]
		str 	w9, [x8, coord_b+coord_x]			//loads and stores x to return

		ldr 	w9, [x29, 16+coord_b+coord_y]
		str 	w9, [x8, coord_b+coord_y]			//loads and stores y to return

		ldr 	w9, [x29, 16+size_b+size_width]
		str 	w9, [x8, size_b+size_width]			//loads and stores width to return

		ldr	w9, [x29, 16+size_b+size_length]
		str 	w9, [x8, size_b+size_length]			//loads and stores length to return

		ldr 	w9, [x29, 16+height_b]
		str 	w9, [x8, height_b]				//loads and stores height to return

		ldr 	w9, [x29, 16+volume_b]
		str 	w9, [x8, volume_b]				//loads and stores volume to return


		ldp 	x29, x30, [sp], newdeAlloc			//restores state
		ret							//returns


relocate:
		stp	x29, x30, [sp,-16]!
		mov 	x29, sp

		ldr 	w2, [x8, coord_b+coord_x]			//loads p->center.x into w2
		ldr 	w3, [x8, coord_b+coord_y]			//loads p_>center.y into w3
		add 	w0, w0, w2					//adds deltaX to original p->center.x
		add	w1, w1, w3					//adds deltaY to original p->center.y
		str 	w0, [x8, coord_b+coord_x]			//stores updated x value
		str	w1, [x8, coord_b+coord_y]			//stores updated y value

		ldp 	x29, x30, [sp], 16
		ret

expand:
		stp 	x29, x30, [sp, -16]!
		mov 	x29, sp

		ldr 	w1, [x8, size_b+size_width]			//loads p->base.width
		mul 	w1, w0, w1					//multiplies by factor
		str 	w1, [x8, size_b+size_width]			//stores p->base.width after scaling

		ldr 	w2, [x8, size_b+size_length]			//loads p->base.length
		mul 	w2, w0, w2					//multiplies by factor
		str 	w2, [x8, size_b+size_length]			//stores p->base.length after scaling

		ldr 	w3, [x8, height_b]				//loads p->height
		mul 	w3, w0, w3					//multiplies by factor
		str 	w3, [x8, height_b]				//stores p-> height after scaling

		mul 	w4, w1, w2					//w4 = width *length
		mul 	w4, w4, w3					//w4 = width * length * height
		mov 	w5, 3
		sdiv 	w4, w4, w5					//w4 = width * length *height /3
		str 	w4, [x8, volume_b]

		ldp 	x29, x30, [sp], 16				//restores state
		ret							//returns

equalSize:
		stp 	x29, x30, [sp, -16]!
		mov 	x29, sp

		mov 	w0, FALSE

		ldr 	x9, [x1, size_b+size_width]			//loads khafre width
		ldr 	x10, [x2, size_b+size_width]			//loads cheops width
		cmp 	x9, x10						//compares
		b.ne 	skip						//if not equal skips
		ldr 	x9, [x1, size_b+size_length]			//loads khafre length
		ldr 	x10, [x2, size_b+size_length]			//loads cheops length
		cmp 	x9, x10						//compares
		b.ne 	skip						//if not equal skips
		ldr 	x9, [x1, height_b]				//loads khafre height
		ldr 	x10, [x2, height_b]				//loads cheops height
		cmp 	x9, x10						//compares
		b.ne 	skip						//if not equal skips
		mov 	w0, TRUE					//if all checks passed, w0 is updated to be true

skip:
		ldp 	x29, x30, [sp], 16
		ret


printPyramid:
		stp 	x29, x30, [sp, -32]!
		mov 	x29, sp
		str 	x8, [x29, 16]					//stores pointer for safe keeping between calls to print

		mov	x1, x0
		adrp 	x0, string3
		add	x0, x0, :lo12:string3
		bl	printf						//prints name

		adrp 	x0, string4
		add 	x0, x0, :lo12:string4
		ldr 	x8, [x29, 16]
		ldr 	w1, [x8, coord_b+coord_x]
		ldr 	w2, [x8, coord_b+coord_y]
		bl 	printf						//prints coordinates

		adrp	x0, string5
		add	x0, x0, :lo12:string5
		ldr 	x8, [x29, 16]
		ldr 	w1, [x8, size_b+size_width]
		ldr 	w2, [x8, size_b+size_length]
		bl 	printf						//prints sizes

		adrp 	x0, string6
		add 	x0, x0, :lo12:string6
		ldr 	x8, [x29, 16]
		ldr 	w1, [x8, height_b]
		bl	printf						//prints height string

		adrp 	x0, string7
		add 	x0,x0, :lo12:string7
		ldr 	x8, [x29, 16]
		ldr 	w1, [x8, volume_b]
		bl 	printf						//prints volume string
		ldp 	x29, x30, [sp], 32
		ret

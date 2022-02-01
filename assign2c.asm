//Author: Ben Foster UCID: 30094638
//Date: October 5th, 2021
//Program Assign2c, reversing the bits of 0x01FF01FF


define(xValue, w19)
define(yValue, w20)
define(t1, w21)
define(t2, w22)
define(t3, w23)										//Declares all m4 macros to be used in the coming program
define(t4, w24)
define(stepOne, 0x55555555)
define(stepTwo, 0x33333333)
define(stepThree, 0x0F0F0F0F)
define(stepFour, 0XFF00)

output_string: 		.string 	"original: 0x%08X	reversed: 0x%08X\n"	//Declares the output strings format
			.balign 	4						//Assures divisibility by 4 as for all coming register startpoints.
			.global 	main						//sets start label to main

main:
			stp		x29, x30, [sp,-16]!				//store FP and LP to stack
			mov		x29, sp						//moves stack pointer to FP
			adrp		x0, output_string
			add		x0, x0, :lo12:output_string			//these two lines set up x0 to point to the output_string start point, we will also use x1 and x2 to pass it the two x and y variables later



step_One:
			mov		xValue, 0x01FF01FF				//stores the correct hexadecimal digit into x( aka w19)
			and		t1, xValue, stepOne				//binary and operation on x and 0x55555555, result is stored in t1
			lsl		t1, t1, 1					//binary shift t1 left by one, store result in t1
			lsr		t2 , xValue, 1					//binary shift x right one store result in t2
			and		t2, t2, stepOne					//binary and t2 and 0x55555555, stores result in t2
			orr 		yValue, t1, t2					//binary or operation done on t1, t2, result stored in y

step_Two:
			and		t1, yValue, stepTwo				//binary and performed on y and stepTwo, stored in t1
			lsl		t1, t1, 2					//binary shift performed on t1 2 digits left, stored in t1 again
			lsr		t2, yValue, 2					//binary shift performed on y two digits right, stored in t2
			and		t2, t2, stepTwo					//binary and performed on t2 and stepTwo, result stored in t2
			orr		yValue, t1, t2					//binary or performed on t1 and t1, result stored in y

step_Three:
			and		t1, yValue, stepThree				//binary and on yValue and step three, stored in t1
			lsl		t1, t1, 4					//binary shift left on t1 4, stored in t1
			lsr		t2, yValue, 4					//binary shift right on yValue 4, stored in t2
			and		t2, t2, stepThree				//binary and on t2 and stepThree, stored in t2
			orr		yValue, t1, t2					//binary or on t1 and t2, stored in y

step_Four:
			lsl		t1, yValue, 24					//binary shift left on yValue 24, stored in t1
			and		t2, yValue, stepFour				//binary and on yValue and step 4, stored in t2
			lsl		t2, t2, 8					//binary shift left on t2 8, stored in t2
			lsr		t3, yValue, 8					//binary shift right on y value 8, stored in t3
			and		t3, t3, stepFour				//binary and on t3 and step 4, stored in t3
			lsr		t4, yValue, 24					//binary shift right yValue 24, stored in t4
			orr		t1, t1, t2					//binary or on t1 and t2, stored in t1
			orr		t3, t3, t4					//binary or on t3 and t4, stored in t3
			orr		yValue, t1, t3					//binary or on t1 and t3 (the binary orr taken from t1 and t2 and t3 and t4) stored in yValue

			mov		w1, xValue					//xValue stored in w1 to be printed
			mov		w2, yValue					//yValue stored in w2 to be printed
			bl 		printf						//calls print f function from the c library
exit:
			ldp		x29, x30, [sp], 16				//restores the SP to previous state
			ret								//returns to the os

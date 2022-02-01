//Author: Ben Foster UCID: 30094638
//Date: 09/25/2021
//
//Description:Minimized version of assignment one, calculating the same equation
//using madd as well as a test at the bottom of the loop, as well as m4 macros

define(xValue, x19)
define(yValue, x20)
define(maximum, x21)
define(termOne, x22)
define(termTwo, x23)					//All these lines are used exclusively to define m4 macros for commonly used registers and values
define(coeff1, x25)
define(coeff2, x26)
define(coeff3, x27)
define(maxX, 10)



output_string:	.string "The X value is : %ld, the Y value is: %ld, and the current max output is: %ld\n"

		.balign 4

		.global main

main:
		stp 	x29, x30, [sp,-16]!
		mov 	x29, sp


		mov 	xValue, -10			//Current X value set to negative ten for the purpose of starting the program

		mov	coeff1, -3
		mov 	coeff2, 267			//all coefficients set to their proper values
		mov 	coeff3, 47


		b	test				//unconditianal branch to the test to ensure the loop is functional

loopTop:
		mul	termOne, xValue, xValue		//termOne now holds x^2, termOne = x*x
		mov	termTwo, termOne		//termTwo now holds x^2, termTwo = termOne = x*x
		mul	termOne, termOne, termOne	//termOne now holds x^4, termOne = termOne*termOne = (x^2)*x^2
		mul	termOne, termOne, coeff1	//termOne now holds -3(x^4)
		madd	yValue, termTwo, coeff2, termOne//yValue now holds termOne+267(x^2), this is the combination of the first two terms
		madd	yValue, xValue, coeff3, yValue	//yValue now hold termOne+termTwo+ termThree
		sub	yValue, yValue, 43		//subtracts 43 from the yValue, completing the equation

		cmp 	xValue, -10
		b.ne	elseif				//this is used to determine if the loop is on its first iteration, if it is, the maximum is automatically set
		mov	maximum, yValue

elseif:
		cmp	yValue, maximum			//compares the yValue to the current maximum yValue
		b.le 	skip				//if the y value is less than the current max, the max is not updated and the code jumps to skip:
		mov	maximum, yValue			//updates the maximum to the current yValue if it is greater than the previous max

skip:
		adrp	x0, output_string
		add	x0, x0, :lo12:output_string
		mov	x1, xValue
		mov	x2, yValue			//formats the string with the correct variables in the correct places
		mov	x3, maximum
		bl 	printf
		add	xValue, xValue, 1		//increments xValue by one

test:		cmp	xValue, maxX			//test to ensure the xValue is within the prescribed range
		b.le	loopTop

		ldp	x29, x30, [sp], 16
		ret

//File: assign1a.s
//Authour: Ben Foster UCID: 30094638
//Date: 2021/09/22
//
//Description:
// A program that calculates the maximum value of y = -3x^4 + 267x^2 + 47x - 43
// Using the range -10 <= x <= 10
// At each x value from -10 -> 10, the current x value, the current y value, and
// also the current maximum should be output

output_string: .string "the x value is: %ld, the y value is: %ld, the current max output is: %ld\n"

		.balign 4

		.global main
main:
		stp 	x29, x30, [sp, -16]!
		mov 	x29, sp

		mov 	x19, -10	//x19 is set to -10, the minimum x value
					//x19 is current x value
					//x20 is current y value
					//x21 is current max value
		mov	x24, -3 	//stores x24 as constant -3
		mov	x25, 267	//stores x25 as constant 267
		mov 	x26, 47		//stores x26 as constant 47

loop:
		cmp	x19, 10		//compares value to 10 and sets condition flag
		b.gt	exit		//if condition flag indicates x19 is greater than 10, the loop is exited


		mul 	x22, x19, x19	//squares x19 value, this needs to be done twice more
		mul	x23, x19, x19	//stores squared value in x23, this is needed for the calculation
		mul	x22, x22, x19	//x19 is now cubed
		mul	x22, x22, x19	//x19 is now raised to the power of four and stored in x22
		mul	x22, x22, x24	//multiplies x22 by x24 (x^4*-3)
		mul	x23, x23, x25	//multiplies x23 by x25 (267*x^2)
		add	x22, x22, x23	//adds x22 and x23 together, completing first two terms
		mul	x23, x19, x26	//multiplies x19 and x26 together stores back in x23 (47*x)
		add	x22, x22, x23	//adds x23 to x22, first three terms complete
		sub 	x20, x22, 43	//subtracts 43 from first three terms, math now complete

		cmp	x19, -10
		b.ne 	elseif
		mov 	x21, x20
elseif:
		cmp 	x20, x21	//compares current y value and max value
		b.le	skip		//if less or equal to current max, skips updating the max
		mov	x21, x20	//updates the max to the current y value
skip:
		adrp	x0, output_string
		add 	x0, x0, :lo12:output_string
		mov	x1, x19 	//Stores the current x value in x1 to be printed
		mov	x2, x20 	// Stores the current y value in x2 to be printed
		mov	x3, x21 	// Stores the current maximum in x3 to be printed

		bl 	printf		//prints the output
		add	x19, x19, 1	//increments x19, the x value by one
		b	loop		//returns to the top of the loop
exit:
		ldp 	x29, x30, [sp], 16
		ret


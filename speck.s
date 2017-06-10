.text

.global main

ROR:
	@address of 64-bit number to be rotated is in r0
	
	@we need r4. so save it in stack
	sub sp, sp, #4
	str r4, [sp]

	mov r4, r0	@moving address of the number to r4

	@loading the 64-bit number to 2 32-bit registers
	ldr r0, [r4, #4]
	ldr r1, [r4]

	lsr r2, r0, #8
	lsl r3, r1, #24
	orr r12, r2, r3	@taking the first rotated part to r12

	lsr r2, r1, #8
	lsl r3, r0, #24
	orr r1, r2, r3	@taking the second rotated part

	@updating the number with rotation
	str r12, [r4, #4]
	str r1, [r4]

	@loading r4 back from stack
	ldr r4, [sp]
	add sp, sp, #4

	mov pc, lr

ROL:
	@address of 64-bit number to be rotated is in r0
	
	@we need r4. so save it in stack
	sub sp, sp, #4
	str r4, [sp]
	mov r4, r0	@moving address of number to r4

	@loading the 64-bit number to 2 32-bit registers
	ldr r0, [r4, #4]
	ldr r1, [r4]

	lsl r2, r0, #3
	lsr r3, r1, #29
	orr r12, r2, r3	@taking the first rotated part to r12

	lsl r2, r1, #3
	lsr r3, r0, #29
	orr r1, r2, r3	@taking the second rotated part

	@updating the number with rotation
	str r12, [r4, #4]
	str r1, [r4]

	@loading r4 back from stack
	ldr r4, [sp]
	add sp, sp, #4

	mov pc, lr


R:
	@starting addresses of 64-bit numbers x, y are in r0, r1. value of k(64-bit) 
	@is in r2(32-bit) and r3(32-bit) (i.e.&x, &y, k)

	@saving return address and r4-r7 in stack
	@since we call other functions and use r4-r7 inside the function 
	sub sp, sp, #20
	str lr, [sp, #16]	
	str r4, [sp, #12]	
	str r5, [sp, #8]	
	str r6, [sp, #4]	
	str r7, [sp, #0]	


	@step 1: ROR x

	@saving r0, r1, r2, r3 in stack before calling ROR
	sub sp, sp, #16
	str r0, [sp, #12]
	str r1, [sp, #8]
	str r2, [sp, #4]
	str r3, [sp, #0]

	bl ROR		

	@restoring r0, r1, r2, r3 from stack
	ldr r0, [sp, #12]
	ldr r1, [sp, #8]
	ldr r2, [sp, #4]
	ldr r3, [sp, #0]
	add sp, sp, #16


	@step 2: x = x + y

	@loading x to r4, r5; loading y to r6, r7
	ldr r4, [r0, #4]
	ldr r5, [r0]
	ldr r6, [r1, #4]
	ldr r7, [r1]

	@adding 32-bit parts to get 64-bit addition
	adds r5, r5, r7	
	adc r6, r4, r6

	
	@step 3: x = x ^ k
	
	eor r5, r5, r3
	eor r6, r6, r2

	@updating x in the stack
	str r5, [r0]
	str r6, [r0, #4]

	
	@step 4: ROL y

	@saving r0, r1, r2, r3 in stack before calling ROL
	sub sp, sp, #16
	str r0, [sp, #12]
	str r1, [sp, #8]
	str r2, [sp, #4]
	str r3, [sp, #0]

	mov r0, r1
	bl ROL		

	@restoring r0, r1, r2, r3 from stack
	ldr r0, [sp, #12]
	ldr r1, [sp, #8]
	ldr r2, [sp, #4]
	ldr r3, [sp, #0]
	add sp, sp, #16
	

	@step 5: y = y ^ x

	@loading y to r4, r5; loading x to r6, r7
	ldr r4, [r0, #4]
	ldr r5, [r0]
	ldr r6, [r1, #4]
	ldr r7, [r1]

	eor r4, r4, r6
	eor r5, r5, r7
	
	@updating y in the stack
	str r5, [r1]
	str r4, [r1, #4]
	

	@loading actual return address and r4-r7 from stack and returning
	ldr lr, [sp, #16]	
	ldr r4, [sp, #12]	
	ldr r5, [sp, #8]	
	ldr r6, [sp, #4]	
	ldr r7, [sp, #0]	
	add sp, sp, #20
	mov pc, lr
	
	
main:
	@ preserving return address
	sub sp, sp, #4
	str lr, [sp]
	
	@to read 4 64-bit numbers to stack
	sub sp, sp, #32

	@prompt user to enter the key
	ldr r0, =format1
	bl printf

	@reading the key
	ldr r0, =format2
	add r1, sp, #24		@a = key[1] will be read to [sp, #24]
	add r2, sp, #16		@b = key[0] will be read to [sp, #16]
	bl scanf

	@prompt user to enter plain text
	ldr r0, =format3
	bl printf

	@reading the plain text
	ldr r0, =format2	
	add r1, sp, #8		@x = pt[1] will be read to [sp, #8]
	add r2, sp, #0		@y = pt[0] will be read to [sp, #0]
	bl scanf
	
	@------------------encryption-------------------------

	@calling R(&x, &y, b)
	add r0, sp, #8		@&x
	mov r1, sp		@&y
	ldr r2, [sp, #20]	@b - first part	(32-bit)
	ldr r3, [sp, #16]	@b - second part (32-bit)
	bl R

	mov r4, #0		@i = 0

	loop:	
		cmp r4, #31	@if i < 31, continue; else, exit.
		bge exit

		@calling R(&a, &b, i)
		add r0, sp, #24		@&a
		add r1, sp, #16		@&b
		mov r2, #0		@0 - first part (32-bit)
		mov r3, r4		@i - second part (32-bit)
		bl R

		@calling R(&x, &y, b)
		add r0, sp, #8		@&x
		mov r1, sp		@&y
		ldr r2, [sp, #20]	@b - first part	(32-bit)
		ldr r3, [sp, #16]	@b - second part (32-bit)
		bl R

		add r4, r4, #1		@i++
		b loop

	exit:
		
	
	@printing out the cipher text
	ldr r0, =format4
	ldr r1, [sp, #12]
	ldr r2, [sp, #8]
	bl printf

	ldr r0, =format5
	ldr r1, [sp, #4]
	ldr r2, [sp, #0]
	bl printf

	@-----------------------------------------------------


	@releasing stack used for 4 64-bit numbers
	add sp, sp, #32

	@popping return address and return
	ldr lr, [sp]
	add sp, sp, #4
	mov pc, lr

.data
	format1: .asciz "Enter the key:\n"
	format2: .asciz "%llx %llx"
	format3: .asciz "Enter the plain text:\n"
	format4: .asciz "Cipher text is:\n%x%x "
	format5: .asciz "%x%x\n"


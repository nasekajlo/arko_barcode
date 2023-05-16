.include "img_info.asm"
.include "data.asm"

.global write_line
.global count_bar_loop

	.text

# ========================================================================
# generate_line - writes a single line of pixels and increments x by 1
# arguments:
# 	a0 - Image Info descriptor
#	a1 - x coordinate
#	a2 - y coordinate
#	a3 - Color of written line (0 - black (default), 1 - white)
# return value: none
write_line:
	la s0, codes		#pointer on codes
	addi sp, sp, -8
	sw ra, 4(sp)		#push ra
	sw a2, 0(sp)		#push a2 to preserve it
	mv s1, a0 		#preserve imgInfo for further use
	lb a4, 11		#pixel number in checking word
	lb a5, 0		#bit
	lw a6, 0		#store the symbol in binary 
	lb a7, 2413		#star's code

count_bar_loop:
	jal get_pixel
	mul a5, a3, a4		#color * 2^11
	add a6, a6, a5		#lallala
	beqz a4, find_symbol_loop
	addi a1, a1, 1
	addi a4, a4, -1 
	b count_bar_loop

find_symbol_loop:		
	lb t1, 0(s0)
	lb a4, 11
	beq t1, a6, write_symbol		
	beq a6, a7, count_bar_loop_exit
	addi s0, s0, 2		#go throw element and its code in ascii
	lw a6, 0
	b find_symbol_loop
	
write_symbol:
	lw a6, 0
	addi s0, s0, 1
	lb t1, 0(s0)
	li a7, 4
	mv a0, t1
	ecall
	b count_bar_loop

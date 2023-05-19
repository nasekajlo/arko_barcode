.include "img_info.asm"
.include "data.asm"
.include "bmp.asm"

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
#	a4 - Space to be filled
# return value:
#	a4 - Decoded string
write_line:
	#jal read_bmp
	addi sp, sp, -4
	sw ra, 0(sp)		# push ra

	lw a1, ImgInfo_width(a0)
	lw a2, ImgInfo_height(a0)
	la s0, codes		#pointer on codes
	addi sp, sp, -8
	sw ra, 4(sp)		#push ra
	sw a2, 0(sp)		#push a2 to preserve it
	mv s1, a0 		#preserve imgInfo for further use
	li s2, 12		#pixel number in checking word
	li a5, 0		#bit
	li a6, 0		#store the symbol in binary 
	li a7, 2413		#star's code
	
skip_start_spaces:
	addi a1, a1, 1
	beq a3, zero, skip_start_spaces
	addi a1, a1, 13
	

count_bar_loop:
	jal get_pixel
	sll a5, a3, s2		#color * 2^11
	add a6, a6, a5		#calculate symbol code in 10
	beqz s2, find_symbol_loop
	addi a1, a1, 1		#go to the next pixel
	addi s2, s2, -1 	#increase position in bin
	b count_bar_loop

find_symbol_loop:		
	lb t1, 0(s0)		#first synmol in codes
	li s2, 12		#reload s2 by 12
	beq t1, a6, write_symbol #symbol found	
	beq a6, a7, count_bar_loop_exit		#last star
	addi s0, s0, 2		#go throw element and its code in ascii
	lw a6, 0		
	b find_symbol_loop
	
write_symbol:
	addi a1, a1, 1		#skip one space between symbols
	lw a6, 0
	addi s0, s0, 1		#take code of symbol
	sb s0, 0(a4)		#load this symbol in a4
	b count_bar_loop
	
count_bar_loop_exit:
	lw ra, 0(sp)		#pop ra
	addi sp, sp, 4
	jr ra


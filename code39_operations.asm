.include "img_info.asm"
.include "data.asm"

.global write_line
.global generate

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
	addi sp, sp, -8
	sw ra, 4(sp)		#push ra
	sw a2, 0(sp)		#push a2 to preserve it
	mv s1, a0 		#preserve imgInfo for further use

write_loop:
	jal set_pixel
	
	bltz a2, write_loop_exit
	addi a2, a2, -1
	
	j write_loop

write_loop_exit:
	addi a1, a1, 1
	lw a2, 0(sp)		#pop a2
	lw ra, 4(sp)		#pop ra
	addi sp, sp, 8
	jr ra

# ========================================================================
# gen_lines: generate n lines by calling generate_line
# arguments:
#	a4 - line thickness in pixels
gen_lines:
	addi sp, sp, -12
	sw ra, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)

gen_lines_loop:
	beqz a4, gen_lines_exit
	jal write_line
	addi a4, a4, -1
	j gen_lines_loop

gen_lines_exit:
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	addi sp, sp, 12
	jr ra

# ========================================================================
# setup_char - finds index for the specified char in "codes" label 
# arguments:
# 	s0 - codes label
#	s1 - number of characters in a single code
#	t1 - character in question
# returns: none
setup_char:
	li t2, '*'
	beq t1, t2, setup_ast
	
	li t2, 'A'
	bge t1, t2, setup_str 
	
	li t2, ' '
	beq t1, t2, setup_space
	
	li t2, '-'
	beq t1, t2, setup_minus
	
	li t2, '$'
	beq t1, t2, setup_dolar
	
	li t2, '%'
	beq t1, t2, setup_percent
	
	li t2, '.'
	beq t1, t2, setup_dot
	
	li t2, '/'
	beq t1, t2, setup_slash
	
	li t2, '+'
	beq t1, t2, setup_plus
	
#setup_numbers:
	addi t1, t1, -48	# Subtract 48 for numbers
	mul t1, t1, s1 		# Multiply by 9 -> correct character position
	add s0, s0, t1 		# start position of the encoded character
	
	j setup_exit

setup_space:
	addi s0, s0, 324
	j setup_exit

setup_minus:
	addi s0, s0, 333
	j setup_exit

setup_dolar:
	addi s0, s0, 342
	j setup_exit

setup_percent:
	addi s0, s0, 351
	j setup_exit

setup_dot:
	addi s0, s0, 360
	j setup_exit

setup_slash:
	addi s0, s0, 369
	j setup_exit

setup_plus:
	addi s0, s0, 378
	j setup_exit

setup_ast:
	addi s0, s0, 387
	j setup_exit

setup_str:
	addi t1, t1, -55
	mul t1, t1, s1
	add s0, s0, t1

setup_exit:
	jr ra


# ========================================================================
# arguments:
# 	a0 - Image Info descriptor
#	a5 - input text
# variables used during runtime:
#	a1 - x coordinate
#	a2 - y coordinate
# return value: none
generate:
	addi sp, sp, -4
	sw ra, 0(sp)		# push ra
	
	lw a1, ImgInfo_width(a0)
	lw a2, ImgInfo_height(a0)
	li a3, 0		# Set color to black


generate_loop:
	lb t1, (a5)
	beqz t1, generate_exit
	addi a5, a5, 1

	li s1, 9 		# Code 39 has 9 characters, set iteration count
	la s0, codes
	
	jal setup_char


gen_code_loop:
	lb a4, (s0)
	jal gen_lines
	
	addi s1, s1, -1
	beqz s1, prep_next_char
	addi s0, s0, 1
	
	# Invert color
	mv t0, a3
	addi a3, a3, 1
	rem a3, a3, t0

	j gen_code_loop

prep_next_char:
	li a4, 1
	li a3, 1
	jal gen_lines
	li a3, 0
	j generate_loop

generate_exit:
	lw ra, 0(sp)		#pop ra
	addi sp, sp, 4
	jr ra

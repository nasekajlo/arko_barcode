.include "img_info.asm"
.include "data.asm"

.global generate_line
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
generate_line:
	addi sp, sp, -8
	sw ra, 4(sp)		#push ra
	sw a2, 0(sp)		#push a2 to preserve it
	mv s1, a0 		#preserve imgInfo for further use

generate_loop:
	jal set_pixel
	
	bltz a2, generate_loop_exit
	addi a2, a2, -1
	
	j generate_loop

generate_loop_exit:
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
	jal generate_line
	addi a4, a4, -1
	j gen_lines_loop

gen_lines_exit:
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	addi sp, sp, 12
	jr ra


# ========================================================================
# arguments:
# 	a0 - Image Info descriptor
#	a4 - input text
# variables used during runtime:
#	a1 - x coordinate
#	a2 - y coordinate
# return value: none
generate:
	addi sp, sp, -4
	sw ra, 0(sp)		#push ra
	
	lw a1, ImgInfo_width(a0)
	lw a2, ImgInfo_height(a0)
	li a3, 0 # Set color to black
	li s2, '*' # Must start and end with *


generate_star:
	li s1, 9 # Code 39 has 9 characters, set iteration count
	la s0, codes
	addi s0, s0, 387 # position of the * code

generate_star_loop:
	lb a4, (s0)
	jal gen_lines
	
	beqz s1, generate_exit
	addi s0, s0, 1
	addi s1, s1, -1
	
	# Invert color
	mv t0, a3
	addi a3, a3, 1
	rem a3, a3, t0

	j generate_star_loop

generate_exit:
	lw ra, 0(sp)		#pop ra
	addi sp, sp, 8
	jr ra

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
	addi sp, sp, -12
	sw ra, 8(sp)		#push ra
	sw s1, 4(sp)		#push s1
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
	lw s1, 4(sp)		#pop s1
	lw ra, 8(sp)		#pop ra
	addi sp, sp, 12
	jr ra

# Generates 2 pixel-wide line
generate_thick_line:
	addi sp, sp, -4
	sw ra, 0(sp)

	jal generate_line
	jal generate_line
	
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra


# ========================================================================
generate:
	addi sp, sp, -4
	sw ra, 0(sp)		#push ra
	
	lw a1, ImgInfo_width(a0)
	lw a2, ImgInfo_height(a0)
	
	jal generate_thick_line

generate_exit:
	lw ra, 0(sp)		#pop ra
	addi sp, sp, 8
	jr ra

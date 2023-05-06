#-------------------------------------------------------------------------------
#author: Rajmund Kozuszek
#date : 2023.04.26
#description : example RISC V program for reading, modifying and writing a BMP file 
#-------------------------------------------------------------------------------

.include "img_info.asm"
.globl set_pixel
.globl get_pixel
.globl invert_diagonal

	.text

# ============================================================================
# set_pixel - sets the color of specified pixel
#arguments:
#	a0 - address of ImgInfo image descriptor
#	a1 - x coordinate
#	a2 - y coordinate - (0,0) - bottom left corner
#	a3 - pixel color (on the lsb)
#return value: none
#remarks - a0, a1, a2 values are left unchanged

set_pixel:
	lw t1, ImgInfo_lbytes(a0)
	mul t0, t1, a2  # t0 = y * linebytes
	srai t1, a1, 3	# t1 = x / 8 (pixel offset in line)
	add t0, t0, t1  # t0 is offset of the pixel
	
	lw t1, ImgInfo_imdat(a0) # address of image data
	add t0, t0, t1 	# t0 is address of the pixel

	andi t1, a1, 0x7   # t1 = x % 8 (pixel offset within the byte)

	lbu t2,(t0)	# load 8 pixels

	sll  t2, t2, t1	# pixel bit on the msb of the lowest byte
	andi a3, a3, 1  # mask the color
	
	li t3, 0x80  # pixel mask
	beqz a3, set_pixel_black
	
set_pixel_white:
	or   t2, t2, t3
	srl  t2, t2, t1
	sb   t2, (t0)	# store 8 pixels
	jr   ra
	
set_pixel_black:
	not  t3, t3
	and  t2, t2, t3
	srl  t2, t2, t1
	sb   t2, (t0)	# store 8 pixels
	jr   ra

# ============================================================================
# get_pixel- returns color of specified pixel
#arguments:
#	a0 - address of ImgInfo image descriptor
#	a1 - x coordinate
#	a2 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - pixel color (0 or 1)
#remarks: a1, a2 are preserved

get_pixel:
	lw   t1, ImgInfo_lbytes(a0)
	mul  t0, t1, a2  # t0 = y * linebytes
	srai t1, a1, 3	# t1 = x / 8 (pixel offset in line)
	add  t0, t0, t1  # t0 is offset of the pixel
	
	lw   t1, ImgInfo_imdat(a0) # address of image data
	add  t0, t0, t1 	# t0 is address of the pixel

	andi t1, a1, 0x7   # t1 = x % 8 (pixel offset within the byte)

	lbu  a0,(t0)	# load 8 pixels
	sll  a0, a0, t1  # pixel bit is on the msb of the lowest byte
	srli a0, a0, 7
	andi a0, a0, 0x1 

	jr   ra

# ============================================================================
# invert_diagonal - inverts pixel values on the main diagonal in the input image
#arguments:
#	a0 - address of ImgInfo image descriptor
#return value:
#	none

# for (int y = imgInfo->height-1; y >= 0; --y)
#   for (int x = imgInfo->width-1; x >= 0; --x)
#   {
#     unsigned pval = get_pixel(imgInfo, x, y);
#     set_pixel(imgInfo, x, y, ~pval);
#   }

invert_diagonal:
	addi sp, sp, -8
	sw ra, 4(sp)		#push ra
	sw s1, 0(sp)		#push s1
	mv s1, a0 		#preserve imgInfo for further use
	
	lw a2, ImgInfo_height(a0)
	addi a2, a2, -1		
	lw a1, ImgInfo_width(a0)
	addi a1, a1, -1
	
invert_diagonal_next:
	jal get_pixel
	
	not a3, a0
	
	mv a0, s1
	jal set_pixel
	
	addi a1, a1, -1
	blt a1, zero, invert_diagonal_exit
	
	addi a2, a2, -1
	bge a2, zero, invert_diagonal_next
	
invert_diagonal_exit:
	lw s1, 0(sp)		#pop s1
	lw ra, 4(sp)		#pop ra
	addi sp, sp, 8
	jr ra

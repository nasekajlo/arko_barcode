.include "img_info.asm"

	.data

imgInfo: 	.space	28	# image descriptor

	.align 2		# word boundary alignment
dummy:		.space  2
bmpHeader:	.space	BMPHeader_Size
		.space  1024	# enough for 256 lookup table entries

	.align 2
imgData: 	.space	MAX_IMG_SIZE

ifname:		.asciz  "source.bmp"
ofname: 	.asciz  "result.bmp"

input:		.space 	19 # Supports up to 19 characters
prompt:		.asciz 	"\n(Must start and end with '*' to be valid)\nText: "
	.align 0
space:		.space 	100

	.text
	
main:
	la a4, space
	#li t1, '9'
	#sb t1, 0(a4)
	#sw zero, 1(a4)
	

# initialize image descriptor
	la a0, imgInfo 
	la t0, ifname	# input file name
	sw t0, ImgInfo_fname(a0)
	la t0, bmpHeader
	sw t0, ImgInfo_hdrdat(a0)
	la t0, imgData
	sw t0, ImgInfo_imdat(a0)
	jal read_bmp
	bnez a0, main_failure
	
	la a0, imgInfo
	jal write_line
	
	
	la a0, space
	li a7, 4
	ecall
	

main_failure:
	li a7, 10
	ecall

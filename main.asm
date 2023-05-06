.include "img_info.asm"

	.data

imgInfo: 	.space	56	# image descriptor

	.align 2		# word boundary alignment
dummy:		.space  2
bmpHeader:	.space	BMPHeader_Size
		.space  1024	# enough for 256 lookup table entries

	.align 2
imgData: 	.space	MAX_IMG_SIZE

ifname:		.asciz  "white.bmp"
ofname: 	.asciz  "result.bmp"

input:		.asciz  "PINEAPPLE"


	.text
	
main:
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
	jal generate
	
	la a0, imgInfo
	la t0, ofname
	sw t0, ImgInfo_fname(a0)
	jal save_bmp

main_failure:
	li a7, 10
	ecall

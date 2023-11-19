/*
 * Copyright (c) 1995 FirePower Systems, Inc.
 * Copyright (c) 1994 FirmWorks, Mountain View CA USA. All rights reserved.
 * Copyright (c) 1994 FirePower Systems Inc.
 *
 * $RCSfile: vrstart.s $
 * $Revision: 1.7 $
 * $Date: 1996/06/20 16:30:20 $
 * $Locker:  $
 */

.set ctr,9

	.text
	.align  4

	.globl  start
start:

	/*
	 * We get control from the firmware here.
	 * As of 4/19/94, we're getting the following arguments:
	 * r1   initial stack pointer
	 * r2   zero (we must set up TOC)
	 * r3   reserved (residual data)
	 * r4   client program entry point
	 * r5   client interface handler
	 * r6   client program argument address
	 * r7   client program argument length
	 *
	 * Note that we're receiving all our arguments in registers;
	 * if we call C subroutines before calling vrmain we'll
	 * have to save state...so it might not be best to use bzero()
	 * (unless we recode it in assembler).
	 */

	/*
	 * XXX - We may need to remap ourselves. If so, that code goes here.
	 * XXX - Is bss zeroed? If not, do that here.
	 */

	/*
	 * Now we know where we are. Store the cif_handler, find vrmain,
	 * and jump to it.
	 * TODO: does [toc] even mean something in llvm machine code asm?
	 */

	sync
	isync
	lis %r1, stack@ha
	addi %r1, %r1, stack@l
	addi %r1, %r1, 8192
	addi %r1, %r1, 8192
	addi %r1, %r1, 8192
	addi %r1, %r1, 8192

	mfmsr %r8
	li %r0, 0
	mtmsr %r0
	isync

	mfspr	%r0,287		 /* mfpvbr %r0 PVR = 287 */
	srwi	%r0,%r0,0x10	
	cmplwi	%r0,0x02	 /* 601 CPU = 0x0001 */
	blt	2f		 /* skip over non-601 BAT setup */
	cmplwi	%r0,0x39	 /* PPC970 */
	blt	0f		
	cmplwi	%r0,0x45	 /* PPC970GX */
	ble	1f		
	/* non PPC 601 BATs */
0:	li	%r0,0		
	mtibatu	0,%r0		
	mtibatu	1,%r0		
	mtibatu	2,%r0		
	mtibatu	3,%r0		
	mtdbatu	0,%r0		
	mtdbatu	1,%r0		
	mtdbatu	2,%r0		
	mtdbatu	3,%r0		
				
	li	%r9,0x12		/* BATL(0, BAT_M, BAT_PP_RW) */
	mtibatl	0,%r9		
	mtdbatl	0,%r9		
	li	%r9,0x1ffe		/* BATU(0, BAT_BL_256M, BAT_Vs) */
	mtibatu	0,%r9		
	mtdbatu	0,%r9		
	b	3f		
	/* 970 initialization stuff */
1:				
	/* make sure we're in bridge mode */
	clrldi	%r8,%r8,3	
	mtmsrd	%r8		
	isync			
	 /* clear HID5 DCBZ bits (56/57), need to do this early */
	mfspr	%r9,0x3f6	
	rldimi	%r9,0,6,56	
	sync			
	mtspr	0x3f6,%r9	
	isync			
	sync			
	/* Setup HID1 features, prefetch + i-cacheability controlled by PTE */
	mfspr	%r9,0x3f1	
	li	%r11,0x1200	
	sldi	%r11,%r11,44	
	or	%r9,%r9,%r11	
	mtspr	0x3f1,%r9	
	isync			
	sync			
	b	3f			
	/* PPC 601 BATs */
2:	li	%r0,0		
	mtibatu	0,%r0		
	mtibatu	1,%r0		
	mtibatu	2,%r0		
	mtibatu	3,%r0		
				
	li	%r9,0x7f	
	mtibatl	0,%r9		
	li	%r9,0x1a	
	mtibatu	0,%r9		
				
	lis	%r9,0x80	
	addi	%r9,%r9,0x7f	
	mtibatl	1,%r9		
	lis	%r9,0x80	
	addi	%r9,%r9,0x1a	
	mtibatu	1,%r9		
				
	lis	%r9,0x100	
	addi	%r9,%r9,0x7f	
	mtibatl	2,%r9		
	lis	%r9,0x100	
	addi	%r9,%r9,0x1a	
	mtibatu	2,%r9		
				
	lis	%r9,0x180	
	addi	%r9,%r9,0x7f	
	mtibatl	3,%r9		
	lis	%r9,0x180	
	addi	%r9,%r9,0x1a	
	mtibatu	3,%r9		
				
3:	isync			
				
	mtmsr	%r8		
	isync			
				
	/*
	 * Make sure that .bss is zeroed
	 */
				
	li	%r0,0		
	lis	%r8,_edata@ha	
	addi	%r8,%r8,_edata@l
	lis	%r9,_end@ha	
	addi	%r9,%r9,_end@l	
				
5:	cmpw	0,%r8,%r9	
	bge	6f		
	/*
	 * clear by bytes to avoid ppc601 alignment exceptions
	 */
	stb	%r0,0(%r8)	
	stb	%r0,1(%r8)	
	stb	%r0,2(%r8)	
	stb	%r0,3(%r8)	
	addi	%r8,%r8,4	
	b	5b		

	.extern vrmain
6:	b	vrmain

	.globl  VrGetProcRev
VrGetProcRev:
	mfpvr   %r3         /* get processor version*/
	blr
VrGetProcRev.end:

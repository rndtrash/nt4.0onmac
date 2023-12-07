/*++
 *
 * Copyright (c) 1996 FirePower Systems, Inc.
 * Copyright (c) 1995 FirePower Systems, Inc.
 * Copyright (c) 1994 FirmWorks, Mountain View CA USA. All rights reserved.
 * Copyright (c) 1994 FirePower Systems Inc.
 *
 * $RCSfile: vrpehdr.c $
 * $Revision: 1.7 $
 * $Date: 1996/02/17 00:50:30 $
 * $Locker:  $

Module Name:

	vrpehdr.c

Abstract:

	These routines read and parse the Microsoft PE header.

Author:

	Mike Tuciarone  9-May-1994


Revision History:

--*/


#include "veneer.h"




#define	HEADER_CHR	(IMAGE_FILE_EXECUTABLE_IMAGE	| \
			 IMAGE_FILE_BYTES_REVERSED_LO	| \
			 IMAGE_FILE_32BIT_MACHINE	| \
			 IMAGE_FILE_BYTES_REVERSED_HI)

/*
 * For some reason NT 3.5 changed the OSLoader header.
 */
#define	HEADER_CHR_35	(IMAGE_FILE_EXECUTABLE_IMAGE	| \
			 IMAGE_FILE_32BIT_MACHINE	| \
			 IMAGE_FILE_LINE_NUMS_STRIPPED)

void *
load_file(ihandle bootih)
{
	IMAGE_FILE_HEADER FileHdr;
	IMAGE_OPTIONAL_HEADER OptHdr;
	IMAGE_SECTION_HEADER *SecHdr, *hdr;
	int res, size, i;
	PCHAR BaseAddr;

	if ((res = OFRead(bootih, (char *) &FileHdr, IMAGE_SIZEOF_FILE_HEADER))
	    != IMAGE_SIZEOF_FILE_HEADER) {
		fatal("Couldn't read entire file header: got %d\n", res);
	}

	// TODO:
	{
		char *filehdrc = (char *)&FileHdr;
		for (int i = 0; i < IMAGE_SIZEOF_FILE_HEADER; i++) {
			//debug(VRDBG_MAIN, "HDR: %x\n", (unsigned char)filehdrc[i]);
		}
	}

	/*
	 * Sanity check.
	 */
	FileHdr.Machine = LE16BE(FileHdr.Machine);
	if (FileHdr.Machine != IMAGE_FILE_MACHINE_POWERPC) {
		// TODO: add the big endian machine type
		fatal("Wrong machine type: %x\n", FileHdr.Machine);
	}
#ifdef NOT
	/*
	 * Don't bother to check the flags. They change every release anyway.
	 */
	if ((FileHdr.Characteristics & HEADER_CHR   ) != HEADER_CHR &&
	    (FileHdr.Characteristics & HEADER_CHR_35) != HEADER_CHR_35) {
		fatal("Wrong header characteristics: %x\n",
		    FileHdr.Characteristics);
	}
#endif

	FileHdr.SizeOfOptionalHeader = LE16BE(FileHdr.SizeOfOptionalHeader);
	size = FileHdr.SizeOfOptionalHeader;
	if ((res = OFRead(bootih, (char *) &OptHdr, size)) != size) {
		fatal("Couldn't read optional header: expect %x got %x\n",
		    size, res);
	}

	/*
	 * More sanity.
	 */
	OptHdr.Magic = LE16BE(OptHdr.Magic);
	if (OptHdr.Magic != 0x010b) {
		fatal("Wrong magic number in header: %x\n", OptHdr.Magic);
	}

	/*
	 * Compute image size and claim memory at specified virtual address.
	 * We assume the SizeOfImage field is sufficient.
	 */
	OptHdr.ImageBase = LE32BE(OptHdr.ImageBase);
	OptHdr.SizeOfImage = LE32BE(OptHdr.SizeOfImage);
	BaseAddr = (PCHAR) OptHdr.ImageBase;
	if (CLAIM(BaseAddr, OptHdr.SizeOfImage) == -1) {
		fatal("Couldn't claim %x bytes of VM at %x\n",
	        OptHdr.SizeOfImage, BaseAddr);
	}
	debug(VRDBG_MAIN, "BaseAddr: %x\n", BaseAddr);
	bzero(BaseAddr, OptHdr.SizeOfImage);

	/*
	 * Allocate section headers.
	 */
	FileHdr.NumberOfSections = LE16BE(FileHdr.NumberOfSections);
	size = FileHdr.NumberOfSections * sizeof(IMAGE_SECTION_HEADER);
	SecHdr = (PIMAGE_SECTION_HEADER) malloc(size);
	if ((res = OFRead(bootih, (char *) SecHdr, size)) != size) {
		fatal("Couldn't read section headers: expect %x got %x\n",
		    size, res);
	}

	/*
	 * Loop through section headers, reading in each piece at the
	 * specified virtual address.
	 */
	for (i = 0; i < FileHdr.NumberOfSections; ++i) {
		hdr = &SecHdr[i];
		debug(VRDBG_PE, "Processing section %d: %s\n", i, hdr->Name);
		hdr->SizeOfRawData = LE32BE(hdr->SizeOfRawData);
		if (hdr->SizeOfRawData == 0) {
			continue;
		}
		hdr->PointerToRawData = LE32BE(hdr->PointerToRawData);
		if (OFSeek(bootih, 0, hdr->PointerToRawData) == -1) {
			fatal("seek to offset %x failed\n",
			    hdr->PointerToRawData);
		}
		hdr->VirtualAddress = LE32BE(hdr->VirtualAddress);
		debug(VRDBG_MAIN, "Addr: %s=%x\n", hdr->Name, hdr->VirtualAddress);
		res = OFRead(bootih,
		    (PCHAR) hdr->VirtualAddress + (ULONG) BaseAddr,
		    hdr->SizeOfRawData);
		if ((ULONG)res != hdr->SizeOfRawData) {
			fatal("Couldn't read data: exp %x got %x\n",
			    hdr->SizeOfRawData, res);
		}
	}
	free((char *)SecHdr);

	OptHdr.AddressOfEntryPoint = LE32BE(OptHdr.AddressOfEntryPoint);
	debug(VRDBG_MAIN, "POE: %x\n", OptHdr.AddressOfEntryPoint);
	debug(VRDBG_MAIN, "*POE: %x\n", LE32BE(*((unsigned int*)(BaseAddr + OptHdr.AddressOfEntryPoint))));
	return (void *)(BaseAddr + OptHdr.AddressOfEntryPoint);
	// TODO: rndtrash: wtf???
	//return (void *)LE32BE(*((unsigned int*)(BaseAddr + OptHdr.AddressOfEntryPoint)));
}

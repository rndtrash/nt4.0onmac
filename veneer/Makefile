.PHONY: clean

MAJORCOMP := ntos
MINORCOMP := bldr

TARGETNAME := veneer
TARGETPATH := obj
TARGETTYPE := LIBRARY

VENEER_VERSION := 0x0
VENEER_REVISION := 0x9909

C_DEFINES := $(C_DEFINES) -D_NTSYSTEM_ -Dppc=1 -D$(CPU)=1 -D_$(CPU)_=1 -DVENEER_VERSION=$(VENEER_VERSION) -DVENEER_REVISION=$(VENEER_REVISION)

# INCLUDES=..\..\inc
#INCLUDES := $(BASEDIR)/ntos_inc

#!IFDEF DDKBUILDENV
#INCLUDES=$(BASEDIR)\SRC\HAL\INC
#!ENDIF

# CFLAGS := /W3 /Oxs /Zd -ZB64

#C_DEFINES=$(C_DEFINES) -DBUILTBY=$(BUILTBY)

#SOURCES :=

#
# Copyright (c) 1995 FirePower Systems, Inc.
#
# $RCSfile: sources $
# $Revision: 1.4 $
# $Date: 1996/01/11 07:54:58 $
# $Locker:  $
#

SOURCES_C :=\
	vrmain.c    \
	vrconfig.c  \
	vrcons.c    \
	vrcpiwrp.c  \
	vrdumptr.c  \
	vrenv.c     \
	vrio.c      \
	vrdisp.c    \
	vrlib.c     \
	vrmalloc.c  \
	vrmemory.c  \
	vrload.c    \
	vrrstart.c  \
	vrmisc.c    \
	vrpehdr.c   \
	vrsup.c     \
	vrtree.c    \
	verno.c

SOURCES_AS :=\
    vrstart.s   \
    vrmp.s      \
    pxcache.s   \
    pxutil.s    \
    ofwmagic.s

OBJECTS := $(SOURCES_C:%.c=bin/%.c.o) $(SOURCES_AS:%.s=bin/%.s.o)

#NTTARGETFILES=obj\*\veneer.exe
#
# Copyright (c) 1995,1996 FirePower Systems, Inc.
#
# $RCSfile: makefile.inc $
# $Revision: 1.9 $
# $Date: 1996/07/02 20:32:24 $
# $Locker:  $
#

#!IFNDEF LANGUAGE
LANGUAGE := usa
#!ENDIF

#!IFDEF NotNow
#msg.rc msg.h msg00001.bin: msg.$(LANGUAGE)
#    mc -v msg.$(LANGUAGE)
#!ENDIF

#!IF $(PPC)

#!IFDEF NotNow
#obj\$(TARGET_DIRECTORY)\veneer.res: msg.$(LANGUAGE)
#!ENDIF

#!IFNDEF DDKBUILDENV

VENEER := obj/$(TARGET_DIRECTORY)/veneer.lib

#obj/$(TARGET_DIRECTORY)/veneer.exe: $(VENEER) makefile.inc
#    -link -out:obj\$(TARGET_DIRECTORY)\veneer.exe -nodefaultlib @<<
#-machine:$(TARGET_DIRECTORY)
#-rom
#-BASE:0x50000
#-debug:notmapped
#-debugtype:coff
#-map:obj\$(TARGET_DIRECTORY)\veneer.map
#-align:0x200
#-entry:start
#obj\$(TARGET_DIRECTORY)\veneer.lib
#$(BASEDIR)\public\sdk\lib\$(TARGET_DIRECTORY)\int64.lib
#<<NOKEEP


#    -@binplace obj\$(TARGET_DIRECTORY)\veneer.exe

#!ELSE
#
# This is for building within a DDK environment...
#
#VENEER=$(BASEDIR)/lib/$(CPU)/$(DDKBUILDENV)/veneer.lib

#$(TARGETPATH)\$(TARGET_DIRECTORY)\veneer.exe: $(VENEER) makefile.inc
#	-link -out:$(TARGETPATH)\$(TARGET_DIRECTORY)\veneer.exe -nodefaultlib -machine:ppc -rom -BASE:0x50000 -debug:notmapped -debugtype:coff -map:obj\ppc\veneer.map -align:0x200 -entry:start $(VENEER) $(BASEDIR)\lib\$(TARGET_DIRECTORY)\$(DDKBUILDENV)\int64.lib
#	-@binplace -d .. $(TARGETPATH)\$(TARGET_DIRECTORY)\veneer.exe

#$(VENEER): obj\$(CPU)\$(DDKBUILDENV)\veneer.lib
#	-copy obj\$(CPU)\$(DDKBUILDENV)\veneer.lib $(VENEER)

#!ENDIF # End of else clause covering ddk build environment case

#verno.c: $(MAIN_PPC_SOURCES)

#!ENDIF # End of IF $(PPC) clause

# TODO: not sure why 0x50000
RELOC := 50000

CFLAGS := -target powerpc-none-eabi -static -msoft-float -ffreestanding -nostdlib $(C_DEFINES) -I$(BASEDIR)/public_sdk_inc -I$(BASEDIR)/private_ntos_inc
ASINCLUDEDIRS := $(BASEDIR)/public_sdk_inc
ASINCLUDE := $(ASINCLUDEDIRS:%=-I%)
ASFLAGS := $(ASINCLUDE) -filetype=obj --arch=ppc32
# TODO: might need to be aligned by 0x200
LDFLAGS := -N --Bstatic -nostdlib -e start -Ttext ${RELOC} -v

all: bin/veneer.elf

bin/veneer.elf: $(OBJECTS)
	ld.lld $(OBJECTS) $(LDFLAGS) -o bin/veneer.elf

bin/%.c.o: %.c Makefile
	clang $< $(CFLAGS) -c -o $@

bin/%.s.preproc: %.s Makefile
	cpp -P $< $(ASINCLUDE) -o $@

bin/%.s.o: bin/%.s.preproc Makefile
	llvm-mc $< $(ASFLAGS) -o $@
	#cpp -P $< $(ASFLAGS) | powerpc-linux-gnu-as $(ASFLAGS) -o $@
	#powerpc-linux-gnu-as $< $(ASFLAGS) -o $@

clean:
	rm -f bin/*.s.preproc
	rm -f bin/*.o

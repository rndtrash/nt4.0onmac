CPU := PPC
BASEDIR := $(shell pwd)
C_DEFINES := -D_M_PPC=1

export

.PHONY: clean qemu veneer

all: veneer/bin/veneer.elf

veneer/bin/veneer.elf: veneer

veneer:
	make -C veneer

clean:
	make -C veneer clean
	rm -f bin/*.o

qemu:
	# TODO:
	# qemu-system-ppc -L openbios-ppc -boot d -M mac99 -m 256 -cdrom bin/hellorld.iso -device VGA,edid=on
	qemu-system-ppc -L openbios-ppc -boot d -M mac99 -m 256 -device VGA,edid=on

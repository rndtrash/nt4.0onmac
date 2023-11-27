CPU := PPC
BASEDIR := $(shell pwd)
C_DEFINES := -D_M_PPC=1

export

.PHONY: clean qemu veneer

all: bin/nt4.0.iso

bin/nt4.0.iso: veneer/bin/veneer.elf
	mkdir -p ./dmg_mount/ppc
	cp veneer/bin/veneer.elf ./dmg_mount/ppc
	genisoimage \
		-joliet-long -r \
		-V 'Windows NT' \
		-o bin/nt4.0.iso \
		--iso-level 4 \
		--netatalk -hfs -probe \
		-map hfs.map \
		-hfs-parms MAX_XTCSIZE=2656248 \
		--chrp-boot \
		-part -no-desktop \
		-hfs-bless ppc \
		-hfs-volid WinNT_boot \
		./dmg_mount/

veneer/bin/veneer.elf: veneer

veneer:
	make -C veneer

clean:
	make -C veneer clean
	rm -f bin/*.iso
	rm -f bin/*.o

qemu: bin/nt4.0.iso
	qemu-system-ppc -L openbios-ppc -boot d -M mac99 -m 2048 -cdrom bin/nt4.0.iso -device VGA,edid=on

# Windows NT 4.0 on PowerPC Macs

This repository contains a lot of leaked Windows NT 4.0 source code. By reading it, you lose the right to contribute to ReactOS. Oh, well.

This is an attempt at running the Windows NT 4.0 kernel on a PowerPC Apple computers.

## TODO

- [x] veneer.elf "works" on QEMU
- [ ] veneer.elf works on a real Mac (it crashes on my iBook G3 Dual USB)
- [ ] veneer.elf boots the NT kernel on QEMU (no, it doesn't, it crashes after
jumping at `0x80600000`)

## Building

This project uses clang for compiling and QEMU for emulation.

 1. Make these folders: `dmg_mount/os/winnt`, then copy the `SETUPLDR` file from a Windows NT 4.0 Service Pack 1 CD and rename it to `osloader.exe`
 2. Run `make`
 3. Run `make` again, I screwed up somewhere, and you need to run Makefile twice in order to generate an ISO
 4. Run `make qemu`, then type in `boot cd:,\ppc\veneer.elf`

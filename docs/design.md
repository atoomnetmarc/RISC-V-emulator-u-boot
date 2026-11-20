# Design

## Boot chain

The emulator starts in M-mode at `0x80000000` and loads OpenSBI `fw_jump.bin` at `0x80000000`. OpenSBI jumps to U-Boot at `0x80400000`. U-Boot loads the Linux `Image` and the DTB from the boot partition on the virtio disk and starts the kernel with `booti`.

The load address `0x80400000` is U-Boot's `TEXT_BASE` for RV32 S-mode and OpenSBI's `FW_JUMP_OFFSET=0x400000` target. The U-Boot stack at `0x80200000` stays clear of the text, and the prebuilt OpenSBI ends at `0x80042330`.

## Memory map

| Region | Address | Notes |
| --- | --- | --- |
| OpenSBI | `0x80000000` | `fw_jump.bin`, ends at `0x80042330` |
| U-Boot | `0x80400000` | `TEXT_BASE` |
| Linux `Image` | `0x80600000` | `kernel_addr_r` |
| DTB | `0x81b00000` | `fdt_addr_r` |
| ramdisk | `0x81c00000` | `ramdisk_addr_r` |
| U-Boot stack | `0x81e8a000` | relocated, grows down |
| RAM end | `0x84000000` | 64 MiB |

The QEMU defaults `kernel_addr_r=0x84000000` and `fdt_addr_r=0x8c000000` are outside the 64 MiB RAM, so the default environment sets the three addresses. The addresses stay below the relocated U-Boot stack at `0x81e8a000`; the pre-relocation stack at `0x80200000` is not the limit.

## Disk layout

The disk is a GPT image with a boot partition and a rootfs partition. The boot partition holds the Linux `Image` and the DTB; the rootfs partition holds the Buildroot root. The 21 MB `Image` does not fit the 16 MB rootfs, so it has a partition of its own.

## RAM size

The emulator `-M <size>` option is deferred. The first boot uses the fixed 64 MiB RAM and the current DTS.

## ISA

U-Boot builds with `rv32ima_zicsr_zifencei`. C, F and D are off. The emulator has I, M, A, C, Zicsr, Zifencei and Zicntr; U-Boot does not need the rest.

A is required: `arch/riscv/cpu/start.S` uses `amoswap.w` for the hart lottery and the available-harts lock. `CONFIG_RISCV_ISA_A` adds `a` to the `-march` in `arch/riscv/Makefile`.

## Debug UART

`CONFIG_DEBUG_UART=y` with the ns16550 driver at `0x10000000` and a 16 MHz clock. The S-mode default is the SBI console, so the fragment selects `CONFIG_DEBUG_UART_NS16550` explicitly. `CONFIG_DEBUG_UART_ANNOUNCE=y` prints `<debug_uart>` when the early UART is ready, before the driver model serial is up.

## Environment

`CONFIG_ENV_IS_NOWHERE=y`. The disk is a Buildroot product, so a saved environment disappears on the next build. The compiled-in environment is the configuration.

## Boot commands

`CONFIG_BOOTCOMMAND` carries the boot and `CONFIG_ENV_SOURCE_FILE` points to `configs/riscv-emulator.env`, which the wrapper copies into the board directory. The `.env` file sets `kernel_addr_r=0x80600000`, `fdt_addr_r=0x81b00000` and `ramdisk_addr_r=0x81c00000`. The boot command `ext4load`s the `Image` and the DTB from the boot partition and runs `booti ${kernel_addr_r} - ${fdt_addr_r}`. The `bootargs` live in the DTB `/chosen/bootargs`; the boot command leaves `bootargs` unset, so U-Boot does not overwrite the DTB value.

## Container

The wrapper extends `riscv-emulator-tools-container`. The base image provides the xPack `riscv-none-elf-gcc`; the wrapper adds the U-Boot host tools and the Linux-targeting linker. `CONFIG_TOOLS_LIBCRYPTO=n` and `CONFIG_TOOLS_KWBIMAGE=n` remove the OpenSSL dependency. The Makefile is the native U-Boot interface and the container is an implementation detail.

## Toolchain

U-Boot compiles with the xPack `riscv64-unknown-elf-gcc` from the base image, which has the rv32 `libgcc`. The xPack linker has no `-pie` or `-shared` support, and U-Boot links with both, so `LD=riscv64-linux-gnu-ld` from the wrapper image does the link step. The Linux linker accepts `-m elf32lriscv` and finds the rv32 `libgcc` through the `-L` path that U-Boot derives from `CC`.

## Upstream

U-Boot `v2026.10` is fetched into the shared cache at commit `5508406582f6f7120dce0c4b3059819a41788db2`. The wrapper Makefile records the tag and the exact upstream commit; the source is not part of either repository.

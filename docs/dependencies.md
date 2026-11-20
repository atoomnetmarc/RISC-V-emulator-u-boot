# Dependencies

The build image is `riscv-emulator-tools-container`. It provides the ACT runtime, the bare-metal RISC-V toolchain and the U-Boot host tools.

| Package | Needed by | Why |
| --- | --- | --- |
| `riscv-none-elf-gcc` (xPack) | ACT, U-Boot | bare-metal RISC-V compiler; the ACT configs use the `riscv64-unknown-elf-*` symlinks |
| `make`, `python3`, `git` | ACT, U-Boot | build and scripts |
| `ruby`, `nodejs`, `npm`, `z3` | ACT | UDB gems and the Sail model |
| `sail-riscv` c_emulator | ACT | reference model |
| `build-essential` | U-Boot | `HOSTCC` for `mkimage`, `dtc` and the other host tools |
| `bison`, `flex` | U-Boot | Kconfig and the device tree compiler |
| `device-tree-compiler` | U-Boot | `dtc` for the U-Boot DTB build |
| `swig` | U-Boot | host tool bindings |
| `gcc-riscv64-linux-gnu` | U-Boot, OpenSBI | `riscv64-linux-gnu-ld` links with `-pie` and `-shared`; the xPack linker has neither |

`CONFIG_TOOLS_LIBCRYPTO=n` and `CONFIG_TOOLS_KWBIMAGE=n` keep the OpenSSL dependency out of the host tools, so the tools container has no `libssl-dev`.

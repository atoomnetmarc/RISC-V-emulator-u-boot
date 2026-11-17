# Dependencies

The container image is layered. The base image is `riscv-emulator-tools-container`; the wrapper image adds the U-Boot host tools.

## Base image

| Package | Needed by | Why |
| --- | --- | --- |
| `riscv-none-elf-gcc` (xPack) | ACT, U-Boot | bare-metal RISC-V compiler; the ACT configs use the `riscv64-unknown-elf-*` symlinks |
| `make`, `python3`, `git` | ACT, U-Boot | build and scripts |
| `ruby`, `nodejs`, `npm`, `z3` | ACT | UDB gems and the Sail model |
| `sail-riscv` c_emulator | ACT | reference model |

## Wrapper image

| Package | Needed by | Why |
| --- | --- | --- |
| `build-essential` | U-Boot | `HOSTCC` for `mkimage`, `dtc` and the other host tools |
| `bison`, `flex` | U-Boot | Kconfig and the device tree compiler |
| `device-tree-compiler` | U-Boot | `dtc` for the U-Boot DTB build |
| `swig` | U-Boot | host tool bindings |
| `gcc-riscv64-linux-gnu` | U-Boot | `riscv64-linux-gnu-ld` links with `-pie` and `-shared`; the xPack linker has neither |

`CONFIG_TOOLS_LIBCRYPTO=n` and `CONFIG_TOOLS_KWBIMAGE=n` remove the OpenSSL dependency from the host tools, so the wrapper image does not install `libssl-dev`.

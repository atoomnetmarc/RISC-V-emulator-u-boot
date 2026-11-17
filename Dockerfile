ARG BASE_IMAGE=riscv-emulator-tools-container:latest
FROM ${BASE_IMAGE}

# U-Boot host tools and the RISC-V cross toolchain. U-Boot links with -pie and
# builds EFI shared objects, which the xPack bare-metal linker in the base
# image does not support. The Linux-targeting toolchain does.
# CONFIG_TOOLS_LIBCRYPTO=n removes the OpenSSL dependency.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential bison flex device-tree-compiler swig xxd \
      gcc-riscv64-linux-gnu \
 && rm -rf /var/lib/apt/lists/*

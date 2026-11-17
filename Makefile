# U-Boot build wrapper. The container is the build environment; the source
# stays on the host.

IMAGE         ?= riscv-emulator-u-boot
BASE_IMAGE    ?= riscv-emulator-tools-container:latest
UBOOT_DIR     := u-boot
DEFCONFIG     ?= qemu-riscv32_smode_defconfig
FRAGMENT      := configs/uboot-fragment.config
ENV_SOURCE    := configs/riscv-emulator.env
ENV_TARGET    := $(UBOOT_DIR)/board/emulation/qemu-riscv/riscv-emulator.env
CROSS_COMPILE ?= riscv64-unknown-elf-
# The xPack bare-metal linker has no -pie or -shared support. U-Boot links
# with both, so the Linux-targeting linker does the link step. LD is a make
# built-in (ld), so it needs := rather than ?=.
LD            := riscv64-linux-gnu-ld
JOBS          ?= $(shell nproc)

SRC   := /src
BUILD := $(SRC)/build
STAMP := build/.image

# Rootless podman maps container root to the host user, so no --user is needed.
DOCKER ?= podman
RUN    := $(DOCKER) run --rm -v $(CURDIR):$(SRC) -w $(SRC)

.PHONY: all image defconfig build clean distclean

all: build

image: $(STAMP)

$(STAMP): Dockerfile
	$(DOCKER) build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(IMAGE) .
	@mkdir -p build
	@touch $@

$(ENV_TARGET): $(ENV_SOURCE)
	cp $< $@

defconfig: $(STAMP) $(ENV_TARGET)
	$(RUN) $(IMAGE) sh -c 'cd $(UBOOT_DIR) && make O=$(BUILD) $(DEFCONFIG) && scripts/kconfig/merge_config.sh -m -O $(BUILD) $(BUILD)/.config $(SRC)/$(FRAGMENT) && make O=$(BUILD) olddefconfig'

build: defconfig
	$(RUN) $(IMAGE) make -C $(UBOOT_DIR) O=$(BUILD) -j$(JOBS) CROSS_COMPILE=$(CROSS_COMPILE) LD=$(LD)

clean:
	rm -rf build
	rm -f $(ENV_TARGET)

distclean: clean
	-$(DOCKER) image rm $(IMAGE)

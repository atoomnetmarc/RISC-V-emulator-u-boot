# U-Boot build wrapper. The container is the build environment; the pinned
# source lives in the shared cache outside both repositories.

IMAGE         ?= riscv-emulator-u-boot
BASE_IMAGE    ?= riscv-emulator-tools-container:latest
UBOOT_VERSION ?= v2026.10
UBOOT_COMMIT  ?= 5508406582f6f7120dce0c4b3059819a41788db2
XDG_CACHE_HOME ?= $(HOME)/.cache
CACHE         := $(XDG_CACHE_HOME)/riscv-emulator
UBOOT_SRC     := $(CACHE)/u-boot-$(UBOOT_VERSION)
DEFCONFIG     ?= qemu-riscv32_smode_defconfig
FRAGMENT      := configs/uboot-fragment.config
ENV_FILE      := /src/configs/riscv-emulator.env
CROSS_COMPILE ?= riscv64-unknown-elf-
LD            := riscv64-linux-gnu-ld
JOBS          ?= $(shell nproc)

SRC       := /src
UBOOT_MNT := /u-boot-src
BUILD     := $(SRC)/build
STAMP     := build/.image

DOCKER ?= podman
RUN    := $(DOCKER) run --rm -v $(CURDIR):$(SRC) -v $(UBOOT_SRC):$(UBOOT_MNT) -w $(SRC)

.PHONY: all image fetch defconfig build clean distclean purge-cache

all: build

image: $(STAMP)

$(STAMP): Dockerfile
	$(DOCKER) build --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(IMAGE) .
	@mkdir -p build
	@touch $@

$(UBOOT_SRC)/Makefile:
	mkdir -p $(CACHE)
	git clone --depth 1 --branch $(UBOOT_VERSION) \
		https://git.u-boot-project.org/u-boot/u-boot.git $(UBOOT_SRC)
	@test "$$(git -C $(UBOOT_SRC) rev-parse HEAD)" = "$(UBOOT_COMMIT)" || { \
		echo "U-Boot tag $(UBOOT_VERSION) does not match pinned commit"; exit 1; \
	}

fetch: $(UBOOT_SRC)/Makefile

defconfig: $(STAMP) fetch
	$(RUN) $(IMAGE) sh -c 'cd $(UBOOT_MNT) && make O=$(BUILD) $(DEFCONFIG) && scripts/kconfig/merge_config.sh -m -O $(BUILD) $(BUILD)/.config $(SRC)/$(FRAGMENT) && make O=$(BUILD) ENV_FILE=$(ENV_FILE) olddefconfig'

build: defconfig
	$(RUN) $(IMAGE) make -C $(UBOOT_MNT) O=$(BUILD) -j$(JOBS) ENV_FILE=$(ENV_FILE) CROSS_COMPILE=$(CROSS_COMPILE) LD=$(LD)

clean:
	rm -rf build

distclean: clean
	-$(DOCKER) image rm $(IMAGE)

purge-cache:
	rm -rf $(UBOOT_SRC)

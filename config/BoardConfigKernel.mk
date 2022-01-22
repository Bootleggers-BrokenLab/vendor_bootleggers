# Copyright (C) 2018-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Kernel build configuration variables
# ====================================
#
# These config vars are usually set in BoardConfig.mk:
#
#   TARGET_KERNEL_SOURCE               = Kernel source dir, optional, defaults
#                                          to kernel/$(TARGET_DEVICE_DIR)
#   TARGET_KERNEL_ADDITIONAL_FLAGS     = Additional make flags, optional
#   TARGET_KERNEL_ARCH                 = Kernel Arch
#   TARGET_KERNEL_CROSS_COMPILE_PREFIX = Compiler prefix (e.g. arm-eabi-)
#                                          defaults to arm-linux-androidkernel- for arm
#                                                      aarch64-linux-android- for arm64
#   TARGET_KERNEL_CROSS_COMPILE_PREFIX_ARM32 = Compiler prefix for building vDSO32
#   						defaults to arm-linux-androidkernel-
#
#   TARGET_KERNEL_CLANG_COMPILE        = Compile kernel with clang, defaults to false
#
#   KERNEL_TOOLCHAIN_PREFIX            = Overrides TARGET_KERNEL_CROSS_COMPILE_PREFIX,
#                                          Set this var in shell to override
#                                          toolchain specified in BoardConfig.mk
#   KERNEL_TOOLCHAIN                   = Path to toolchain, if unset, assumes
#                                          TARGET_KERNEL_CROSS_COMPILE_PREFIX
#                                          is in PATH
#   USE_CCACHE                         = Enable ccache (global Android flag)

BUILD_TOP := $(shell pwd)

TARGET_AUTO_KDIR := $(shell echo $(TARGET_DEVICE_DIR) | sed -e 's/^device/kernel/g')
TARGET_KERNEL_SOURCE ?= $(TARGET_AUTO_KDIR)
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_KERNEL_SOURCE :=
endif

TARGET_KERNEL_ARCH := $(strip $(TARGET_KERNEL_ARCH))
ifeq ($(TARGET_KERNEL_ARCH),)
KERNEL_ARCH := $(TARGET_ARCH)
else
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)
endif

ifneq ($(TARGET_CLANG_PREBUILTS_VERSION),)
    ifeq ($(TARGET_CLANG_PREBUILTS_VERSION),latest)
        # Set the latest version of clang
        CLANG_PREBUILTS_VERSION := $(shell ls -d $(BUILD_TOP)/prebuilts/clang/host/$(HOST_OS)-x86/clang-r* | xargs -n 1 basename | tail -1)
    else
        # Find the clang-* directory containing the specified version
        CLANG_PREBUILTS_VERSION := clang-$(TARGET_CLANG_PREBUILTS_VERSION)
    endif
else
    # Use the default version of clang if TARGET_CLANG_PREBUILTS_VERSION hasn't been set by the device config
    CLANG_PREBUILTS_VERSION := clang-r416183b1
endif

CLANG_PREBUILTS := $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/$(CLANG_PREBUILTS_VERSION)
GCC_PREBUILTS := $(BUILD_TOP)/prebuilts/gcc/$(HOST_OS)-x86
# arm64 toolchain
KERNEL_TOOLCHAIN_arm64 := $(GCC_PREBUILTS)/aarch64/aarch64-linux-android-4.9/bin
KERNEL_TOOLCHAIN_PREFIX_arm64 := aarch64-linux-android-
# arm toolchain
KERNEL_TOOLCHAIN_arm := $(GCC_PREBUILTS)/arm/arm-linux-androideabi-4.9/bin
KERNEL_TOOLCHAIN_PREFIX_arm := arm-linux-androidkernel-

TARGET_KERNEL_CROSS_COMPILE_PREFIX := $(strip $(TARGET_KERNEL_CROSS_COMPILE_PREFIX))
ifneq ($(TARGET_KERNEL_CROSS_COMPILE_PREFIX),)
KERNEL_TOOLCHAIN_PREFIX ?= $(TARGET_KERNEL_CROSS_COMPILE_PREFIX)
else
KERNEL_TOOLCHAIN ?= $(KERNEL_TOOLCHAIN_$(KERNEL_ARCH))
KERNEL_TOOLCHAIN_PREFIX ?= $(KERNEL_TOOLCHAIN_PREFIX_$(KERNEL_ARCH))
endif

TARGET_KERNEL_CROSS_COMPILE_PREFIX_ARM32 := $(strip $(TARGET_KERNEL_CROSS_COMPILE_PREFIX_ARM32))
ifneq ($(TARGET_KERNEL_CROSS_COMPILE_PREFIX_ARM32),)
KERNEL_TOOLCHAIN_PREFIX_ARM32 ?= $(TARGET_KERNEL_CROSS_COMPILE_PREFIX_ARM32)
else
KERNEL_TOOLCHAIN_ARM32 ?= $(KERNEL_TOOLCHAIN_arm)
KERNEL_TOOLCHAIN_PREFIX_ARM32 ?= $(KERNEL_TOOLCHAIN_PREFIX_arm)
endif

ifeq ($(KERNEL_TOOLCHAIN),)
KERNEL_TOOLCHAIN_PATH := $(KERNEL_TOOLCHAIN_PREFIX)
else
KERNEL_TOOLCHAIN_PATH := $(KERNEL_TOOLCHAIN)/$(KERNEL_TOOLCHAIN_PREFIX)
endif

ifeq ($(KERNEL_TOOLCHAIN_ARM32),)
KERNEL_TOOLCHAIN_PATH_ARM32 := $(KERNEL_TOOLCHAIN_PREFIX_ARM32)
else
KERNEL_TOOLCHAIN_PATH_ARM32 := $(KERNEL_TOOLCHAIN_ARM32)/$(KERNEL_TOOLCHAIN_PREFIX_ARM32)
endif

# We need to add GCC toolchain to the path no matter what
# for tools like `as`
KERNEL_TOOLCHAIN_PATH_gcc := $(KERNEL_TOOLCHAIN_$(KERNEL_ARCH))

ifneq ($(USE_CCACHE),)
    ifneq ($(CCACHE_EXEC),)
        # Android 10+ deprecates use of a build ccache. Only system installed ones are now allowed
        CCACHE_BIN := $(CCACHE_EXEC)
    endif
endif

ifeq ($(TARGET_KERNEL_CLANG_COMPILE),true)
    KERNEL_CROSS_COMPILE := CROSS_COMPILE="$(KERNEL_TOOLCHAIN_PATH)"
else
    KERNEL_CROSS_COMPILE := CROSS_COMPILE="$(CCACHE_BIN) $(KERNEL_TOOLCHAIN_PATH)"
endif

# Needed for CONFIG_COMPAT_VDSO, safe to set for all arm64 builds
ifeq ($(KERNEL_ARCH),arm64)
    KERNEL_CROSS_COMPILE += CROSS_COMPILE_ARM32="$(KERNEL_TOOLCHAIN_PATH_ARM32)"
    KERNEL_CROSS_COMPILE += CROSS_COMPILE_COMPAT="$(KERNEL_TOOLCHAIN_PATH_ARM32)"
endif

# Clear this first to prevent accidental poisoning from env
KERNEL_MAKE_FLAGS :=

# Add back threads, ninja cuts this to $(nproc)/2
KERNEL_MAKE_FLAGS += -j$(shell nproc --all)

ifeq ($(KERNEL_ARCH),arm)
  # Avoid "Unknown symbol _GLOBAL_OFFSET_TABLE_" errors
  KERNEL_MAKE_FLAGS += CFLAGS_MODULE="-fno-pic"
endif

ifeq ($(KERNEL_ARCH),arm64)
  # Avoid "unsupported RELA relocation: 311" errors (R_AARCH64_ADR_GOT_PAGE)
  KERNEL_MAKE_FLAGS += CFLAGS_MODULE="-fno-pic"
endif

ifeq ($(HOST_OS),darwin)
  KERNEL_MAKE_FLAGS += HOSTCFLAGS="-I$(BUILD_TOP)/external/elfutils/libelf -I/usr/local/opt/openssl/include -fuse-ld=lld" HOSTLDFLAGS="-L/usr/local/opt/openssl/lib -fuse-ld=lld"
else
  KERNEL_MAKE_FLAGS += CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTCFLAGS="-fuse-ld=lld" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld"
endif

ifneq ($(TARGET_KERNEL_ADDITIONAL_FLAGS),)
  KERNEL_MAKE_FLAGS += $(TARGET_KERNEL_ADDITIONAL_FLAGS)
endif

TOOLS_PATH_OVERRIDE := \
    PATH=$(BUILD_TOP)/prebuilts/tools-bootleg/$(HOST_OS)-x86/bin:$$PATH \
    LD_LIBRARY_PATH=$(BUILD_TOP)/prebuilts/tools-bootleg/$(HOST_OS)-x86/lib:$$LD_LIBRARY_PATH \
    PERL5LIB=$(BUILD_TOP)/prebuilts/tools-bootleg/common/perl-base

# Set DTBO image locations so the build system knows to build them
ifeq (true,$(filter true, $(TARGET_NEEDS_DTBOIMAGE) $(BOARD_KERNEL_SEPARATED_DTBO)))
BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ/arch/$(KERNEL_ARCH)/boot/dtbo.img
endif

# Set use the full path to the make command
KERNEL_MAKE_CMD := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_OS)-x86/bin/make

# Set the full path to the clang command
KERNEL_MAKE_FLAGS += HOSTCC=$(CLANG_PREBUILTS)/bin/clang
KERNEL_MAKE_FLAGS += HOSTCXX=$(CLANG_PREBUILTS)/bin/clang++
KERNEL_MAKE_FLAGS += HOSTAR=$(CLANG_PREBUILTS)/bin/llvm-ar
KERNEL_MAKE_FLAGS += HOSTLD=$(CLANG_PREBUILTS)/bin/ld.lld

# Since Linux 4.16, flex and bison are required
ifeq ($(TARGET_NEEDS_PREBUILT_FLEX_BISON), true)
KERNEL_MAKE_FLAGS += LEX=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_OS)-x86/bin/flex
KERNEL_MAKE_FLAGS += YACC=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_OS)-x86/bin/bison
TOOLS_PATH_OVERRIDE += BISON_PKGDATADIR=$(BUILD_TOP)/prebuilts/build-tools/common/bison
endif

KERNEL_MAKE_FLAGS += M4=$(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/m4

# Set the out dir for the kernel's O= arg
# This needs to be an absolute path, so only set this if the standard out dir isn't used
OUT_DIR_PREFIX := $(shell echo $(OUT_DIR) | sed -e 's|/target/.*$$||g')
KERNEL_BUILD_OUT_PREFIX :=
ifeq ($(OUT_DIR_PREFIX),out)
KERNEL_BUILD_OUT_PREFIX := $(BUILD_TOP)/
endif

# Copyright (C) 2020 BOOTLEGGERS
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

# Versioning System
BUILD_DATE := $(shell date +%Y%m%d)
TARGET_PRODUCT_SHORT := $(subst bootleggers_,,$(BOOTLEGGERS_BUILD))

BOOTLEGGERS_BUILDTYPE ?= HOMEMADE
BOOTLEGGERS_BUILD_VERSION := $(PLATFORM_VERSION)
BOOTLEGGERS_VERSION := $(BOOTLEGGERS_BUILD_VERSION)-$(BOOTLEGGERS_BUILDTYPE)-$(TARGET_PRODUCT_SHORT)-$(BUILD_DATE)
ROM_FINGERPRINT := BOOTLEGGERS/$(PLATFORM_VERSION)/$(TARGET_PRODUCT_SHORT)/$(shell date -u +%H%M)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
  ro.bootleggers.build.version=$(BOOTLEGGERS_BUILD_VERSION) \
  ro.bootleggers.build.date=$(BUILD_DATE) \
  ro.bootleggers.buildtype=$(BOOTLEGGERS_BUILDTYPE) \
  ro.bootleggers.fingerprint=$(ROM_FINGERPRINT) \
  ro.bootleggers.version=$(BOOTLEGGERS_VERSION) \
  ro.bootleggers.device=$(BOOTLEGGERS_BUILD) \
  ro.modversion=$(BOOTLEGGERS_VERSION)

# Signing
ifneq (eng,$(TARGET_BUILD_VARIANT))
ifneq (,$(wildcard vendor/bootleggers/signing/keys/releasekey.pk8))
PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/bootleggers/signing/keys/releasekey
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.oem_unlock_supported=1
endif
ifneq (,$(wildcard vendor/bootleggers/signing/keys/otakey.x509.pem))
PRODUCT_OTA_PUBLIC_KEYS := vendor/bootleggers/signing/keys/otakey.x509.pem
endif
endif

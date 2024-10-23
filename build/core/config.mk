
# Copyright (C) 2018 BOOTLEGGERS
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

# We modify several neverallows, so let the build proceed
ifeq ($(TARGET_BUILD_VARIANT),eng)
SELINUX_IGNORE_NEVERALLOWS := true
endif

# Rules for QCOM targets
include $(TOPDIR)vendor/bootleggers/build/core/qcom_target.mk

BUILD_RRO_SYSTEM_PACKAGE := $(TOP)/vendor/bootleggers/build/core/system_rro.mk

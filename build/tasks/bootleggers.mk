BOOTLEGGERS_TARGET_PACKAGE := $(PRODUCT_OUT)/BOOTLEGGERS-$(BOOTLEGGERS_VERSION).zip
SHA256 := prebuilts/build-tools/path/$(HOST_PREBUILT_TAG)/sha256sum

.PHONY: otapackage bootleggers bacon
otapackage: $(INTERNAL_OTA_PACKAGE_TARGET)
bootleggers: otapackage
	$(hide) mv $(INTERNAL_OTA_PACKAGE_TARGET) $(BOOTLEGGERS_TARGET_PACKAGE)
	$(hide) $(SHA256) $(BOOTLEGGERS_TARGET_PACKAGE) | cut -d ' ' -f1 > $(BOOTLEGGERS_TARGET_PACKAGE).sha256sum
	$(hide) source ./vendor/bootleggers/tools/generate_json_build_info.sh $(BOOTLEGGERS_TARGET_PACKAGE)
	@echo -e ""
	@echo -e "${cya}Building ${bldcya}BOOTLEGGERS${txtrst}";
	@echo -e "	:::   :::   :::         :::     :::::::::  "
	@echo -e "	:+:   :+: :+: :+:     :+: :+:   :+:    :+: "
	@echo -e "	 +:+ +:+ +:+   +:+   +:+   +:+  +:+    +:+ "
	@echo -e "	  +#++: +#++:++#++: +#++:++#++: +#++:++#+  "
	@echo -e "	   +#+  +#+     +#+ +#+     +#+ +#+        "
	@echo -e "	   #+#  #+#     #+# #+#     #+# #+#        "
	@echo -e "	   ###  ###     ### ###     ### ###        "
	@echo -e "		Yet Another AOSP Project			   "
	@echo -e ""
	@echo -e "zip: "$(BOOTLEGGERS_TARGET_PACKAGE)
	@echo -e "sha256: `cat $(BOOTLEGGERS_TARGET_PACKAGE).sha256sum | cut -d ' ' -f 1`"
	@echo -e "size: `ls -lah $(BOOTLEGGERS_TARGET_PACKAGE) | cut -d ' ' -f 5`"
	@echo -e ""

bacon: bootleggers

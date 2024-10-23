BOOTLEGGERS_FASTBOOT_PACKAGE := $(PRODUCT_OUT)/BOOTLEGGERS-$(BOOTLEGGERS_VERSION)-img.zip

.PHONY: updatepackage bootleggers-fastboot
updatepackage: $(INTERNAL_UPDATE_PACKAGE_TARGET)
bootleggers-fastboot: updatepackage
	$(hide) mv $(INTERNAL_UPDATE_PACKAGE_TARGET) $(BOOTLEGGERS_FASTBOOT_PACKAGE)
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
	@echo -e "zip: "$(BOOTLEGGERS_FASTBOOT_PACKAGE)
	@echo -e "size: `ls -lah $(BOOTLEGGERS_FASTBOOT_PACKAGE) | cut -d ' ' -f 5`"
	@echo -e ""

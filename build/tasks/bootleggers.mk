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
	@echo -e "        ▄ █ ███████▄▄      ▐██████████████     ████                ▄▄███████▀▄"
	@echo -e " ████████ █ ██████████▄    ▐██████████████▌    ████             ▄██████████████"
	@echo -e "▐█▌▄▄▄▄▄▄ █ ████  ▐███▌          ████          ████            ▄████▀        ▀"
	@echo -e "     ▄███ █ ██████████▄          ████          ████           ▐████"
	@echo -e " ▄██▀▀▐██ █ ████████████▄        ████          ████           ▐███▌       ██████"
	@echo -e "   ▄▄█▀ █ █ ████     ████        ████          ████           ▐████       ▀▀▀███"
	@echo -e " ▀▀  ▄▄█▀ █ ████    ▄████        ████          ████            ▀████▄       ▐███"
	@echo -e "▄▄██▀▀    █ ████████████▀        ████          ████████████     ▀███████████████"
	@echo -e "     ▐▀█▀ █ ████████▀▀▀          ████          ████████████        ▀▀███████▀▀"
	@echo -e ""
	@echo -e "          Bootleggers ROM         "
	@echo -e "          #KeepTheBootleg        "
	@echo -e ""
	@echo -e ""
	@echo -e ""
	@echo -e "The build is done, be sure to get it on:"
	@echo -e "$(BOOTLEGGERS_TARGET_PACKAGE)"
	@echo -e ""
	@echo -e "zip: "$(BOOTLEG_TARGET_PACKAGE)
	@echo -e "size: `ls -lah $(BOOTLEG_TARGET_PACKAGE) | cut -d ' ' -f 5`"
	@echo -e "Also, enjoy your $(BOOTLEGGERS_BUILD_TYPE)build"
	@echo -e ""

bacon: bootleggers

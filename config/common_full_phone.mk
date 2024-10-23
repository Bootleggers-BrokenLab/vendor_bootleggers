# Inherit common stuff
$(call inherit-product, vendor/bootleggers/config/common.mk)

# Sensitive Phone Numbers list
PRODUCT_PACKAGES += \
    sensitive_pn.xml

# World APN list
PRODUCT_PACKAGES += \
    apns-conf.xml

# SIM Toolkit
PRODUCT_PACKAGES += \
    Stk

# Wallet app for Power menu integration
# https://source.android.com/devices/tech/connect/quick-access-wallet
PRODUCT_PACKAGES += \
    QuickAccessWallet

# Enable support of one-handed mode
PRODUCT_PRODUCT_PROPERTIES += \
    ro.support_one_handed_mode=true

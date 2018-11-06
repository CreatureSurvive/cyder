include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = cyderprefs
cyderprefs_FILES = CYPPreferenceController.m
cyderprefs_INSTALL_PATH = /Library/PreferenceBundles
cyderprefs_FRAMEWORKS = UIKit
cyderprefs_PRIVATE_FRAMEWORKS = Preferences
cyderprefs_CFLAGS += -fobjc-arc
cyderprefs_LDFLAGS +=  -lCSPreferences -lCSColorPicker -lCSPUtilities

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/cyderprefs.plist$(ECHO_END)

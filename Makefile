ARCHS = arm64
TARGET = iphone:clang:11.2:latest

DEBUG = 1
GO_EASY_ON_ME = 0
BUILD_EXT = b

ifeq ($(DEBUG), 1)
	BUILDNUMBER = -$(VERSION.INC_BUILD_NUMBER)
	FINALPACKAGE = 0
else
	BUILDNUMBER = 
	FINALPACKAGE = 1
endif

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)$(BUILDNUMBER)$(BUILD_EXT)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = cyder
$(TWEAK_NAME)_FILES = $(wildcard source/*.m source/*/*.m source/*.xm)
$(TWEAK_NAME)_FRAMEWORKS = 
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = 
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = MMMarkdown
$(TWEAK_NAME)_LDFLAGS += -lCSPreferencesProvider -lCSColorPicker -F./layout/Library/Frameworks
$(TWEAK_NAME)_CFLAGS +=  -fobjc-arc -I$(THEOS_PROJECT_DIR)/source

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
SUBPROJECTS += cyderprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

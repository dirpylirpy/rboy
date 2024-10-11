CARGO?=cargo

Q ?= @
CC = arm-none-eabi-gcc
AR = arm-none-eabi-ar
RANLIB = arm-none-eabi-ranlib
NWLINK = npx --yes -- nwlink@0.0.15
LINK_GC = 1
LTO = 1

LIBS_PATH=$(shell pwd)/output/libs

CFLAGS += $(shell $(NWLINK) eadk-cflags)
CFLAGS += -Os
CPPFLAGS += -I$(LIBS_PATH)/include
CFLAGS += -fno-exceptions -fno-unwind-tables

LDFLAGS += --specs=nano.specs
LDFLAGS += -L$(LIBS_PATH)/lib

ifeq ($(LINK_GC),1)
CFLAGS += -fdata-sections -ffunction-sections
LDFLAGS += -Wl,-e,main -Wl,-u,eadk_app_name -Wl,-u,eadk_app_icon -Wl,-u,eadk_api_level
LDFLAGS += -Wl,--gc-sections
endif

ifeq ($(LTO),1)
AR = arm-none-eabi-gcc-ar
RANLIB = arm-none-eabi-gcc-ranlib
CFLAGS += -flto -fno-fat-lto-objects
CFLAGS += -fwhole-program
CFLAGS += -fvisibility=internal
LDFLAGS += -flinker-output=nolto-rel
endif

PACKEDROMS=$(wildcard roms/*.gb.gz)
ROMS=$(PACKEDROMS:.gb.gz=.gb)

.PHONY: release
release:
	$(CARGO) build --release

.PHONY: debug
debug:
	$(CARGO) build

.PHONY: test
test: $(ROMS)
	$(CARGO) test

$(ROMS): %.gb : %.gb.gz
	gunzip -c $< > $@

.PHONY: clean
clean:
	$(CARGO) clean
	$(RM) -r $(ROMS)

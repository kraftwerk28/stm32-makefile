OPENCM3_DIR = libopencm3

SOURCES ?= $(error SOURCES must be set)
BUILD_DIR ?= build
OBJS ?= $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SOURCES))
BIN ?= binary
BIN_ELF ?= $(BUILD_DIR)/$(BIN).elf
BIN_BIN ?= $(BUILD_DIR)/$(BIN).bin
BIN_HEX ?= $(BUILD_DIR)/$(BIN).hex

CFLAGS += -Wall -g -DENABLE_ITM=$(ENABLE_ITM) -Iinclude
LDFLAGS += -static -nostartfiles -specs=nosys.specs -specs=nano.specs -u_printf_float
LDLIBS += -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group

ENABLE_ITM ?= 1

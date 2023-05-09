.PHONY: clean compile-commands

BIN_BIN ?= $(error BIN_BIN must be set)
BIN_ELF ?= $(error BIN_ELF must be set)
BIN_HEX ?= $(error BIN_HEX must be set)

all: $(BIN_BIN) $(BIN_ELF) $(BIN_HEX)

BUILD_DIR ?= $(error BUILD_DIR must be set)

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(BUILD_DIR)
	@printf "  CC      $<\n"
	$(Q)$(CC) $(CFLAGS) $(CPPFLAGS) $(ARCH_FLAGS) -o $@ -c $<

clean:
	$(Q)$(RM) -rfv $(BUILD_DIR)

compile-commands:
	@mkdir -p $(BUILD_DIR)
	bear --output $(BUILD_DIR)/compile_commands.json -- make -B

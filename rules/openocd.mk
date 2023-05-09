FIFO_NAME ?= itm.fifo
TPIU_FREQ ?= $(error TPIU_FREQ must be set)
BIN_ELF ?= $(error BIN_ELF must be set, i.e. build/binary.elf)
OPENOCD_CHIP_CFG ?= $(error OPENOCD_CHIP_CFG must be set)

.PHONY: check-fifo flashdbg flash openocd itmdump eraase gdb

$(FIFO_NAME):
	@if [[ ! -p $(FIFO_NAME) ]]; then mkfifo $(FIFO_NAME); fi

check-fifo:
	@if ! pgrep itmdump >/dev/null; then \
		echo "No itmdump is running, this would hang the openocd" >&2; \
		exit 1; \
	fi

flash: $(BIN_BIN)
	openocd \
		-f interface/stlink.cfg \
		-f board/stm32ldiscovery.cfg \
		-c "program $(BIN_ELF) verify reset exit"

flashdbg: $(BIN_ELF) $(FIFO_NAME) check-fifo
	$(Q)openocd \
		-f interface/stlink.cfg \
		-f $(OPENOCD_CHIP_CFG) \
		-c "program $(BIN_ELF) verify reset" \
		-c "tpiu config internal $(FIFO_NAME) uart off $(TPIU_FREQ)" \
		-c "itm ports on"

openocd: $(FIFO_NAME) check-fifo
	$(Q)openocd \
		-f interface/stlink.cfg \
		-f $(OPENOCD_CHIP_CFG) \
		-c "tpiu config internal $(FIFO_NAME) uart off $(TPIU_FREQ)" \
		-c "itm ports on" \
		-c "init" \
		-c "reset"

itmdump:
	itmdump -F -f $(FIFO_NAME)

erase:
	$(Q)st-flash erase

gdb:
	@arm-none-eabi-gdb -tui \
		-ex "target extended-remote localhost:3333" \
		-ex "monitor reset halt" \
		-ex "monitor arm semihosting enable"


ASM=nasm

SRC_DIR=src
BUILD_DIR=build

all: run

# Floppy image
floppy_img: $(BUILD_DIR)/main.img
$(BUILD_DIR)/main.img: bootloader kernel
	@echo "Creating system image..."
	# Allocate 1.44 MB of space for main.img
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880

	# Bootloader -> Sector 1 of the image
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/main.img conv=notrunc

	# Kernel -> Sector 2
	dd if=$(BUILD_DIR)/kernel.bin of=$(BUILD_DIR)/main.img bs=512 seek=1 conv=notrunc
	@echo "System image created successfully."

# Bootloader
bootloader: $(BUILD_DIR)/boot.bin
$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

# Kernel
kernel: $(BUILD_DIR)/kernel.bin
$(BUILD_DIR)/kernel.bin: $(SRC_DIR)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

# Run
run: floppy_img
	@echo "Running Ardonium/OS..."
	qemu-system-i386 -fda $(BUILD_DIR)/main.img

# Clean
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)/*

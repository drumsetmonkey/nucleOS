# Copyright (C) 2019  Belle-Isle, Andrew <drumsetmonkey@gmail.com>
# Author: Belle-Isle, Andrew <drumsetmonkey@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CC = arm-none-eabi-gcc
SC = arm-none-eabi-as
LC = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

BOARD = STM32H743xx

DIR_CRT = mkdir -p $(@D)

SRC_DIR = src
C_FILES = $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/*/*.c)
S_FILES = $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*/*.s)


OBJ_DIR = out
O_FILES = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(C_FILES)) \
		  $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.s.o, $(S_FILES))

CPU_FLAGS = -mcpu=cortex-m7
C_FLAGS = $(CPU_FLAGS) --specs=nosys.specs -Isrc/ -Ilib/ -Ilib/system/ \
					   -Ilib/cmsis/inc -Llib/cmsis/gcc -L. -D$(BOARD) \
		  				-Wall -Werror -std=c11
DEB_FLAGS = -g -DDEBUG
REL_FLAGS = -O2

S_FLAGS = $(CPU_FLAGS)

ELF = $(OBJ_DIR)/os.elf
HEX = $(OBJ_DIR)/os.hex
OUT = $(HEX)

all: debug

debug: C_FLAGS += $(DEB_FLAGS)
debug: $(OUT)

release: C_FLAGS += $(REL_FLAGS)
release: $(OUT)

$(OUT): $(O_FILES)
	$(CC) $(C_FLAGS) -o $(ELF) $^ -T lib/ld/STM32H743ZITx_FLASH.ld
	$(OC) -O ihex $(ELF) $(OUT)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@$(DIR_CRT)
	$(CC) $(C_FLAGS) -c $< -o $@

$(OBJ_DIR)/%.s.o: $(SRC_DIR)/%.s
	@$(DIR_CRT)
	$(SC) $(S_FLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)/*

upload:
	@echo "Starting openOCD"
	@openocd -f board/st_nucleo_h743zi.cfg &
	@arm-none-eabi-gdb -iex "target remote :3333" out/os.elf 
	@pkill -9 openocd

stop:
	@pkill -9 openocd

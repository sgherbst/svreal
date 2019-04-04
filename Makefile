# modified from: https://github.com/tommythorn/verilator-demo/blob/master/Makefile

target ?= hello

TEST_DIR = tests
TOP_NAME = top
CPP_FILE = test.cpp
SV_FILE = $(TOP_NAME).sv
OBJ_DIR = obj_dir

# OS-dependent executable file extension
ifeq ($(OS),Windows_NT)
    EXE_FILE = $(OBJ_DIR)/V$(TOP_NAME).exe
else
    EXE_FILE = $(OBJ_DIR)/V$(TOP_NAME)
endif

.PHONY: run build clean

run: build
	$(EXE_FILE)

build:
	cp $(TEST_DIR)/$(target).sv $(SV_FILE)
	verilator +1800-2012ext+sv +incdir+include -y src -Wall -Wno-fatal --cc $(SV_FILE) --exe $(CPP_FILE) 
	make -C $(OBJ_DIR) -j -f V$(TOP_NAME).mk V$(TOP_NAME)

clean:
	rm -rf $(OBJ_DIR)
	rm -f $(SV_FILE)

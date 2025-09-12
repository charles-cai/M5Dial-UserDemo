#!/bin/bash

# Configs
IDF_PATH=$HOME/esp/v5.1.6/esp-idf/
SERIAL_PORT=/dev/ttyACM0


# Help shit
help() {
    sed -rn 's/^### ?//;T;p' "$0"
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    help
    exit 1
fi

# Get idf
. ${IDF_PATH}/export.sh

# Build and flash and monitor
idf.py -p ${SERIAL_PORT} flash -b 1500000 monitor

# /home/charles/.espressif/python_env/idf5.1_py3.10_env/bin/python \
#   ../../../esp/v5.1.6/esp-idf/components/esptool_py/esptool/esptool.py \
#   -p /dev/ttyACM0 -b 460800 \
#   --before default_reset --after hard_reset \
#   --chip esp32s3 \
#   write_flash --flash_mode dio --flash_size 8MB --flash_freq 80m \
#   0x0 build/bootloader/bootloader.bin\
#   0x8000 build/partition_table/partition-table.bin \
#   0x10000 build/stamp_ring_factory_test.bin
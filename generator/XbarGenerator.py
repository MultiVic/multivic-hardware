# Copyright (c) 2025 Maximilian Kirschner, Ben Krusekamp
# Licensed under the Solderpad Hardware License v2.1. See LICENSE file in the project root for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

import json
from Variables import core_count

# default options
base_addrs = 0x00200000
step = 0x00100000
memory_size_data = 0x80000
memory_size_instr = 0x4000

def generate_device_entry(name, base_addr_hart, memory_size):
    return {
        "name": name,
        "type": "device",
        "clock": "clk_main_i",
        "reset": "rst_main_ni",
        "xbar": False,
        "pipeline": True,
        "req_fifo_pass": False,
        "rsp_fifo_pass": False,
        "addr_range": [
            {
                "base_addrs": {"hart": base_addr_hart},
                "size_byte": memory_size
            }
        ]
    }

def vicunaDataName(core_id):
    return f"vicuna{core_id}_scratchpad_data"

def vicunaInstrName(core_id):
    return f"vicuna{core_id}_scratchpad_instr"
def generateDevices():
    entries = []
    for core_id in range(core_count):
        core_base_addr = base_addrs + core_id * 2 * step

        entries.append((vicunaInstrName(core_id), hex(core_base_addr),hex(memory_size_instr)))
        entries.append((vicunaDataName(core_id), hex(core_base_addr + step),hex(memory_size_data)))

    result = [generate_device_entry(name, base_addr_hart,memory_size) for name, base_addr_hart, memory_size in entries]
    extra_indent = "        "
    for entry in result:
        formatted_entry = json.dumps(entry, indent=4)
        # Add extra indentation to each line
        indented_entry = '\n'.join(f"{extra_indent}{line}" for line in formatted_entry.splitlines())
        print(f"{indented_entry},")

def generateConnections():
    entries = []
    for core_id in range(core_count):
        entries.append(vicunaInstrName(core_id))
        entries.append(vicunaDataName(core_id))

    extra_indent = "        "
    for entry in entries:
        print(f"{extra_indent}\"{entry}\",")


# Copyright (c) 2025 Ben Krusekamp
# Licensed under the Solderpad Hardware License v2.1. See LICENSE file in the project root for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

import re
from Variables import core_count

def _replaceName(core_id,content):
    return re.sub(f"CORE_NAME",f"vicuna{core_id}",content);

def generateDeclaration():
    with open("generator/system/declaration.sv", 'r') as file:
        content = file.read()
    for core_id in range(core_count):
        new_content = _replaceName(core_id,content)
        print(new_content)

def generateXbar():
    with open("generator/system/xbar.sv", 'r') as file:
        content = file.read()
    for core_id in range(core_count):
        new_content = _replaceName(core_id,content)
        print(new_content)

def generateCores():
    with open("generator/system/core.sv", 'r') as file:
        content = file.read()
    for core_id in range(core_count):
        new_content = _replaceName(core_id,content)
        print(new_content)


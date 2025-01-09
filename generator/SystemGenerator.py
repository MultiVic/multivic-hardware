import re
core_count = 2

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


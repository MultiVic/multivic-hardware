opentitan_repo := "./submodules/opentitan"

default: 
    @echo "Please look at the readme for more information about each command."
    @echo "The current commands are:"
    @just --list

# Build the project
build:
    fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build ess-fzi:vicuna:multicore

#Sets everything needed for the project up.
setup:
    git submodule update --init
    @just configure
    @just generate_xbar

# Run the project using verilator
run *OPTIONS: 
    ./build/ess-fzi_vicuna_multicore_0.0.1/sim-verilator/Vtop_verilator {{OPTIONS}}

# Clean the build directory
clean: 
    rm -rf ./build/*

# Generates the xbars.
generate_xbar:
    {{opentitan_repo}}/util/tlgen.py -t ./data/xbar_main.json -o src/crossbar_main
    {{opentitan_repo}}/util/tlgen.py -t ./data/xbar_management_peripherals.json -o src/crossbar_management_peripherals

# Applies the config, like core count.
configure:
    cog -d generator/xbar_main.json > data/xbar_main.json
    cog -d generator/system.sv > ./src/system.sv

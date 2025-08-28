# Vicuna Multicore
## Architecture Overview
Hardware implementation of the MultiVic architecture, for deployment on FPGA (Xilinx ZCU102 or VCU128) or Verilator simulation.
The architecture is configurable in the number of worker cores and the size of the scratchpad memories.

Examplary hardware architecture, with 4 worker cores and 1 MiB data scratchpads:
![Architecture Overview](docs/architecture-overview.drawio.svg) 

### Address Map
Default address ranges for a 2-core configuration:

#### Main Crossbar
| Component                         | Base Address | Size in bytes |
| --------------------------------- | ------------ | ------------- |
| scratchpad management instruction | 0x00000000   | 0x10000       |
| scratchpad management data        | 0x00100000   | 0x10000       |
| vicuna 0 instruction              | 0x00200000   | 0x4000        |
| vicuna 0 data                     | 0x00300000   | 0x80000       |
| vicuna 1 instruction              | 0x00400000   | 0x4000        |
| vicuna 1 data                     | 0x00500000   | 0x80000       |

#### Peripheral Crossbar
| Component                  | Base Address | Size    |
| -------------------------- | ------------ | ------- |
| scratchpad management data | 0x00100000   | 0x10000 |
| uart                       | 0x80001000   | 0x1000  |
| timer                      | 0x80002000   | 0x1000  |
| dma register port          | 0x90001000   | 0x1000  |

## Commands
The commands are contained in a justfile. Run ```just``` to see a list of options.

The primary commands that you need to know are:

### Setup
```bash
CORE_COUNT=2 just setup
```
This command sets the project up.
This will:<br>
1. Initialize the git submodules.
2. Run the preprocessor to generate files like system.sv.
3. Generate the xbars.

### build
```bash
just build
```
will build the project for verilator

### run
```bash
just run
```
executes the project with verilator. This will pass through parameters, like `-t`.

### Configure Vicuna Co-Processor
To configure the size of the vector registers or the compute units, you can use the provided Makefile.

For example 1024 bit vector registers and 512 bit multiplication unit:
```bash
cd submodules/vicuna
make --file config.mk VPROC_CONFIG=legacy VREG_W=2048 VPIPE_W_VMUL=1024
```

## License
Unless otherwise noted, the code in this repository is licensed under the MIT License. See LICENSE for details.

Some components come from third-party libraries and are licensed under their respective licenses. These are listed in the NOTICE file.
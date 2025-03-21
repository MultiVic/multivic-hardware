# Vicuna Multicore
## Architecture Overview
Default architecture with 2 worker cores and 1 management core. The architecture is configurable in the number of worker cores.

![Architecture Overview](docs/architecture-overview.drawio.svg) 

### Address Map
Default address ranges, also subject to change because the number of cores and the size of the scratchpad memories can be configured.

#### Main Crossbar
| Component | Base Address  | Size in bytes |
| ---       | ---           | ---   |
| scratchpad management instruction | 0x00000000    | 0x10000   |
| scratchpad management data        | 0x00100000    | 0x10000   |
| vicuna 0 instruction | 0x00200000    | 0x10000   |
| vicuna 0 data        | 0x00300000    | 0x10000   |
| vicuna 1 instruction | 0x00400000    | 0x10000   |
| vicuna 1 data        | 0x00500000    | 0x10000   |

#### Main Crossbar
| Component | Base Address  | Size  |
| ---       | ---           | ---   |
| scratchpad management data        | 0x00100000    | 0x10000   |
| uart      | 0x80001000    | 0x1000    |
| dma register port | 0x90001000    | 0x1000    |

## Commands
The commands are contained in a justfile. Run ```just``` to see a list of options.

The primary commands that you need to know are:

### setup
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

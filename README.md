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

## Build Commands
### Tlgen generation
Generate the main crossbar:
```bash
submodules/opentitan/util/tlgen.py -t data/xbar_main.json -o src/crossbar_main
```
Generate the smaller crossbar at the management core data port:
```bash
submodules/opentitan/util/tlgen.py -t data/xbar_management_peripherals.json -o src/crossbar_management_peripherals
```

### Simulation - verilator
Before simulating edit the paths for the scratchpad initialization in `simulation/top_verilator.sv`.

Build the simulation model:
```bash
fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build ess-fzi:vicuna:multicore
```

Execute the simulation:
```bash
# Parameter -t to record the trace in a sim.fst file
./build/ess-fzi_vicuna_multicore_0.0.1/sim-verilator/Vtop_verilator -t
```
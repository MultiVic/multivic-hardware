# Tlgen generation
```bash
../repos/opentitan/util/tlgen.py -t data/xbar_main.json -o src/crossbar
```

# Simulation - verilator
(currently not working)
```bash
fusesoc --cores-root=. run --target=sim --tool=verilator --setup --build ess-fzi:vicuna:multicore
```

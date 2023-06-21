# Getting Started

Install RISC-V [toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) and [verilator](https://verilator.org/guide/latest/install.html). These tools can be built by following the instructions in the corresponding links, or can be installed directly by running the following command

    sudo apt-get install -y gcc-riscv64-unknown-elf verilator gtkwave

Check that these tools are installed correctly, by running `verilator --version` and `riscv64-unknown-elf-gcc -v`.

### Build Model and Run Simulation

Verilator model of RTL core can be built using Makefile:

    make verilate

The verilator model is build under `ver_work/Vcore_sim`. The executeable can accept the following three parameters:

- `imem` : This paramerter accepts the file that contain the hexadecimal instructions of compiled program.
- `max_cycles`: This parameter the maxiumum number of cycles for simulation. Simulation terminates after executing these number of cycles.
- `vcd`: This parameters accepts a boolean value. If it is 0, the waveform file `trace.vcd` will not be dumped and vice versa.



The `imem` and `max_cycles` by be overwritten in Makefile using.

    make verilate imem=</path/to/hex/file> max_cycles=<No. of cycles> 

### Verification

RISC-V Architecture Compatibility Tests (ACTs) can be executed under RISCOF environment. Instructions to run these tests can be followed in [verif](/verif/) directory.
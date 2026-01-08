The file allmodule2.sv contains all the modules required for the implementation of the single-cycle processor, including:
- All the modules for the ALU (without using operators for subtraction (−), comparison (<, >), shifting (≪, ≫, and ≫), multiplication (∗), division (/), modulo (%), and other
unsynthesizable operators): add, sub, sll, srl, slt, sltu, sra.
- Immediate generator
- Register file.
- Load-Store Unit.
- Branch Comparison.
- Program Counter.
- Instruction Memory.
- Control Unit.

The file single_cycle.sv contains the top-level module, which instantiates and connects all the required modules to form the complete single-cycle processor.

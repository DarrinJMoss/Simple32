# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-11-3

### Added

- Folder in `docs/` for internal documentation.
- Updated the `README.md` to have links to other documents as opposed to
  directly embedding them in the file.

### Changed

- Moved `s32_asm_reference.md` from root to `docs/` and renamed it to
  `S32 Documentation.md`
- Moved some internal documentation (`Compiled Format.txt`) to a dedicated
  folder in `docs/`
- Moved the AI Statement from `README.md` to a seperate file.

### Removed

- Several outdated pieces of internal documentation (`opcodes.txt`, 
  `registers.txt`, `V32 Assembly Reference`).

## [0.3.0] - 2026-11-2

### Added

- Macros `CAST_TO_BIN64` and `CAST_TO_BIN32` which convert any input
  variable to binary for processing by `fprintf_binary`.
  ```
  Ex:
  float myfloat = 31.4f;
  fprintf_binary(stdout, CAST_TO_BIN32(myfloat), 32, NULL);
  OUTPUT: 01000001111110110011001100110011
  ```
- Documentation for the function `fprintf_binary` and macros `CAST_TO_BIN64`
  and `CAST_TO_BIN32`.

### Changed

- Removed the debug outputs from `full_adder.sv`.
- Removed hooks for the above debug outputs from `full_adder_tb.cpp`.
- Updated the changelog to better utilize sections.
- Modified `fprintf_binary` to lead with the MSB instead of the LSB.
- Moved `SIGNED` to `s32tb_utils.h` and added a massive explanation of how it
  works due to it being rather complex.
- Updated `full_adder_tb.cpp` to utilize the new `SIGNED` macro.
- Updated `README.md` to actually have stuff to read.

### Removed

- `full_adder_tb.csv`, a file in the root that was supposed to be removed
  before the last commit, however the developer forgot.

## [0.2.2] - 2026-11-2

### Added

- Added `fprintf_binary` to `s322tb_utils.h`, a function that prints out an
  integer in its binary form.
- Added `SIGNED` macro to expand a small signed number to a 32 bit one for
  processing.

### Changed

- Changed the testbench to print to a CSV file as opposed to stdout

### Fixed

- The subtraction testbench display, which now uses the afformentioned `SIGNED()`
  macro.

## [0.2.1] - 2026-10-22

### Added

- README.md

### Changed

- Updated the current s32 documentation

## [0.2.0] - 2026-10-22

### Added

- Makefile to facilitate running different protocols.
- Testbenches for the full_adder

### Fixed

- Fixed an issue with the ALU regarding the behavior of carry and overflow
  flags on non-arithmetic operations.

## [0.1.0] - 2026-10-21

### Added

- This changelog.
- types.sv, a file that contians some shared data structures that are utilized
  by multiple files or are generally important for data communication (i.e.,
  status flags after ALU operations).
- An assembly reference file that contians links to the current online
  documentation. Documentation will be updated online generally before
  being updated in the file.
- Rust files relating to the assembler, specifically the tokenizer on the 
  assembler.
- Implemented the first draft of the ALU


### Changed

- Migrated non CPU verilog files to SystemVerilog.

### Deprecated

- cpu.sv is currently being deprecated and will be removed once an updated one
  is finished. This is due to major architectural changes and a better
  understanding of SystemVerilog.
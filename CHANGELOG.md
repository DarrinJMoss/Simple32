# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-10-22

### Added

- README.md

### Changed

- Updated the current s32 documentation

## [0.2.0] - 2026-10-22

### Added

- Makefile to facilitate running different protocols.
- Testbenches for the full_adder

### Changed

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
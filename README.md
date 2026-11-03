# Simple32 

<center>

<img src="docs/images/logo.svg" alt="Simple 32 Logo" width="30%">

**Simple32** is a 32-bit CPU written entirely in Systemverilog. 

It runs a custom ISA with its own assembly language known as **S32 ASM.**

***PLEASE NOTE!*** _This project is still in development and many aspects are a work in progress._

</center>

## How to Run & Build

Let's say you want to run simple 32. The easiest way to do that is just run the precompiled 
binaries found on this GitHub page.* The binaries are designed to be self-explorable, though
I may eventaually add documentation for each. Just run each binary without arguments to get 
started.

The rest of this section is for those who want to build from source. For this, simply use make with Linux or WSL to build the project as specified below:

If you want to make all testbenches and programs, simply use `make all`. 
_(Do note the compilation will take a fair amount of time to complete.)_
However, This will not compile the S32 ASM assembler**. To build that, use `make [TODO]`. 

If you want a complete list of what the makefile can do, just use `make help`.
Alternatively, just typing `make` will default to the help command.

#### Footnotes

_* If there are no binaries at the time of reading, that means S32 is still in beta._
_they will be added when the first stable release completes._

_**This is isolated since I'm assuming most people probably don't have a Rust compiler installed._ 
_I don't want regular compilation to get walled by not having one._



## Backend Notes

This project is primarily written in three different languages, each with their own purpose:

1. **Systemverilog**  - Systemverilog is used as the primary HDL for this project. it is used to 
                        write all of the hardware code used.
                        I chose Systemverilog because--outside of being the industry standard--it's
                        the langauge I learned how to use in school 
                        _(technically plain Verilog, but it's close enough)._

2. **C/C++**          - C/C++ is what all interfaces and testbenches are written in.
                        You may be wondering why I say C/C++ as opposed to just one or the other.
                        And my reasoning is pretty straightforward. Verilator utilizes C++, but I 
                        prefer C. So the result is a hybrid style where I use C++ for some things, 
                        but primarily revert to C for overall code structure. And by some things I
                        bascially just mean built-in booleans and the occasional C++ standard data
                        structure (i.e., `vector`).

3. **Rust**           - Rust is the language the compiler for S32 ASM is written in. I chose this 
                        purely due to personal preference in being a certified enjoyer of the 
                        language. Because it's a more isolated part of the project



## Other Documents
### [S32 ASM Documentation](docs/S32Documentation.md)
### [Statement on AI Usage](docs/Statement%20of%20AI%20Usage.md)
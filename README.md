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



## Statement on AI Usage

Our modern tech industry is currently under a massive AI revolution, with it drastically changing
the way we approach making projects. However, this project is created with entirely human-made
code, text, and images. In addition, no AI was used in any major decision making.

My logic here is for two main reasons. The lesser of these _(personally speaking)_ is that I'm a 
student. I still have a lot to learn in tech. Personally, vibe-coding projects to me feels... 
_cheap_, almost like cheating in a class. You may have passed, but in the end, can you reall say 
you've learned anything? That is a primary reason I am writing this by hand. I'm not interested in
a cool resume project, I actually want to learn about the projects I'm working on.

The greater of these, however, is that I love what I do. Programming isn't a means to an end or a
blockade in the way of a cool project, it's a hobby of mine, something I do recreationally 
_(thanks Tsoding)_. When I use AI significantly for a personal project, I feel a bit of my soul get 
ripped away in the name of productivity. While it's not a huge deal for work, it kind of stings to 
use it for projects important to me, hence why I am abstaining from it.

As for the effects of this on the project, they can be generally summed up as follows:
- **Some code may contain bugs which are uncommon for LLM generated code.** This is to be expected, 
  I am only human, after all. Bug reports are encouraged if anything is found.
- **This project will be more on the unoptimized side, to an extent.** While I would like to get S32
  running smoothly, I am--again--also human. I don't have infinite knowledge for the best way to 
  approach every problem. And I generally fall into the camp of, "make it work first, make it 
  perfect later." So many decisions aren't going to be perfect.
- **This project will take much longer to develop.** I'm a full time student with a part time job 
  and a social life. I, unfortunately, rarely have more than an hour to devote to this project per 
  week, and that's if I'm lucky. Because of the length of this project, I will also potentially go 
  back and redesign large swaths of the project if I learn about a better way to approach something.
  _(This already happened once when I got into computer architecture and found a much better_
  _way of handling opcodes for assembly instructions, leading to S32 ASM getting a complete_ 
  _overhaul)_

That being said, I wouldn't describe myself as anti-AI at all. In fact I still do use it for my
projects, this one included. Here are some ways AI is used in this project:
- **Bugfixing.** As much as I use them, C/C++ errors still vex me most of the time, especailly if 
  they occur during linking. Header files are the death of me, and I am terrible at finding issues. 
  AI helps me in this way by parsing and identifying errors when they occur. That being said, I make
  sure not to default to AI when an issue arises. I still want to flex my debugging muscles, after
  all.
- **Identifying code safety issues or undefined behavior:** C/C++ can be minefields with footguns 
  around every corner. AI can help to catch any catestrophic errors before they occur.
- **Research and learning.** I sometimes use AI to help explain concepts that I am learning or I may
  use it to also answer a more specific question that random forums may not have the answer to.

Outside of these specific things, though, I generally avoid AI to keep my skills sharp and my mind
sharper. If you have any other questions please feel free to reach out.
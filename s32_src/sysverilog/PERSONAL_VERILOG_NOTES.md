# Some personal notes for common mistakes I make

## VECTOR SYNTAX

Vectors are defined using the syntax *[MSB:LSB]*

So both [7:0] and [0:7] represent the same size of vector, however one is big endian *([7:0])* and the other is little endian *([0:7])*

Generally, just stick to ***[BIT_N - 1 : 0]*** unless you're accessing specific bits from a line.
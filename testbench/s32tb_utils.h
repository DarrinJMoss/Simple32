#ifndef __S32TB_UTILS_H
#define __S32TB_UTILS_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/// Casts any variable to a `uint64_t`, or binary. Requires `<stdint.h>` to be included.
///
/// Note: The variable must be predefined, and must not be a literal.
#define CAST_TO_BIN64(x) (*(uint64_t*)&x)
/// Casts any variable to a `uint32_t`, or binary. Requires `<stdint.h>` to be included.
///
/// Note: The variable must be predefined, and must not be a literal.
#define CAST_TO_BIN32(x) (*(uint32_t*)&x)

/// @brief  Prints a variable in its binary form.
///        
///         This function attempts to print with the MSB..LSB format, however if a dynamic
///         allocation fails it will fall back to LSB..MSB with a header to denote this.
///
///         If you want to use a non-integer type, just cast it to binary before printing.
///         See `CAST_TO_BIN(32/64)()` for more info.
///
///         I.e., 
///
///         `fprintf_binary(stdout, 500, 16, NULL); -> 0000000111110100`
///
///         `float myfloat = 31.4f; fprintf_binary(stdout, CAST_TO_BIN32(myfloat), 32, NULL); -> 01000001111110110011001100110011`
/// @param ftarget  The file target to write to. If you just want to print it, use stdout or stderr.
/// @param num      The number we want to print.
/// @param bit_cnt  The length of the number in bits.
/// @param delim    A deliminator to add to the end of the print. Useful if we're writing to a format
///                 like CSV. If you don't want a deliminator, just pass NULL.
void fprintf_binary(FILE* ftarget, uint64_t num, uint8_t bit_cnt, const char* delim) {
    // An array of bits for us to print in the stack format
    uint8_t* bin_stack = (uint8_t*)malloc(sizeof(uint8_t) * bit_cnt);

    if (bin_stack == NULL) {
        // This shouldn't happen, but just in case...
        fprintf(stderr, "Could not create a stack to print LSB first. Using MSB first without dynamic allocation.");
        
        // Print withot the stack, LSB first
        fprintf(ftarget, "LSB..MSB:");

        for (int i = 0; i < bit_cnt; i++) {
            fprintf(ftarget, "%lu", (num >> i) & 1);
        }

        if (delim != NULL) {
            fprintf(ftarget, "%s", delim);
        }

        return;
    }

    // Load our stack with bits
    for (int i = 0; i < bit_cnt; i++) {
        bin_stack[i] = (uint8_t)((num >> i) & 1);
    } 
    // Pop em off into the file target
    for (int i = bit_cnt - 1; i >= 0; i--) {
        fprintf(ftarget, "%u", bin_stack[i]);
    }

    if (delim != NULL) {
        fprintf(ftarget, "%s", delim);
    }

    free(bin_stack);

    return;
}

/// @brief Converts a signed N bit number into a 32-bit signed number.
///
/// @param num The number to convert.
/// @param bcnt The number of bits in the number, ie., 4 for a 4-bit number, 8 for an 8-bit number, etc.
///
/// I.e., let's say we have a four bit number in SystemVerilog, `0b1111`.
/// As a signed number this is -1, however when we expand it to 32 bits for processing in C/C++, it becomes `0b0000...0000_1111`.
/// This is interpereted instead as 16, which is no bueno.
///
/// This function seeks to fix this gap, it converts the `0b0000...00001111` into `0b1111...1111_1111` so that it can be read correctly.
///
/// Ex: `0b1010 -> 0b1111...1111_1010, 0b1011 -> 0b1111...1111_1011`.
///
/// This macro does nothing if the number is signed, but not negative.
///
/// Ex: `0b0111 -> 0b0000...0000_0111, 0b0000 -> 0b0000...0000_0000`.
#define SIGNED(num, bcnt) ((int32_t)((((0b1 << (bcnt - 1)) & num) >> (bcnt - 1) == 1) ? num | (UINT32_MAX << bcnt) : num))
/* 
    Developer note: this macro is SUPER ugly, but was fun to make. 

    It basically first checks if the number is negative or not. It does this by checking if the
    Nth bit is set, which implies negativity according to two's complement.
        (((0b1 << (bcnt - 1)) & num) >> (bcnt - 1) == 1)
           ^^^^^^^^^^^^^^^^^^^^^^^   ^^^^^^^^^^^^  ^^^^
            Isolate the Nth bits          |         | 
                                Shift it all the way|
                                   to the right     |
                                                Actually check if it's
                                                set
    
    Using a ternary if, the first condition is if the function is true, and thus the number
    is negative. This simply takes -1 as a 32 bit number (all 1s) and shifts it N times 
    to the left. Each shift makes adds a zero to the right, meaning we can safely OR it with
    our number to just make all the new leftmost bits equal to one without loosing data.
        num | (UINT32_MAX << bcnt)
           ^    ^^^^^^^^^     ^^^^^^^
           |   Get all 1s       |
           |              Add our zeros to 
           |              the right
        OR that baby
    Note: This uses UINT32_MAX over the old (int32_t)-1 due to an old implementation resulting in UB (left shifts on signed numbers). 
    This didn't actually affect anything, but probably best to erradicate all potential errors.
    
    Finally, if the condition is false and we aren't negative, we don't actually have to
    do anything, just directly pass the number on through
        num
        ^^^
     I trust in your
     ability to understand
     this line
    
    Now you should be able to parse this monstrosity I have created. That includes me in a week
    too. I will not be able to unpack this later.

    ((((0b1 << (bcnt - 1)) & num) >> (bcnt - 1) == 1) ? num | (UINT32_MAX << bcnt) : num)

    Praise God for bitwise operators!
*/ 


#endif
`timescale 1ps/1ps

package Enums;

    // List of operations the Arithmetic Logic Unit (ALU) can perform
    typedef enum [4 : 0] { 
        // Total of 18 operations

        // LOGIC ******************
        ALU_AND  = 5'b00000,    // Compute the logical AND of inputs 1 and 2
        ALU_OR   = 5'b00001,    // Compute the logical OR of inputs 1 and 2
        ALU_XOR  = 5'b00010,    // Compute the logical Exclusive OR of inputs 1 and 2

        ALU_NAND = 5'b00011,    // Compute the logical NAND of inputs 1 and 2
        ALU_NOR  = 5'b00100,    // Compute the logical NOR of inputs 1 and 2
        ALU_XNOR = 5'b00101,    // Compute the logical Exclusive NOR of inputs 1 and 2

        ALU_NOT  = 5'b00110,    // Invert every bit of input 1
        ALU_NEG  = 5'b00111,    // Perform 2's complement inversion on input 1

        ALU_ASR  = 5'b01000,    // Compute the artithmetic shift right of input 1 input 2 times.
        ALU_ASL  = 5'b01001,    // Compute the artithmetic shift left of input 1 input 2 times.

        ALU_LSR  = 5'b01010,    // Compute the logical shift right of input 1 input 2 times.
        ALU_LSL  = 5'b01011,    // Compute the logical shift left of input 1 input 2 times.

        ALU_ROR  = 5'b01100,    // Rotate the bits of input 1 input 2 times to the right.
        ALU_ROL  = 5'b01101,    // Rotate the bits of input 1 input 2 times to the left.

        ALU_TEST = 5'b01110,    // Compute the logical AND of inputs 1 and 2 without returning a value.
        
        // ARITHMETIC ******************
        // Note: The binary value for CMP is different due to how determining arithmetic is handled 
        //                                  (leftmost bit = arithmetic?, rightmost bit = subtract?)
        ALU_CMP  = 5'b10011,    // Compute the difference of inputs 1 and 2 without returning a value.

        ALU_ADD  = 5'b10000,    // Compute the sum of inputs 1 and 2.
        ALU_SUB  = 5'b10001     // Compute the difference of inpouts 1 and 2.
    } AluOperations;

endpackage

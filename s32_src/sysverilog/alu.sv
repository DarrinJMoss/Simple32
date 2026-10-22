`timescale 1ps/1ps

import Enums::*;
import Types::ResultFlags;

module ALU #(
    // Must be a power of 2. The rotate commands will not work as expected otherwise
    parameter int unsigned ALU_WORD_SIZE = 8
) (
    // INPUT ***************************************
    input AluOperations                     op_i,

    input logic [ALU_WORD_SIZE - 1 : 0]     arg1_i,
    input logic [ALU_WORD_SIZE - 1 : 0]     arg2_i,

    // OUTPUT **************************************
    output logic [ALU_WORD_SIZE - 1 : 0]    result_o,
    output ResultFlags                      flags_o
);

    logic [ALU_WORD_SIZE - 1 : 0]   result;
    logic [ALU_WORD_SIZE - 1 : 0]   adder_result;

    logic flag_carry      = 0;
    logic flag_overflow   = 0;

    logic is_arithmetic;  assign is_arithmetic  = op_i[4];
    logic do_subtraction; assign do_subtraction = is_arithmetic & op_i[0];

    FullAdder_Nbit #(
        .BIT_N              (ALU_WORD_SIZE)
    ) Adder (
        .addend_a           (arg1_i),
        .addend_b           (arg2_i),
        .do_subtraction     (do_subtraction),
        .result_o           (adder_result),
        .flag_carry_o       (flag_carry),
        .flag_overflow_o    (flag_overflow)
    );

    always_comb begin : Operations
        case(op_i)
            ALU_AND:     result = arg1_i & arg2_i;
            ALU_OR:      result = arg1_i | arg2_i;
            ALU_XOR:     result = arg1_i ^ arg2_i;

            ALU_NAND:    result = ~(arg1_i & arg2_i);
            ALU_NOR:     result = ~(arg1_i | arg2_i);
            ALU_XNOR:    result = ~(arg1_i ^ arg2_i);

            ALU_NOT:     result = ~arg1_i;
            ALU_NEG:     result = -arg1_i;

            ALU_ASR:     result = $signed(arg1_i) >>> arg2_i;
            ALU_ASL:     result = arg1_i <<< arg2_i;

            ALU_LSR:     result = arg1_i >> arg2_i;
            ALU_LSL:     result = arg1_i << arg2_i;

            ALU_ROR:     result = (arg1_i >> (arg2_i & (ALU_WORD_SIZE - 1))) | (arg1_i << (ALU_WORD_SIZE - (arg2_i & (ALU_WORD_SIZE - 1))));
            ALU_ROL:     result = (arg1_i << (arg2_i & (ALU_WORD_SIZE - 1))) | (arg1_i >> (ALU_WORD_SIZE - (arg2_i & (ALU_WORD_SIZE - 1))));

            ALU_TEST:    result = arg1_i & arg2_i;
            ALU_CMP:     result = adder_result;

            ALU_ADD:     result = adder_result;
            ALU_SUB:     result = adder_result;

            default:                    result = '0;
        endcase
    end

    // TODO: Make carry and overflow flags not do anything if not adding
    
    
    // Evaluate the output to determine if it is zero or not
    assign flags_o.zero         = ~| result;
    // Check the MSB to determine if it is negative (if interpereted as signed)
    assign flags_o.negative     = result[ALU_WORD_SIZE - 1];
    // Signed overflow, computed in FullAdder_Nbit
    assign flags_o.overflow     = flag_overflow & is_arithmetic;
    // Carry, compuuted in FullAdder_Nbit
    assign flags_o.carry        = flag_carry    & is_arithmetic;
    
    // Move the result to the output
    assign result_o             = result;

endmodule

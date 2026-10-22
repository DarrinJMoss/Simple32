`timescale 1ps/1ps

import Types::ResultFlags;

// Full-adder for one bit.
module FullAdder (
    input   logic   a,
    input   logic   b,
    input   logic   carry_i,
    output  logic   result,
    output  logic   carry_o
);  
    assign result = a ^ b ^ carry_i;
    assign carry_o  = (a & b) | ((a ^ b) & carry_i);
endmodule


// Full-adder for n bits.
module FullAdder_Nbit #(
    // Use 8 by default to test adder functionality
    parameter int unsigned          BIT_N = 8
) (
    // INPUT ***************************************
    input   logic [BIT_N - 1 : 0]   addend_a,  
    input   logic [BIT_N - 1 : 0]   addend_b,

    input   logic                   do_subtraction,

    // OUTPUT **************************************
    output  logic [BIT_N - 1 : 0]   result_o,
    
    output  logic                   flag_carry_o,
    output  logic                   flag_overflow_o
);
    // We need to store these in an intermediate state to do some flag evaluations once the addition is finished
    logic [BIT_N - 1 : 0] carry_register;
    logic [BIT_N - 1 : 0] result_register;

    genvar i;
    generate
        // Assert that BIT_N >= 2
        if (BIT_N < 2) begin : Invalid_BIT_N
            initial begin
                $fatal(1, "BIT_N must be at least 2");
            end
        end
        
        for (i = 0; i < BIT_N; i = i + 1)   begin : GenerateFulladders
            // When subtracting, the second addend is inverted with 2's complement
            // This is the bit inversion
            logic b_modified;
            assign b_modified = addend_b[i] ^ do_subtraction;
            // The +1 part of the 2's complement is done by passing do_subtraction to the carry input of the first adder
            //                                                                 |
            if (i == 0)                     begin : FirstAdder  //             V
                FullAdder OpFirst   (.a(addend_a[i]), .b(b_modified), .carry_i(do_subtraction),        .result(result_register[i]), .carry_o(carry_register[i]));
            end else                        begin : OtherAdders
                FullAdder OpOther   (.a(addend_a[i]), .b(b_modified), .carry_i(carry_register[i - 1]), .result(result_register[i]), .carry_o(carry_register[i]));
            end
        end
    endgenerate

    // Check for signed overflow
    //
    // This can be set if the final carry bit and second to last carry bit are not equal, which is always true on signed overflow
    // For unsigned overflow, check the carry flag
    assign flag_overflow_o  = carry_register[BIT_N - 1] ^ carry_register[BIT_N - 2];
    // Assigned if there is a final carry bit in the operation
    //
    // This is always true when doing signed arithmetic with two negative numbers
    // For unsigned arithmetic addition, this can be used to determine if overflow has occurred
    assign flag_carry_o     = carry_register[BIT_N - 1];

    assign result_o = result_register;
    
endmodule

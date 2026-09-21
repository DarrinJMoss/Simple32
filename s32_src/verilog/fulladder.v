`timescale 1ps/1ps

// Full-adder for one bit
module FullAdder (
    input                   a,
    input                   b,
    input                   c_In,
    output                  result,
    output                  c_Out
);  
    assign result = a ^ b ^ c_In;
    assign c_Out  = (a & b) | ((a ^ b) & c_In);
endmodule

// n-bit full-adder
module FullAdder_N #(
    // Allows the programmer to specify the size of the adder
    parameter               BIT_N = 8
) (
    input  [BIT_N - 1 : 0]  addendA,
    input  [BIT_N - 1 : 0]  addendB,
    input                   isSub,
    output [BIT_N - 1 : 0]  result,
    
    output                  fl_Carry,
    output                  fl_Zero,
    output                  fl_Overflow,
    output                  fl_Negative,
);
    // Since we can accept and aribtrary bit size, we have to generate a full adder for each bit in the size (BIT_N)
    genvar i;
    generate
        wire [BIT_N - 1: 0] carry;
        wire [BIT_N - 1: 0] resWire; // Result stored as a wire to allow for the zero-flag check

        // Instantiate BIT_N full adders
        for (i = 0; i < BIT_N; i = i + 1) begin
            // Invert our input for the subtrahend if we want to subtract instead (2's complement)
            wire operationB;
            assign operationB = addendB[i] ^ isSub;
            
            // First bit in sequence
            if (i == 0) begin // Apply the +1 of the 2's complement if we want to subtract, otherwise ignore the first carry
                FullAdder Op (.a(addendA[i]), .b(operationB), .c_In(isSub),         .c_Out(carry[i]), .result(resWire[i]));
            end else begin
                FullAdder Op (.a(addendA[i]), .b(operationB), .c_In(carry[i - 1]),  .c_Out(carry[i]), .result(resWire[i]));
            end
        end

        // Carry flag
        assign fl_Carry = carry[BIT_N - 1];

        // Zero flag
        assign fl_Zero = ~| resWire;

        // Overflow flag
        assign fl_Overflow = carry[BIT_N - 2] ^ carry[BIT_N - 1];

        // Negative flag
        assign fl_Negative = resWire[BIT_N - 1];

        assign result = resWire;
    endgenerate

endmodule
`timescale 1ps/1ps

package Types;

    // Structure containing all of the ALU output flags in one place.
    typedef struct packed {
        // Set if the result has a carry bit. This also works to determine unsigned overflow.
        logic carry;
        // Set if the result from an operation equals zero.
        logic zero;
        // Set if the operation results in signed overflow.
        logic overflow;
        // Set if the operation is negative if the operation is assumed to be a signed operation.
        logic negative;
    } ResultFlags;

endpackage

#include "VFullAdder_Nbit.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>

#include "s32tb_utils.h"

#define BIT_CNT 4
constexpr int32_t BIT_SIZE = (0b1 << (BIT_CNT));

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
    VerilatedContext* context = new VerilatedContext;
    context->commandArgs(argc, argv);
    context->traceEverOn(true);

    // Create the simulated hardware module.
    VFullAdder_Nbit* adder = new VFullAdder_Nbit{context};

    VerilatedVcdC* tfp = new VerilatedVcdC;
    adder->trace(tfp, 99);
    tfp->open("sim/full_adder/full_adder.vcd");

    // For the vivado experience
#ifdef _VIVADO_MOMENT
    printf("Executing the elaborate step..."); fflush(stdout); sleep(5);
#endif

    FILE *fptr; fptr = fopen("sim/full_adder/full_adder_tb.csv", "w");
    bool write_ok = true;
    if (fptr == NULL) {
        write_ok = false;
        fprintf(stderr, "Error could not open nor create file full_adder_tb.csv. Writing to stdout instead.");
        fptr = stdout;
    }

    fprintf(fptr, "ADDITION:\n");
    fprintf(fptr, "LHS,RHS,Result,Carry,Overflow,Bin LHS,Bin RHS,Bin Result\n");
    adder->do_subtraction = 0;
    unsigned int t = 0;
    for (int32_t a_i = 0; a_i < BIT_SIZE; a_i++) {
        for (int32_t b_i = 0; b_i < BIT_SIZE; b_i++) {
            adder->addend_a = a_i;
            adder->addend_b = b_i;
            adder->eval();

            printf("%d + %d = %d\n", adder->addend_a, adder->addend_b, adder->result_o);

            fprintf(fptr, "%d,%d,%d,%u,%u,", 
                adder->addend_a, 
                adder->addend_b, 
                adder->result_o, 
                adder->flag_carry_o,
                adder->flag_overflow_o
            );
            fprintf_binary(fptr, adder->addend_a, BIT_CNT, ",");
            fprintf_binary(fptr, adder->addend_b, BIT_CNT, ",");
            fprintf_binary(fptr, adder->result_o, BIT_CNT, "\n");

            tfp->dump(t);
            t++;
        }
    }

    fprintf(fptr, "\n\n");
    printf("\n\n");

    fprintf(fptr, "SUBTRACTION:\n");
    fprintf(fptr, "LHS,RHS,Result,Carry,Overflow,Bin LHS,Bin RHS,Bin Result\n");
    adder->do_subtraction = 1;
    for (int32_t a_i = 0; a_i < BIT_SIZE; a_i++) {
        for (int32_t b_i = 0; b_i < BIT_SIZE; b_i++) {
            adder->addend_a = a_i;
            adder->addend_b = b_i;
            adder->eval();

            printf("%d - %d = %d\n", SIGNED(adder->addend_a, BIT_CNT), SIGNED(adder->addend_b, BIT_CNT), SIGNED(adder->result_o, BIT_CNT));

            fprintf(fptr, "%d,%d,%d,%u,%u,", 
                SIGNED(adder->addend_a, BIT_CNT), 
                SIGNED(adder->addend_b, BIT_CNT), 
                SIGNED(adder->result_o, BIT_CNT), 
                adder->flag_carry_o,
                adder->flag_overflow_o
            );
            fprintf_binary(fptr, adder->addend_a, BIT_CNT, ",");
            fprintf_binary(fptr, adder->addend_b, BIT_CNT, ",");
            fprintf_binary(fptr, adder->result_o, BIT_CNT, "\n");

            tfp->dump(t);
            t++;
        }
        
    }

    if (write_ok) {
        printf("Finished writing output to sim/full_adder/full_adder_tb.csv\n");
    }

    // Release the simulation.
    adder->final();
    tfp->close();

    delete adder;
    delete tfp;
    delete context;

    return 0;
}

#include "VFullAdder_Nbit.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

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

    adder->do_subtraction = 0;
    unsigned int t = 0;
    for (uint8_t a_i = 0; a_i < 0b1000; a_i++) {
        for (uint8_t b_i = 0; b_i < 0b1000; b_i++) {
            adder->addend_a = a_i;
            adder->addend_b = b_i;
            adder->eval();

            printf("%u + %u = %u | Carry: %u Overflow: %u\n", 
                adder->addend_a, 
                adder->addend_b, 
                adder->result_o, 
                adder->flag_carry_o,
                adder->flag_overflow_o
            );
            
            tfp->dump(t);
            t++;
        }
    }

    printf("\n***\n\n");

    adder->do_subtraction = 1;
    for (uint8_t a_i = 0; a_i < 0b1000; a_i++) {
        for (uint8_t b_i = 0; b_i < 0b1000; b_i++) {
            adder->addend_a = a_i;
            adder->addend_b = b_i;
            adder->eval();

            printf("%u - %u = %u | Carry: %u Overflow: %u\n", 
                adder->addend_a, 
                adder->addend_b, 
                adder->result_o, 
                adder->flag_carry_o,
                adder->flag_overflow_o
            );

            tfp->dump(t);
            t++;
        }
        
    }

    // Release the simulation.
    adder->final();
    tfp->close();

    delete adder;
    delete tfp;
    delete context;

    return 0;
}

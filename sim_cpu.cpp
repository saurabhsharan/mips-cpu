// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtop.h"

int main(int argc, char** argv, char** env) {
    // Construct the Verilated model, from Vtop.h generated from Verilating "top.v"
    Vtop* top = new Vtop;

    // Simulate until $finish
    while (!Verilated::gotFinish()) {

        // Evaluate model
        top->eval();
    }

    // Final model cleanup
    top->final();

    // Destroy model
    delete top;

    // Fin
    exit(0);
}


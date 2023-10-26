#include <verilated.h>
#include <verilated_vcd_c.h>
#include <stdio.h>
#include <assert.h>
#include <VRocket__Dpi.h>
#include <svdpi.h>
#include <VRocket___024root.h>
#include <VRocket.h>

static VRocket *dut;
#ifdef WAVEFORM
VerilatedContext *contextp = NULL;
VerilatedVcdC *tfp = NULL;
#endif

void step()
{
    dut->clock = 0;
    dut->eval();
#ifdef WAVEFORM
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
    dut->clock = 1;
    dut->eval();
#ifdef WAVEFORM
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
}

/*
void load_prog(const char *bin) {
    FILE *fp = fopen(bin, "r");
    int ret = fread(&dut->rootp->Core__DOT__ifu__DOT__M__DOT__M_ext__DOT__Memory, 1, 1024, fp);
    assert(ret);
    fclose(fp);
}
*/

void sim_init()
{
    dut = new VRocket;
#ifdef WAVEFORM
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    contextp->traceEverOn(true);
    dut->trace(tfp, 1);
    tfp->open("dump.vcd");
#endif // DEBUG
    dut->reset = 0;
    dut->clock = 0;
}

void reset(int n) 
{ 
    dut->reset = 1; 
    while (n --) { step(); } 
    dut->reset = 0; 
}

int main(int argc, char *argv[])
{
#ifdef WAVEFORM
    Verilated::traceEverOn(true);
#endif
    Verilated::commandArgs(argc, argv);
    sim_init();
    // load_prog(argv[1]);
    reset(4);

    int counter = 0;
    while (1){ step(); printf("cycle: %d\n",counter); counter ++; }
    
#ifdef WAVEFORM
	tfp->close();
#endif
    return 0;
}

#include <stdint.h>
#include <iostream>
#include <signal.h>

#include "Vcore_sim.h"
#include "verilated_vcd_c.h"


static bool done = false;

vluint64_t main_time = 0;

double sc_time_stamp () {
 return main_time;
}

void INThandler(int signal)
{
  printf("\nCaught ctrl-c\n");
  done = true;
}

int main(int argc, char** argv) {

  Verilated::commandArgs(argc, argv);
  Vcore_sim* tb = new Vcore_sim;

  // init trace dump
  VerilatedVcdC* tfp = NULL;
  const char *vcd = Verilated::commandArgsPlusMatch("vcd=");
  if (atoi(vcd+5)) {
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    tb->trace (tfp, 99);
    tfp->open ("trace.vcd");
  }

  signal(SIGINT, INThandler);

  vluint64_t timeout = 0;
  const char *arg_timeout = Verilated::commandArgsPlusMatch("max_cycles=");
  if (arg_timeout[0])
    timeout = atoi(arg_timeout+12);

  vluint64_t vcd_start = 0;
  const char *arg_vcd_start = Verilated::commandArgsPlusMatch("vcd_start=");
  if (arg_vcd_start[0])
    vcd_start = atoi(arg_vcd_start+11);

  bool dump = false;
  tb->clk = 1;

  // Simulate 
  while (!(done || Verilated::gotFinish())) {
    if (tfp && !dump && (main_time > vcd_start)) {
      dump = true;
    }
    tb->rst = main_time < 100;
    tb->eval();
    if (dump)
      tfp->dump(main_time);
    if (timeout && (main_time >= timeout)) {
      printf("Timeout: Exiting after %lu cycles\n", main_time/10);
      done = true;
    }
    tb->clk = !tb->clk;
    main_time+=5;
  }

  if (tfp)
    tfp->close();

  exit(EXIT_SUCCESS);
}
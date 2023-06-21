

verilator 		?= verilator
ver-library 	?= ver_work
defines 		?= 

# default command line arguments
imem 			?= sw/gcd.mem
max_cycles  	?= 1000000
vcd 			?= 0

src := bench/core_sim.v 	\
	   rtl/*.v

verilate_command := $(verilator) +define+$(defines) 	\
					--cc $(src)							\
					--top-module core_sim				\
					-Wno-TIMESCALEMOD 					\
					-Wno-MULTIDRIVEN 					\
					-Wno-CASEOVERLAP					\
					-Wno-WIDTH 							\
					-Wno-LATCH							\
					-Wno-UNOPTFLAT						\
					-Wno-LATCH							\
					-Wno-IMPLICIT						\
					-Wno-fatal                       	\
					-Wno-PINCONNECTEMPTY  				\
					-Wno-ASSIGNDLY                     	\
					-Wno-DECLFILENAME                	\
					-Wno-UNUSED                        	\
					-Wno-BLKANDNBLK                   	\
					-Wno-style                        	\
					--Mdir $(ver-library)				\
					--exe bench/core_tb.cpp				\
					--trace-structs --trace

verilate:
	@echo "Building verilator model"
	$(verilate_command)
	cd $(ver-library) && $(MAKE) -f Vcore_sim.mk

clean:
	rm -rf *.vcd ver_work/
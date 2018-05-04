START = 1280
PROJ = test

.PHONY: all
all: $(PROJ).bin $(PROJ).tap #$(PROJ).dsk

%.bin: %.s
	xa -M -bt $(START) -DPROG_START=$(START) -l$@.sym -o $@ $<

%.tap: %.bin
	header -a0 -h1 -s0 $< $@ $(START)

%.dsk: %.tap
	tap2dsk -n$(PROJ) $< $@

.PHONY: clean
clean:
	rm -f *.tap *.bin *.dsk *.sym

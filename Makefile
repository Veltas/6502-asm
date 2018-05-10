START = 1280

.PHONY: all
all: zapp.tap #zapp.dsk

zapp.bin: *.s atmos/*.s atmos/*.inc
	xa -M -bt $(START) -DPROG_START=$(START) -l$@.sym -o $@ obj.s

zapp.tap: zapp.bin
	header -a0 -h1 -s0 $< $@ $(START)

zapp.dsk: zapp.tap
	tap2dsk -n$(PROJ) $< $@

.PHONY: clean
clean:
	rm -f *.tap *.bin *.dsk *.sym

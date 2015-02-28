root = ../../../..
cc = $(root)/bin/zcc -I$(root)/src/zinclude

ALL: $(root)/.work/ledrom_romonly.vhd

# led	
$(root)/.work/led.psm : led.c
	$(cc) led.c > $(root)/.work/led.psm
$(root)/.work/ledrom_romonly.vhd : $(root)/.work/led.psm
	cd $(root)/.work && ../bin/zas ledrom led.psm
	

cc = ../bin/zcc -I../src/zinclude

ALL: ../.work/ethrxrom_romonly.vhd \
	../.work/ethtxrom_romonly.vhd \
	../.work/dbrom_romonly.vhd

# ethrx	
../.work/ethrx.psm : ../src/example/eth_hub/zsrc/ethrx.c
	$(cc) ../src/example/eth_hub/zsrc/ethrx.c > ../.work/ethrx.psm
../.work/ethrxrom_romonly.vhd : ../.work/ethrx.psm
	cd ../.work && ../bin/zas ethrxrom ethrx.psm

# ethtx	
../.work/ethtx.psm : ../src/example/eth_hub/zsrc/ethtx.c
	$(cc) ../src/example/eth_hub/zsrc/ethtx.c > ../.work/ethtx.psm
../.work/ethtxrom_romonly.vhd : ../.work/ethtx.psm
	cd ../.work && ../bin/zas ethtxrom ethtx.psm

# ethdb	
../.work/ethdb.psm : ../src/example/eth_hub/zsrc/ethdb.c
	$(cc) ../src/example/eth_hub/zsrc/ethdb.c > ../.work/ethdb.psm

../.work/dbrom_romonly.vhd : ../.work/ethdb.psm
	cd ../.work && ../bin/zas dbrom ethdb.psm
	
clean:
	rm ../.work/* -f
	
install : ALL
	cp ../.work/ethrxrom_romonly.vhd ../src/example/eth_hub/vhd/ethrx_zcpsm/
	cp ../.work/ethtxrom_romonly.vhd ../src/example/eth_hub/vhd/ethtx_zcpsm/
	cp ../.work/dbrom_romonly.vhd ../src/example/eth_hub/vhd/db_zcpsm/
	
A simple way to test bare metal programs running on Pine64 hosting Allwinner
A64 SoC.

### Downloads
* Sunxi tools (see Makefile)
* Blobs for FEL booting (see Makefile)

### Booting in FEL mode
- Attach the USB A-A to the upper port.
- Do not insert an SD card.
- Boot the board.
- Check its presence:

    $ ./sunxi-tools/sunxi-fel version                                                      
    AWUSBFEX soc=00001689(A64) 00000001 ver=0001 44 08 scratchpad=00017e00 00000000 00000000


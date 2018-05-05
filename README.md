A simple way to test bare metal programs running on Pine64 hosting Allwinner
A64 SoC. FEL mode is not working for now. Instead, u-boot is built and spl
binary is combined with u-boot.itb and dd'ed to SD card.

### 1. Downloads
* Sunxi tools (see Makefile)

### 2. Build u-boot
* Install `swig`
* Built the most recent with
  `gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu`

### 3. ATF
* use apritzel repo



### 3. Booting in FEL mode
- Attach the USB A-A to the upper port.
- Do not insert an SD card.
- Boot the board.
- Check its presence:

    $ ./sunxi-tools/sunxi-fel version                                                      
    AWUSBFEX soc=00001689(A64) 00000001 ver=0001 44 08 scratchpad=00017e00 00000000 00000000


# I didn't like the bsp approach, too heavy, I don't need all the components.
# Here is more controlled step-by-step script
#
# According to http://linux-sunxi.org/A64 I will try FEL booting mode. But
# mainline u-boot SPL does not support it. It has to use 32-bit FEL-capable
# u-boot first that will be combined with mainline u-boot and normal ATF.


tools_dir		= sunxi-tools
fel				= $(tools_dir)/sunxi-fel
blobs			= blobs
apritzel_repo	= https://github.com/apritzel/pine64/blob/master/binaries

###############################################################################
# 1)
# sunxi-tools
###############################################################################

tools:
	git clone https://github.com/linux-sunxi/$(tools_dir)
	$(MAKE) -C $(tools_dir)

###############################################################################
# 2)
# blobs
###############################################################################

blobs:
	mkdir -p $(blobs)
	cd $(blobs) && wget $(apritzel_repo)/bl31.bin
	cd $(blobs) && wget $(apritzel_repo)/sunxi-a64-spl32-ddr3.bin

# Read more on FEL boot mode
# $ sunxi-fel -v -p spl sunxi-a64-spl32-ddr3.bin write 0x44000 /path/to/arm-trusted-firmware/bl31.bin write 0x4a000000 /path/to/u-boot/u-boot.bin reset64 0x44000


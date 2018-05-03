# I didn't like the bsp approach, too heavy, I don't need all the components.
# Here is more controlled step-by-step script
#
# According to http://linux-sunxi.org/A64 I will try FEL booting mode. But
# mainline u-boot SPL does not support it. It has to use 32-bit FEL-capable
# u-boot first that will be combined with mainline u-boot and normal ATF.


tools_dir		= sunxi-tools
fel				= $(tools_dir)/sunxi-fel
blobs			= ./blobs
apritzel_repo	= https://github.com/apritzel/pine64/blob/master/binaries
ub_dir			= u-boot
# xcc				= /opt/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-elf/bin/aarch64-elf-
xcc	= /opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
xcc32 = /opt/gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi/bin/arm-eabi-

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

###############################################################################
# 3)
# U-boot
###############################################################################
ubconfig = sun50i-a64-ddr3-spl_defconfig
# ubconfig = pine64_plus_defconfig

# git clone -b v2018.03 git://git.denx.de/u-boot.git $(ub_dir)
# git clone https://github.com/linux-sunxi/u-boot-sunxi $(ub_dir)
ubclone:
	git clone -b sunxi64-fel32 --single-branch git@github.com:apritzel/u-boot.git $(ub_dir)

ubbuild:
	$(MAKE) -C $(ub_dir) ARCH=arm CROSS_COMPILE=$(xcc32) $(ubconfig)
	$(MAKE) -C $(ub_dir) ARCH=arm CROSS_COMPILE=$(xcc32) -j3

ubclean:
	$(MAKE) -C $(ub_dir) mrproper


###############################################################################
# 4)
# Cat spl and uboot
###############################################################################
spl		= $(blobs)/sunxi-spl-mainline.bin
itb		= $(blobs)/u-boot-mainline.itb
ub_spl	= $(blobs)/uboot-with-spl.bin
ub_bin	= $(ub_dir)/u-boot.bin


splcat:
	cat $(spl) $(itb) > $(ub_spl)


###############################################################################
# 5)
# Boot
###############################################################################
atf				= $(blobs)/bl31.bin

run:
	./$(tools_dir)/sunxi-fel -v -p uboot $(ub_spl) write 0x44000 $(atf) \
		write 0x4a000000 $(ub_bin)

# Read more on FEL boot mode
# $ sunxi-fel -v -p spl sunxi-a64-spl32-ddr3.bin write 0x44000 /path/to/arm-trusted-firmware/bl31.bin write 0x4a000000 /path/to/u-boot/u-boot.bin reset64 0x44000


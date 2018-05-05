# I didn't like the bsp approach, too heavy, I don't need all the components.
# Here is more controlled step-by-step script
#
# According to http://linux-sunxi.org/A64 I will try FEL booting mode. But
# mainline u-boot SPL does not support it. It has to use 32-bit FEL-capable
# u-boot first that will be combined with mainline u-boot and normal ATF.


ub_dir			= u-boot
xcc	= /opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
xcc32 = /opt/gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi/bin/arm-eabi-

###############################################################################
# 1)
# ATF
###############################################################################
atf_dir			= atf
atf_bin			= $(atf_dir)/build/sun50iw1p1/debug/bl31.bin

# turned into submodule
atf_clone:
	git clone -b allwinner --single-branch \
		 https://github.com/apritzel/arm-trusted-firmware.git $(atf_dir)

atf_build:
	$(MAKE) -C $(atf_dir) CROSS_COMPILE=$(xcc) PLAT=sun50iw1p1 DEBUG=1 bl31

###############################################################################
# 2)
# U-boot
# $ make pine64_defconfig
# change environment:
#	default mmc (0:auto) to (1:auto)
# $ make menuconfig
#
# rebuild
###############################################################################
# ubconfig = sun50i-a64-ddr3-spl_defconfig
ubconfig = pine64_plus_defconfig

# git clone https://github.com/linux-sunxi/u-boot-sunxi $(ub_dir)
# git clone -b sunxi64-fel32 --single-branch git@github.com:apritzel/u-boot.git $(ub_dir)

ubclone:
	git clone git://git.denx.de/u-boot.git $(ub_dir)

ubdefconf:
	$(MAKE) -C $(ub_dir) BL31=$(PWD)/$(atf_bin) ARCH=arm CROSS_COMPILE=$(xcc) $(ubconfig)

ubmenuconf:
	$(MAKE) -C $(ub_dir) BL31=$(PWD)/$(atf_bin) ARCH=arm CROSS_COMPILE=$(xcc) menuconfig

ubbuild:
	$(MAKE) -C $(ub_dir) BL31=$(PWD)/$(atf_bin) ARCH=arm CROSS_COMPILE=$(xcc) -j3

ubclean:
	$(MAKE) -C $(ub_dir) mrproper



###############################################################################
# 4)
# Putting all together on an SD card
#
# im_out is 32M large

# Uboot.env does not work if generated from uboot.in, first call 'saveenv' in
# the u-boot shell.
# NO! Size was wrong, it has to be equal to the one specified in menuconf
# 'Environment'
###############################################################################
ub_spl		= $(ub_dir)/u-boot-sunxi-with-spl.bin
im_env		= sd.env
im_part		= sd.boot
im_out		= sd.img
env_in		= uboot.in
env_out		= uboot.env
mkenv		= $(ub_dir)/tools/mkenvimage

define PARTTAB
cat <<@ | sudo fdisk $(im_out)
o
n
p
1


t
83
p
w
@
endef
export PARTTAB


boot:
	dd if=/dev/zero bs=1M count=16 of=$(im_out)
	dd if=$(ub_spl) bs=8k seek=1 conv=notrunc of=$(im_out)
	dd if=/dev/zero bs=1M count=8 of=$(im_part)
	sh -c "$$PARTTAB"
	sudo mkfs.vfat -n BOOT $(im_part)
	$(ub_dir)/tools/mkenvimage -s 0x20000 -o $(env_out) $(env_in)
	mcopy -smnv -i $(im_part) $(env_out) ::
	dd if=$(im_part) bs=1M seek=1 conv=notrunc of=$(im_out)


sd_clean:
	rm -f $(im_part) $(im_out) $(im_env) $(env_out)

flash:
	dd if=$(im_out) of=/dev/mmcblk0 && sync



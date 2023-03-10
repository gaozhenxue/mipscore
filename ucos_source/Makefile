ifndef CROSS_COMPILE
CROSS_COMPILE = mips-sde-elf-
endif

export	CROSS_COMPILE

#########################################################################

TOPDIR	:= $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)
export	TOPDIR

include $(TOPDIR)/config.mk

# order is important here:
SUBDIRS	= user ucos port

LIBS  =	user/user.o ucos/ucos.o port/port.o
#########################################################################

all: inst_rom.om inst_rom.bin inst_rom.asm inst_rom.data

inst_rom.om: depend subdirs $(LIBS) Makefile
	$(CC) -T ram.ld -o $@ $(LIBS) -nostdlib $(LDFLAGS)

inst_rom.bin: inst_rom.om
	mips-sde-elf-objcopy -O binary $< $@

inst_rom.asm: inst_rom.om
	mips-sde-elf-objdump -D $< > $@
inst_rom.data:inst_rom.bin
	./Bin2Mem.exe -f $< -o $@
#########################################################################

depend dep:
	@for dir in $(SUBDIRS) ; do $(MAKE) -C $$dir .depend ; done

subdirs:
	@for dir in $(SUBDIRS) ; do $(MAKE) -C $$dir || exit 1 ; done

clean:
	find . -type f \
		\( -name 'core' -o -name '*.bak' -o -name '*~' \
		-o -name '*.o' -o -name '*.asm' -o -name '*.om' -o -name '*.tmp' -o -name '*.hex' \
		-o -name 'OS.bin' -o -name 'inst_rom.bin' -o -name '*.srec' \
		-o -name '*.mem' -o -name '*.img' -o -name '*.out' \
		-o -name '*.aux' -o -name '*.log' -o -name '*.data' \) -print \
		| xargs rm -f
	rm -f System.map

distclean: clean
	find . -type f \
		\( -name .depend -o -name '*.srec' -o -name '*.bin' \
		-o -name '*.pdf' \) \
		-print | xargs rm -f
	rm -f $(OBJS) *.bak tags TAGS
	rm -fr *.*~

#########################################################################


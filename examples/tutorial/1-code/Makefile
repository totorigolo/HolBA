# cross compiler
# ---------------------------------
-include Makefile.local
ifndef HOLBA_GCC_ARM8_CROSS
  HOLBA_GCC_ARM8_CROSS	= aarch64-linux-gnu-
endif
ifndef HOLBA_GDB
  HOLBA_GDB             = $(HOLBA_GCC_ARM8_CROSS)gdb
endif

CROSS   =$(HOLBA_GCC_ARM8_CROSS)
GDB     =$(HOLBA_GDB)


# settings
# ---------------------------------
NAME	= examples.elf
CFLAGS	= -ggdb3 -std=gnu99 -Wall -fno-builtin
#LDFLAGS = --gc-sections -nostartfiles -nostdlib


# compilation and linking
# ---------------------------------
all: $(NAME).da

%.o: %.asm
	${CROSS}as -o $@ $<

%.o: %.c
	${CROSS}gcc ${CFLAGS} -c -o $@ -fno-stack-protector $<

#$(NAME): ${OBJECTS} entry/entry.o
#	${CROSS}ld $(LDFLAGS) -o $@ -T linkerscript.ld $^

$(NAME):
	${CROSS}gcc -DBAREMETAL= ${CFLAGS} examples.c -o $@

$(NAME).da: $(NAME)
	${CROSS}objdump -d $< > $@


test.elf:
	gcc examples.c -o test.elf

clean:
	rm -f $(NAME) $(NAME).da test.elf



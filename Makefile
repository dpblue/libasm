NAME = libasm.a
LIBSRC = libasm.asm libasm_bonus.asm
LIBOBJS = libasm.o libasm_bonus.o

ASSEMBLER = nasm
CC = gcc -Werror -Wall -Wextra

GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[0;34m
END=\033[0m
BOLD_START=\e[1m
BOLD_END=\e[0m

all: $(NAME) testlib tests/hello-syscall tests/hello-printf
bonus: $(NAME)


tests/hello-syscall.o: tests/hello-syscall.asm
	nasm -f elf64 -g tests/hello-syscall.asm

tests/hello-syscall: tests/hello-syscall.o
	ld -g tests/hello-syscall.o -o tests/hello-syscall

tests/hello-printf.o: tests/hello-printf.asm
	nasm -f elf64 tests/hello-printf.asm

tests/hello-printf: tests/test-printf.c tests/hello-printf.o
	gcc tests/test-printf.c tests/hello-printf.o -o tests/hello-printf


$(LIBOBJS): %.o: %.asm
	$(ASSEMBLER) -f elf64 -g $<

$(NAME): $(LIBOBJS)
	$(AR) -rcs $(NAME) $(LIBOBJS)

testlib: $(NAME) testlib.c
	$(CC) -g3 testlib.c -L . -lasm -o testlib

clean:
	$(RM) *.o
	$(RM) tests/*.o
	
fclean: clean
	$(RM) $(NAME)
	$(RM) testlib
	$(RM) tests/hello-syscall
	$(RM) tests/hello-printf
	
re: fclean
	$(MAKE)

.PHONY: clean fclean re all bonus
all: hello-syscall hello-printf

hello-syscall.o: hello-syscall.asm
	nasm -f elf64 -g hello-syscall.asm

hello-syscall: hello-syscall.o
	ld -g hello-syscall.o -o hello-syscall

hello-printf.o: hello-printf.asm
	nasm -f elf64 hello-printf.asm

hello-printf: test-printf.c hello-printf.o
	gcc test-printf.c hello-printf.o -o hello-printf

clean:
	rm -f hello-syscall.o
	rm -f hello-printf.o

fclean: clean
	rm -f hello-syscall
	rm -f hello-printf
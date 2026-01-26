#include <stdio.h>

extern int print(char *str, ...);
extern int print_1_6(char *str, ...);
extern int print_7(char *str, ...);
extern int print_8(char *str, ...);

void	call_print()
{
	print("Demo program: calling printf() via assembly file\n");
	int retval = print_1_6("Hello world !\n");
	print_1_6("return value of previous printf(): %i\n", retval);
	print_1_6("print address: %p\n", print);
	printf("print address: %p [printf()]\n", print);
	print("printf address: %p\n", printf);
	printf("printf address: %p [printf()]\n", printf);
	print_7("printf_7 (1+6 args): 1:%s 2:%s 3:%s 4:%c 5:%i 6:%s\n", "un", "deux", "3", '4', 5, "six");
	print_8("printf_8 (1+7 args): 1:%s 2:%s 3:%s 4:%s 5:%s 6:%s 7:%s\n", "un", "deux", "3", "4", "5", "6", "sept");
}

int main()
{
	call_print();
}

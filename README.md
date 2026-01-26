Libasm - Mandatory part  |  ade-sarr  |  26-jan-2026
----------------------------------------------------

	• The library must be called libasm.a.
	
	• You must submit a main function that will test your functions and compile with
	  your library to demonstrate that it is functional.
	
	• You must rewrite the following functions in assembly:
		◦ ft_strlen (man 3 strlen)
		◦ ft_strcpy (man 3 strcpy)
		◦ ft_strcmp (man 3 strcmp)
		◦ ft_write (man 2 write)
		◦ ft_read (man 2 read)
		◦ ft_strdup (man 3 strdup, you can call to malloc)
	
	• You must check for errors during syscalls and handle them properly when needed.
	
	• Your code must set the variable errno properly.
	
	• For that, you are allowed to call the extern ___error or errno_location.


Libasm - Bonus part
-------------------

int ft_atoi_base(char *str, char *base)
---------------------------------------
	• Write a function that converts the initial portion of the string pointed to
	  by str into an integer representation.
	
	• str is in a specific base, given as a second parameter.
	
	• Except for the base rule, the function should behave exactly like ft_atoi.
	
	• If an invalid argument is provided, the function should return 0.
	  Examples of invalid arguments:
		◦ The base is empty or has only one character.
		◦ The base contains duplicate characters.
		◦ The base contains +, -, or whitespace characters.

-------------------------------------------------------------
The linked list functions will use the following structure:
----------------
	typedef struct	s_list
	{
		void 			*data;
		struct s_list	*next;
	}				t_list;
-------------------------------------------------------------

void ft_list_push_front(t_list **begin_list, void *data)
----------------
	• Create the function ft_list_push_front, which adds a new element of type
	  t_list to the beginning of the list.
	• It should assign data to the given argument.
	• If necessary, it will update the pointer at the beginning of the list.

int ft_list_size(t_list *begin_list)
----------------
	• Create the function ft_list_size, which returns the number of elements
	  in the list.

void ft_list_sort(t_list **begin_list, int (*cmp)(void *d1, void *d2))
----------------
	• Create the function ft_list_sort which sorts the list’s elements in ascending
	  order by comparing two elements and their data using a comparison function.
	• The function pointed to by cmp will be used as:
	  (*cmp)(list_ptr->data, list_other_ptr->data)

void ft_list_remove_if(t_list **begin_list, void *data_ref,
						 int (*cmp)(void *d1, void *data_ref), void (*free_fct)(void *d1))
----------------
	• Create the function ft_list_remove_if which removes from the list all elements
	  whose data, when compared to data_ref using cmp, causes cmp to return 0.
	• The data from an element to be erased should be freed using free_fct.
	• The functions pointed to by cmp and free_fct will be used as:
	  (*cmp)(list_ptr->data, data_ref)
	  (*free_fct)(list_ptr->data)

 
------------------------------------------
 System V ABI (x86-64 calling convention)
------------------------------------------
	This is a 64-bit platform. The stack grows downwards. Parameters to functions
	are passed in the registers rdi, rsi, rdx, rcx, r8, r9, and further values are
	passed on the stack in reverse order. Parameters passed on the stack may be
	modified by the called function. Functions are called using the call instruction
	that pushes the address of the next instruction to the stack and jumps to the
	operand. Functions return to the caller using the ret instruction that pops a
	value from the stack and jump to it. The stack is 16-byte aligned just before
	the call instruction is called.

	Functions preserve the registers rbx, rsp, rbp, r12, r13, r14, and r15;
	while rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11 are scratch registers.
	The return value is stored in the rax register, or if it is a 128-bit value,
	then the higher 64-bits go in rdx.

	Syscall:
		rax = the fonction number to call (0: read, 1: write, ...) 
		args: rdi, rsi, rdx, r10, r8, r9 (rcx is used to store the return addr)
---------------------------------------
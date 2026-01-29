#include "libasm_bonus.h"
#include "colors.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>


void	test_ft_read_write_strcpy()
{
	static const char * const ft_msg = "[libasm] Enter a phrase and terminate by enter\n[ft_read()]  ";
	int buflen = 256;
	char buffer[buflen];
	char buffer2[buflen];
	char buffer3[buflen];
	
	ft_write(1, ft_msg, ft_strlen(ft_msg));
	ssize_t readret = ft_read(0, buffer, buflen-1);
	if (readret < 0) {
		printf("[!] error on ft_read(): %s\n", strerror(errno));
		return;
	}
	else
		printf(" (%li bytes read)\n", readret);
	
	buffer[readret] = '\0';
	ft_strcpy(buffer3, ft_strcpy(buffer2, buffer));
	
	ft_write(1, "[ft_write()] ", 13);
	ssize_t writeret = ft_write(1, buffer3, readret);
	if (writeret < 0) {
		printf("[!] error on ft_write(): %s\n", strerror(errno));
		return;
	}
	if ((readret = ft_read(1000, buffer3, 10)) < 0)
		printf("[test bad fd=1000] error on ft_read(): %s\n", strerror(errno));
	else
		printf("[test bad fd=1000] NO error on ft_read(), test fails ! (returns: %li)\n", readret);
	if ((writeret = ft_write(1000, buffer3, 10)) < 0)
		printf("[test bad fd=1000] error on ft_write(): %s\n", strerror(errno));
	else
		printf("[test bad fd=1000] NO error on ft_write(), test fails ! (returns: %li)\n", writeret);
}

void	test_libc()
{
	static const char * const reg_msg = "[libc] Enter a phrase and terminate by enter\n[read()]  ";
	int buflen = 256;
	char buffer[buflen];
	
	write(1, reg_msg, strlen(reg_msg));
	ssize_t readret = read(0, buffer, buflen-1);
	if (readret < 0) {
		printf("[!] error on read(): %s\n", strerror(errno));
		return;
	}
	else
		printf(" (%li bytes read)\n", readret);
	
	ft_write(1, "[write()] ", 10);
	ssize_t writeret = write(1, buffer, readret);
	if (writeret < 0) {
		printf("[!] error on write(): %s\n", strerror(errno));
		return;
	}
	
	if ((readret = read(1000, buffer, 10)) < 0)
		printf("[test bad fd=1000] error on read(): %s\n", strerror(errno));
	else
		printf("[test bad fd=1000] NO error on read(), test fails ! (returns: %li)\n", readret);
	if ((writeret = write(1000, buffer, 10)) < 0)
		printf("[test bad fd=1000] error on write(): %s\n", strerror(errno));
	else
		printf("[test bad fd=1000] NO error on write(), test fails ! (returns: %li)\n", writeret);
}

void	test_ft_strcmp()
{
	char *strs[] = {
		"abcd", "abCd",
		"Identique", "Identique ?",
		"A B C", "A B C",
		"cheval", "chevaux",
	};
	int nbtests = sizeof(strs) / (2 * sizeof(char *));
	
	for (int t=0; t < nbtests; t++)
	{
		int i = t*2;
		printf("ft_strcmp(\""NORM"%s"BRIGHT DARK"\", \""NORM"%s"BRIGHT DARK"\") = "NORM BRIGHT"%i"BRIGHT DARK"\n",
			strs[i], strs[i+1], ft_strcmp(strs[i], strs[i+1]));
		printf("   strcmp(\""NORM"%s"BRIGHT DARK"\", \""NORM"%s"BRIGHT DARK"\") = "NORM"%i"BRIGHT DARK"\n",
			strs[i], strs[i+1], strcmp(strs[i], strs[i+1]));
	}
}

void	test_ft_strdup()
{
	char *str = "Chaine de caractères de test pour ft_strdup()";
	char *str2, *str3;

	printf("ft_strdup(\"%s\"):\n          \"%s\"\n", str, str3 = ft_strdup(str2 = ft_strdup(str)));
	free(str3);
	free(str2);
}

void 	test_get_valid_base(const char *const *base)
{
	for (; *base; base++)
		printf("get_valid_base(\""NORM"%s"BRIGHT DARK"\") = "NORM"%i"BRIGHT DARK"\n",
			*base, get_valid_base(*base));
}

void	print_ft_atoi_base(const char *const strnum, const char *const base)
{
	printf("ft_atoi_base(\""NORM"%1$s"BRIGHT DARK"\", \""NORM"%2$s"BRIGHT DARK"\") = "NORM"%3$8i (%3$#x)"BRIGHT DARK"\n",
			strnum, base, ft_atoi_base(strnum, base));
}

void	test_ft_atoi_base()
{
	const char *const bases[] = {"", "a", "ab", "ndt", "tnt", "abc+", "abc0^/*", NULL};
	test_get_valid_base(bases);

	printf("\n");
	print_ft_atoi_base("", "");
	print_ft_atoi_base("2", "01");
	print_ft_atoi_base("OOOXXX", "OX"); // 7
	print_ft_atoi_base("42", "24");  // 2
	print_ft_atoi_base("07@@", "0@x7"); // 53
	print_ft_atoi_base("11110000", "01"); // 240
	print_ft_atoi_base("|......|", ".|"); // 129
	print_ft_atoi_base("      42", "0123456780");
	print_ft_atoi_base(" -1     ", "0123456789");
	print_ft_atoi_base(" +1     ", "0123456789");
	print_ft_atoi_base("  109   ", "0123456789");
	print_ft_atoi_base("    123x", "0123456789");
	print_ft_atoi_base("abcde   ", "abcdefghij");  // 1234
	print_ft_atoi_base("42424242", "0123456789");  // 42424242
	print_ft_atoi_base("42424242", "9876543210");  // 57575757
	printf(ITALIC);
	print_ft_atoi_base("    r2d2", ".r2maideux");  // 1262
	printf(NITALIC);
	print_ft_atoi_base("ffff0000", "0123456789abcdef"); // -65536
	print_ft_atoi_base("0000ffff", "0123456789abcdef"); //  65535
	print_ft_atoi_base("ffffff00", "0123456789abcdef"); //   -256
	print_ft_atoi_base("   00a00", "0123456789abcdef"); //   2560
	print_ft_atoi_base("     -80", "0123456789abcdef"); //   -128
	print_ft_atoi_base("      -f", "0123456789abcdef"); //    -15
	print_ft_atoi_base("     -10", "0123456789abcdef"); //    -16
	print_ft_atoi_base("    <!?>", "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$&~^%*#\\|/@={}()[]_<>?!."); // 52149020
	printf("ft_atoi_base(\""NORM" \\t \\n\\r  \\f\\v  42 24"BRIGHT DARK"\", \""NORM"%s"BRIGHT DARK"\") = "NORM"%i"BRIGHT DARK"\n",
			"0123456789", ft_atoi_base(" \t \n\r  \f\v  42 24", "0123456789"));
}

void	print_list(char *prefix, t_list *list, char *postfix)
{
	if (list == NULL)
		return;
	printf("%s", prefix);
	while (list)
	{
		if (list->data)
			printf(" `%s`", (char *)list->data);
		else
			printf(" <null>");
		list = list->next;
	}
	printf("%s", postfix);
}

void	freelist(t_list *list, void(*freedata)(void *data))
{
	t_list	*elem;
	while (list)
	{
		elem = list;
		list = list->next;
		freedata(elem->data);
		free(elem);
	}
}

// return zero if true; non-zero if false
int	strcmp_begin_with(void *str, void *begin)
{
	if (str == NULL && begin == NULL)
		return 0;
	if (str == NULL || begin == NULL)
		return -1;
	return ft_strncmp(str, begin, ft_strlen(begin));
}

void	test_ft_list()
{
	t_list	*list = NULL;
	
	ft_list_push_front(&list, ft_strdup("One"));
	ft_list_push_front(&list, ft_strdup("_REM_ Two "));
	ft_list_push_front(&list, ft_strdup("1"));
	ft_list_push_front(&list, NULL);
	ft_list_push_front(&list, ft_strdup("Two"));
	ft_list_push_front(&list, ft_strdup("42"));
	ft_list_push_front(&list, ft_strdup("libasm"));
	ft_list_push_front(&list, NULL);
	ft_list_push_front(&list, ft_strdup("shecat"));
	ft_list_push_front(&list, ft_strdup("_REM_hello!"));
	ft_list_push_front(&list, ft_strdup("84"));
	print_list(NORM"Unsorted:", list, BRIGHT DARK"\n");
	printf("list_size = %i\n", ft_list_size(list));
	ft_list_sort(&list, (t_cmp)ft_strcmp);
	print_list(NORM"Sorted  :", list, BRIGHT DARK"\n");
	printf("    ft_list_remove_if(&list, \""NORM BRIGHT"84"DARK"\", (t_cmp)ft_strcmp, free);\n");
	printf("    ft_list_remove_if(&list, \""NORM BRIGHT"cat"DARK"\", (t_cmp)ft_strcmp, free);\n");
	printf("    ft_list_remove_if(&list, "NORM BRIGHT"NULL"DARK", (t_cmp)ft_strcmp, free);\n");
	printf("    ft_list_remove_if(&list, \""NORM BRIGHT"_REM_"DARK"\", strcmp_begin_with, free);\n");
	ft_list_remove_if(&list, "84", (t_cmp)ft_strcmp, free);
	ft_list_remove_if(&list, "cat", (t_cmp)ft_strcmp, free);
	ft_list_remove_if(&list, NULL, (t_cmp)ft_strcmp, free);
	ft_list_remove_if(&list, "_REM_", strcmp_begin_with, free);
	print_list(NORM"Removed :", list, BRIGHT DARK"\n");
	printf("list_size = %i\n", ft_list_size(list));
	freelist(list, free);
}

int	main()
{
	printf("\n"LYELLOW ITALIC UNDERLN"       "NUNDER
		"libasm test: mandatory & bonus"UNDERLN"       "NUNDER"\n\n"END LYELLOW DARK);
	test_ft_strcmp();
	printf("\n");
	test_ft_strdup();
	//test_ft_read_write_strcpy();
	//printf("\n");
	//test_libc();
	printf("\n"END LYELLOW ITALIC UNDERLN"    "NUNDER
		"libasm: ft_atoi_base"UNDERLN"    "NUNDER"\n\n"END LYELLOW DARK);
	test_ft_atoi_base();
		
	printf(END LYELLOW ITALIC UNDERLN"\n    "NUNDER
		"libasm ft_list_xxx: push_front, list_size, list_sort, remove_if"
		UNDERLN"    \n\n"END LYELLOW DARK);
	test_ft_list();
	printf(END);	
}

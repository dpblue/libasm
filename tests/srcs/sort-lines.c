#include "libasm_bonus.h"
#include "get_next_line_bonus.h"
#include <stdio.h>
#include <stdlib.h>

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

int main(int argc, char **argv)
{
	(void)argv;
	t_list	*list = NULL;
	char	*line;

	if (argc > 1) {
		printf("sort-lines reads from stdin and writes to stdout after sorting text lines in ascending order\n"
				"using libasm and a specific version of get_next_line that use libasm.\n");
		return -1;
	}
	
	while ((line = get_next_line(0)))
		ft_list_push_front(&list, line);

	ft_list_sort(&list, (t_cmp)ft_strcmp);

	for (t_list	*elem = list; elem; elem = elem->next)
		ft_write(1, elem->data, ft_strlen(elem->data));

	freelist(list, free);
	get_next_line(GNL_FREE_ALL_BUFFERS);
}

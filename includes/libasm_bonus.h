#ifndef LIBASM_BONUS_H
# define LIBASM_BONUS_H

# include <sys/types.h>

typedef struct	s_list
{
	void 			*data;
	struct s_list	*next;
}				t_list;

typedef int (*t_cmp)(void *, void *);

// Mandatory functions
ssize_t	ft_read (int fd, const void *buf, size_t count);
ssize_t	ft_write(int fd, const void *buf, size_t count);
size_t	ft_strlen(const char *s);
char *	ft_strcpy(char *restrict dst, const char *restrict src);
int		ft_strcmp(const char *s1, const char *s2);
char *	ft_strdup(const char *s);


// Bonus fonctions
int		get_valid_base(const char *const base);
int		ft_atoi_base(const char *const str, const char *const base);
void	ft_list_push_front(t_list **begin_list, void *data);
int		ft_list_size(t_list *begin_list);
void	ft_list_sort(t_list **begin_list, int (*cmp)(void *data1, void *data2));
void	ft_list_remove_if(t_list **begin_list, void *data_ref,
			int (*cmp)(void *datx, void *data_ref), void (*free_fct)(void *datx));

// Additional functions
char *	ft_strchr(const char *str, int c);
char *	ft_skip_chars(char *str, char *chr2skip);

//size_t	ft_strlcpy(char *dst, const char *src, size_t size);
//int		strncmp(const char s1, const char s2, size_t n);
#endif
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_utils_bonus.c                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ade-sarr <ade-sarr@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/05/23 18:50:27 by ade-sarr          #+#    #+#             */
/*   Updated: 2026/01/28 02:10:19 by ade-sarr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

/* GNL with doubly linked list */

#include "get_next_line_bonus.h"
#include <stdlib.h>

/* Libère le buffer utilisé par le file descriptor 'fd', s'il existe.
 * Si 'fd' = 1 ou -1, toute la liste sera libérée.
 * Si fd < 0, la valeur absolue de fd sera utilisée.
*/
void	gnlbuf_release_by_fd(t_gnl_buflst **plist, int fd)
{
	t_gnl_buflst	*node;
	t_gnl_buflst	*next;

	if (fd < 0)
		fd = -fd;
	if (fd == 1)
	{
		node = *plist;
		while (node)
		{
			next = node->next;
			free(node);
			node = next;
		}
		*plist = NULL;
	}
	else
	{
		node = *plist;
		while (node && node->fd != fd)
			node = node->next;
		if (node)
			gnlbuf_release(plist, node);
	}
}

/*
char	*ft_strchr(const char *s, int c)
{
	const unsigned char	chr = c;

	while (*s)
	{
		if (*s == chr)
			return ((char *)s);
		s++;
	}
	if (chr == '\0')
		return ((char *)s);
	return (NULL);
}

size_t	ft_strlen(const char *str)
{
	size_t	len;

	len = 0;
	while (*str)
	{
		str++;
		len++;
	}
	return (len);
}
*/

size_t	ft_strlcpy(char *dst, const char *src, size_t size)
{
	size_t	n;
	size_t	l;

	l = 0;
	if (size > 0)
	{
		n = size - 1;
		while (*src && n)
		{
			*dst++ = *src++;
			n--;
			l++;
		}
		*dst = '\0';
	}
	while (*src++)
		l++;
	return (l);
}

/* ft_strjoin_ex2 : extended version of ft_strjoin
 * Allocates and returns a new string, which is the result of the concatenation
 * of ’s1’ and ’s2’. NULL values accepted and behave like zero length string.
 * Si ’s2endptr’ <> NULL : s2 est pris en compte uniquement jusqu'a ’s2endptr’
 * inclus. Si ’s2endptr’ = NULL : s2 est pris en compte entierement.
*/
char	*ft_strjoin_ex2(char const *s1, char const *s2, char const *s2endptr)
{
	int		s1len;
	int		s2len;
	char	*concat;

	s1len = 0;
	s2len = 0;
	if (s1)
		s1len = ft_strlen(s1);
	if (s2 && !s2endptr)
		s2len = ft_strlen(s2);
	if (s2 && s2endptr)
		s2len = s2endptr - s2 + 1;
	concat = malloc(s1len + s2len + 1);
	if (concat == NULL)
		return (NULL);
	concat[0] = '\0';
	if (s1)
		ft_strlcpy(concat, s1, s1len + 1);
	if (s2)
		ft_strlcpy(concat + s1len, s2, s2len + 1);
	return (concat);
}

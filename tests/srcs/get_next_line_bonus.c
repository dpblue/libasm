/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line_bonus.c                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ade-sarr <ade-sarr@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/05/23 18:49:28 by ade-sarr          #+#    #+#             */
/*   Updated: 2026/01/28 01:59:58 by ade-sarr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

/* GNL with doubly linked list
 * ===========================
 * Après usage de get_next_line(fd), il est fortement recommandé d'appeler
 * get_next_line(-fd) pour libérer la mémoire du buffer associé au fichier fd.
 * Cette mémoire est automatiquement libérée lorsque la fin du fichier est
 * atteinte mais si la lecture du fichier est incomplète, cela n'est pas le cas.
 * Si le dernier appel à get_next_line(fd) a renvoyé NULL alors il n'est pas
 * necessaire d'appeler get_next_line(-fd) (car fin de fichier atteinte).
 * Un appel à get_next_line(-1) permettra de s'assurer que toute la mémoire
 * liée à la gestion des buffer de tous les fichiers a bien été libérée.
*/

#include "get_next_line_bonus.h"
#include <stdlib.h>
#include <stdbool.h>

/* Returns 'fd' buffer node from doubly linked list 'plist'
 * if not found in 'plist', create and add new node for 'fd' in front of 'plist'
*/
static t_gnl_buflst	*gnlbuf_get(t_gnl_buflst **plist, int fd)
{
	t_gnl_buflst	*node;

	node = *plist;
	while (node && node->fd != fd)
		node = node->next;
	if (node)
		return (node);
	node = malloc(sizeof(t_gnl_buflst));
	if (node == NULL)
		return (NULL);
	node->bufnextline = NULL;
	node->fd = fd;
	node->pred = NULL;
	node->next = *plist;
	if (*plist)
		(*plist)->pred = node;
	*plist = node;
	return (node);
}

//void gnlbuf_add(t_gnl_buflst **plist, t_gnl_buflst *node)

/* Remove node from 'plist' and free node memory
*/
void	gnlbuf_release(t_gnl_buflst **plist, t_gnl_buflst *node)
{
	if (node->next)
		node->next->pred = node->pred;
	if (node->pred)
		node->pred->next = node->next;
	if (node == *plist)
		*plist = node->next;
	free(node);
}

/* Alloue et renvoie une nouvelle chaine résultante de la concaténation de
 * 'line' et de 'buffer'. Si 'bufendline' <> NULL, 'buffer' ne sera considéré
 * que jusqu'à 'bufendline' inclus.
 * [out] *pbufnextline pointera sur le début de la prochaine ligne dans 'buffer'
 * Si 'buffer' est épuisé (cad si 'bufendline' == NULL ou si 'bufendline'
 * est le dernier caratère dans 'buffer'), *pbufnextline sera mis à NULL.
 * 'line' peut etre NULL => meme retour que si 'line' était de longueur nulle.
 * NB : si line <> NULL, 'line' sera désalloué (avec free) apres concaténation.
*/
static char	*gnl_concat(char *line, const char *buffer, const char *bufendline,
					char **pbufnextline)
{
	char	*sjoin;

	sjoin = ft_strjoin_ex2(line, buffer, bufendline);
	if (line)
		free(line);
	*pbufnextline = (char *)bufendline;
	if (*pbufnextline)
		if (!*++*pbufnextline)
			*pbufnextline = NULL;
	return (sjoin);
}

/* Read next line from 'buffer' and/or file descriptor ('fd')
*/
static char	*gnl_read(int fd, char *buffer, char **pbufnextline, bool *eof)
{
	char		*line;
	char		*endline;
	ssize_t		nb_read;

	*eof = true;
	line = NULL;
	endline = NULL;
	if (*pbufnextline)
	{
		endline = ft_strchr(*pbufnextline, '\n');
		line = gnl_concat(line, *pbufnextline, endline, pbufnextline);
	}
	while (!endline)
	{
		nb_read = ft_read(fd, buffer, BUFFER_SIZE);
		if (nb_read == 0)
			return (line);
		if (nb_read < 0)
			return (free(line), NULL);
		buffer[nb_read] = '\0';
		endline = ft_strchr(buffer, '\n');
		line = gnl_concat(line, buffer, endline, pbufnextline);
	}
	*eof = false;
	return (line);
}

/* Renvoie la ligne suivante pour le file descriptor 'fd'.
 * Exploite une liste doublement chainée de buffer de type t_gnl_buflst.
 * Un appel avec 'fd' < 0 renvoie toujours NULL et permet de libérer le buffer
 * du fd égal à la valeur absolue de 'fd' (voir gnlbuf_release_by_fd).
 * Si 'fd' = -1, toute la liste des buffer sera libérée.
 * Si fin de fichier ('eof') le buffer associé est automatiquement libéré.
*/
char	*get_next_line(int fd)
{
	static t_gnl_buflst	*bufferlist = NULL;
	t_gnl_buflst		*node;
	char				*line;
	bool				eof;

	if (fd < 0)
	{
		gnlbuf_release_by_fd(&bufferlist, -fd);
		return (NULL);
	}
	node = gnlbuf_get(&bufferlist, fd);
	if (node == NULL)
		return (NULL);
	line = gnl_read(fd, node->buffer, &node->bufnextline, &eof);
	if (eof)
		gnlbuf_release(&bufferlist, node);
	return (line);
}

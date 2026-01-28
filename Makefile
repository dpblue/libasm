LIBNAME		=  libasm.a

SRCS		+= libasm.asm
SRCS		+= libasm_bonus.asm

SORTLINES	=  sort-lines

GNL_SRCS	+=  get_next_line_bonus.c
GNL_SRCS	+=  get_next_line_utils_bonus.c

TEST_SRCS	+= testlib.c
TEST_SRCS	+= $(SORTLINES).c

INCLUDES	= -I includes
LIBASM		= -L. -lasm

DIR_SRC		= srcs
DIR_OBJ		= objs
DIR_TEST	= tests
DIR_TEST_SRC = $(DIR_TEST)/srcs
DIR_TEST_OBJ = $(DIR_TEST)/objs

vpath %.asm $(DIR_SRC)
vpath %.c $(DIR_TEST_SRC)

OBJS = $(patsubst %.asm, $(DIR_OBJ)/%.o, $(SRCS))
GNL_OBJS  = $(patsubst %.c, $(DIR_TEST_OBJ)/%.o, $(GNL_SRCS))
TEST_OBJS = $(patsubst %.c, $(DIR_TEST_OBJ)/%.o, $(TEST_SRCS))
TEST_EXES = $(patsubst %.c, $(DIR_TEST)/%, $(TEST_SRCS))

GREEN=\e[0;32m
RED=\e[0;31m
BLUE=\e[0;34m
BRIGHT=\e[1m
END=\e[0m

ASSEMBLER = nasm -f elf64
ASM_OPT = -g

CC = gcc -Werror -Wall -Wextra
CC_OPT = -g3

all: $(LIBNAME) tests
bonus: $(LIBNAME)

$(LIBNAME): $(OBJS)
	$(AR) -rcs $(LIBNAME) $(OBJS)

$(DIR_OBJ)/%.o: %.asm
	mkdir -p $(DIR_OBJ)
	$(ASSEMBLER) $(ASM_OPT) $< -o $@

tests: $(TEST_EXES)

# We don't really need this empty rule except to prevent 'make' from deleting
# the intermediate tests objets. The variable TEST_OBJS is not used otherwise.
$(TEST_OBJS):

$(DIR_TEST)/$(SORTLINES): $(DIR_TEST_OBJ)/$(SORTLINES).o $(GNL_OBJS) $(LIBNAME)
	$(CC) $(CC_OPT) $< -o $@ $(GNL_OBJS) $(LIBASM)

$(DIR_TEST)/%: $(DIR_TEST_OBJ)/%.o $(LIBNAME)
	$(CC) $(CC_OPT) $< -o $@ $(LIBASM)

$(DIR_TEST_OBJ)/%.o: %.c
	mkdir -p $(DIR_TEST_OBJ)
	$(CC) $(CC_OPT) $(INCLUDES) -c $< -o $@


clean:
	$(RM) $(DIR_OBJ)/*.o
	$(RM) $(DIR_TEST_OBJ)/*.o
		
fclean: clean
	$(RM) $(LIBNAME)
	$(RM) $(DIR_TEST)/testlib
	$(RM) $(DIR_TEST)/sort-lines
	
re: fclean
	$(MAKE)

.PHONY: clean fclean re all bonus tests
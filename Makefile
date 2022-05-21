CC			=	gcc
CFLAGS		=	-Wall -Wextra -Werror

NAME		=	kuznechiklib
OBJ_DIR		=	obj
SRC_DIR		=	src
SRC			=	main.c
OBJ			=	$(addprefix $(OBJ_DIR)/,$(SRC:.c=.o))
HEADER		=	inc/header.h

.PHONY: all clean fclean re 

$(OBJ_DIR)/%.o:	$(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

all:		$(OBJ_DIR)
	$(MAKE) -j $(NAME)

$(OBJ_DIR):
	mkdir -p $@

$(NAME):	$(OBJ) $(HEADER)
	ar rc $(NAME) $< 
	ranlib $(NAME)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -rf $(NAME)

re:	fclean all


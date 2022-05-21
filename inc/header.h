#ifndef HEADER_H
# define HEADER_H
# define BASE_ADDR 0x10000000
#include <stdbool.h> 
#include <stdint.h>
int	*__FLAGS = (int *)BASE_ADDR;
int	*__DATA_IN = (int *)BASE_ADDR + 0x4;
int	*__DATA_OUT = (int *)BASE_ADDR + 0xE;

void	set_reset(bool in);
void	set_req(bool in);
void	set_data_in(int arr[4]);
uint32_t	get_bytes(void);
int	get_busy(void);
uint32_t	*get_data_out(void);

#endif

#include "../inc/header.h"

void	set_reset(bool in)
{
	uint32_t fst;
	static uint32_t	*rst = (uint32_t *)BASE_ADDR;
	fst = *rst;
	fst = (fst & (~1)) | ((int) in);
	*rst = fst;
}

void	set_req(bool in)
{
	uint32_t fst;
        static uint32_t *rst = (uint32_t *)BASE_ADDR;
        fst = *rst;
        fst = (fst & (~(1 << 1))) | (((int) in) << 1);
        *rst = fst;
}

void	set_data_in(int arr[4])
{
	static uint32_t *data_in = (uint32_t *)BASE_ADDR + 0x4;

	for (int i = 0; i < 4; ++i)
		data_in[i] = arr[i];
}

uint32_t	get_bytes(void)
{
	static uint32_t *bytes = (uint32_t *)BASE_ADDR;

	return (*bytes);
}

uint32_t	*get_data_out(void)
{	
	static uint32_t *data_out = (uint32_t *)BASE_ADDR + 0xE;

	return (data_out);
}

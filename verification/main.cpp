#include <string.h>
#include <sys/time.h>
#include<stdio.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <stdlib.h>
#include <unistd.h>
#include <iostream>
#include <fcntl.h>
#include <sys/time.h>

#define ROM_LEN 32*1024
#define RAM_LEN 128*1024
#define CTRL_LEN 512*1024*1024
#define ROM_START_ADDR    0x40000000
#define RAM_START_ADDR    0x42000000
#define CTRL_START_ADDR   0x60000000



unsigned char *rom;
unsigned char *ram;
unsigned char *ctrl;
int m_fd;


int main()
{
    m_fd = open ("/dev/mem", O_RDWR | O_SYNC);

    rom = (unsigned char *)mmap(0, ROM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, m_fd, ROM_START_ADDR);
    ram = (unsigned char *)mmap(0, RAM_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, m_fd, RAM_START_ADDR);
    ctrl = (unsigned char *)mmap(0, CTRL_LEN, PROT_READ | PROT_WRITE, MAP_SHARED, m_fd, CTRL_START_ADDR);
    unsigned int *control = (unsigned int*)ctrl;
    unsigned int *ram32 = (unsigned int*)ram;

    *((volatile unsigned int *)(control+1)) = 0x00000000;

	FILE* pFile;
	unsigned char buffer[4] = {0};
	unsigned char cmd[4] = {0};
	pFile = fopen("inst_rom.bin", "rb");
    int point = 0;
    while(true)
    {
        int returnsize = fread(buffer, 1, sizeof(buffer), pFile);
        if(returnsize == 0)
        {
            break;
        }
        if(point < 0x73b4)
        {
            cmd[0] = buffer[3];
            cmd[1] = buffer[2];
            cmd[2] = buffer[1];
            cmd[3] = buffer[0];
            memcpy(rom+point,cmd,sizeof(cmd));
            cmd[0] = 0x00;
            cmd[1] = 0x00;
            cmd[2] = 0x00;
            cmd[3] = 0x00;
            memcpy(ram+point,cmd,sizeof(cmd));
        }
        else
        {
            cmd[0] = buffer[3];
            cmd[1] = buffer[2];
            cmd[2] = buffer[1];
            cmd[3] = buffer[0];
            memcpy(ram+point,cmd,sizeof(cmd));
         }
        point += 4;

    }
    printf("rom=%d\n",rom[0]);
    *((volatile unsigned int *)(control+1)) = 0x00000001;
    volatile unsigned int rr;
    while (true)
    {
        rr = ram32[24];
        printf("ram24=%d\n",rr);
        *((volatile unsigned int *)(control+3)) = rr;
        rr = ram32[25];
        *((volatile unsigned int *)(control+4)) = rr;
        printf("ram25=%d\n",rr);
        usleep(500*1000);
    }
    
    return 0;
}

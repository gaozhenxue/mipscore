#include "../include/includes.h"
int global_var;
int a;
#define TASK_STK_SIZE 256
OS_STK TaskStartStk0[TASK_STK_SIZE];
OS_STK TaskStartStk1[TASK_STK_SIZE];
void OSInitTick(void)
{
    INT32U compare = (INT32U)(IN_CLK / OS_TICKS_PER_SEC);
    
    asm volatile("mtc0   %0,$9"   : :"r"(0x0)); 
    asm volatile("mtc0   %0,$11"   : :"r"(compare));  
    asm volatile("mtc0   %0,$12"   : :"r"(0x10000401));
    
    return; 
}
void  TaskStart2 (void *pdata)
{
        int n = 0;
        INT32U add = 0x00000001;
        *((volatile INT32U *)(0x00000064)) = add;
        pdata = pdata;            /* Prevent compiler warning                 */
        while(1)
        {
                OSTimeDly(1);
                n++;
                if(n == 3)
                {
                        n = 0;
                        add = add*2;
                        *((volatile INT32U *)(0x00000064)) = add;
                }

        }
}

void  TaskStart (void *pdata)
{
	OSInitTick();             /* don't put this function in main()        */
	OSTaskCreate(TaskStart2,
               (void *)0,
               &TaskStartStk1[TASK_STK_SIZE - 1],
               1);
	int n = 0;
	INT32U add = 0x00000001;
	*((volatile INT32U *)(0x00000060)) = add;
    	pdata = pdata;            /* Prevent compiler warning                 */
	while(1)
	{	
		OSTimeDly(1);
		n++;
		if(n == 4)
		{
			n = 0;
			add = add*2;
			*((volatile INT32U *)(0x00000060)) = add;
		}
	}
}


void main()
{
	global_var = 0;
	a = 0;
	  OSInit();
	  OSTaskCreate(TaskStart, 
	       (void *)0, 
	       &TaskStartStk0[TASK_STK_SIZE - 1], 
	       0);

	  OSStart();  

}

//typedef unsigned int CPU_INT32U;
//typedef unsigned int volatile OS_CPU_SR;
//typedef int INT32U;

//#define OS_TICKS_PER_SEC	100u
#define IN_CLK			3000000

//void       OSIntCtxSw(void);
//void       OSStartHighRdy(void);
//void       ExceptionHandler(void);
//void       InterruptHandler(void);

//void       TickInterruptClear(void);
//void       CoreTmrInit(CPU_INT32U tmr_reload);
//void       TickISR(CPU_INT32U tmr_reload);
//void       OSTimeTick(void);

//OS_CPU_SR  OS_CPU_SR_Save(void);               /* See os_cpu_a.s*/
//void       OS_CPU_SR_Restore(OS_CPU_SR);       /* See os_cpu_a.s*/

extern int global_var;
extern int a;
extern void main(void);

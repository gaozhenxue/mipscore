# mipscore
使用Verilog实现的32位MIPS架构CPU,并移植ucos到CPU进行运行
# 背景
在进行FPGA的工作当中，为了提高业务水平，锻炼逻辑能力，使用FPGA制作一个MIPS32指令集CPU，并且移植ucos实时操作系统到自制CPU进行运行
# 演示
[验证视频](https://www.bilibili.com/video/BV1H8411n7X4/?spm_id_from=333.999.0.0&vd_source=0582b0da04a26baa6e7035b107b399c2)     [项目文档](https://github.com/gaozhenxue/mipscore/tree/main/doc)
# 项目特色
整个CPU项目除寄存器和D触发器的存储模块外，其余主要逻辑实现全部采用门级描述，放弃行为及描述，大大提高了编程难度，但是更利于未来CPU升级、优化和性能提升
# 目录介绍
* doc 存放项目说明以及测试方法文件  
* mipscore/mips 存放MIPS32指令集CPU源码  
* mipscore/testfiile 存放CPU中各指令仿真测试文件以及编译文件  
* ucos_source 存放移植的ucos源码以及相应的编译文件  
* verification 存放圆形验证的项目工程(由于文件比较大放在百度云中)百度云链接，以及验证板卡中PS端的程序下载程序(main.cpp)
# 实验设备与开发环境
* 仿真
*     使用Xilinx公司vivado2018.3
* 原型验证
*     FPGA开发板一块,为正点原子领航者ZYNQ7020,CPU运行程序不使用传统串口进行下载，使用ZYNQ中PS-PL接口中GP接口进行下载运行程序
* 测试文件以及ucos编译
*     Ubuntu下使用编译器为mips-sde-elf-gcc

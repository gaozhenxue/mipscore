# mipscore
使用Verilog实现的32位MIPS架构CPU,并移植ucos到CPU进行运行
# 背景
在进行FPGA的工作当中，为了提高业务水平，锻炼逻辑能力，使用FPGA制作一个MIPS32指令集CPU，并且移植ucos实时操作系统到自制CPU进行运行
# 演示
[验证视频](https://www.bilibili.com/video/BV1H8411n7X4/?spm_id_from=333.999.0.0&vd_source=0582b0da04a26baa6e7035b107b399c2)     [项目文档](https://github.com/gaozhenxue/mipscore/tree/main/doc)
#项目特色
整个CPU项目全部除寄存器和D触发器的存储模块外，其余主要逻辑实现全部采用门级描述，放弃行为及描述，大大提高了编程难度，但是更利于未来CPU升级、优化和性能提升

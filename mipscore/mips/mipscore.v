`include "defines.v"

module mipscore(

    //与指令rom的接口
	input       [`InstBusWidth-1:0]         rom_data_i,
	output      [`InstAddrBusWidth-1:0]     rom_addr_o,
	output                                  rom_ce_o,
	
    //与数据ram的接口
    output [`DataAddrBusWidth-1:0]          mem_addr_o,
	output                                  mem_we_o,
	output [3:0]				            mem_sel_o,
	output [`RegWidth-1:0]                  mem_data_o,
	output                                  mem_ce_o,
	input  [`RegWidth-1:0]                  mem_data_i,
	
	//exception
	input [5:0]                             int_i,
    output                                  timer_int_o,
    
    
	input	                                clk,
    input                                   rst_n
);
wire[`InstAddrBusWidth-1:0] pc;
//wire[`InstAddrBusWidth-1:0] id_pc_i;
//wire[`InstBusWidth-1:0] id_inst_i;
//连接译码阶段ID模块的输出与ID/EX模块的输入
wire[`AluOpBusWidth-1:0] id_aluop_o;
wire[`AluSelBusWidth-1:0] id_alusel_o;
wire[`RegWidth-1:0] id_reg1_o;
wire[`RegWidth-1:0] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBusWidth-1:0] id_wd_o;
wire                        id_wreg_hi_o;
wire                        id_wreg_lo_o;
wire [`RegWidth-1:0]        id_reg_hi_o;
wire [`RegWidth-1:0]        id_reg_lo_o;
wire                        id_wreg_LLbit_o;
wire                        id_regLLbit_o;
wire [`RegAddrBusWidth-1:0] id_wd_cp0;
wire                        id_wreg_cp0;

//连接ID/EX模块的输出与执行阶段EX模块的输入
wire[`AluOpBusWidth-1:0] ex_aluop_i;
wire[`AluSelBusWidth-1:0] ex_alusel_i;
wire[`RegWidth-1:0] ex_reg1_i;
wire[`RegWidth-1:0] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBusWidth-1:0] ex_wd_i;
wire                        ex_wreg_hi_i;
wire                        ex_wreg_lo_i;
wire [`RegWidth-1:0]        ex_reg_hi_i;
wire [`RegWidth-1:0]        ex_reg_lo_i;
wire                        ex_wreg_LLbit_i;
wire                        ex_regLLbit_i;
wire [`RegAddrBusWidth-1:0] ex_wd_cp0;
wire                        ex_wreg_cp0;

//连接执行阶段EX模块的输出与EX/MEM模块的输入
wire ex_wreg_o;
wire[`RegAddrBusWidth-1:0] ex_wd_o;
wire[`RegWidth-1:0] ex_wdata_o;
wire ex_wreg_real_o;
wire                        ex_wreg_hi_o;
wire[`RegWidth-1:0]         ex_wdata_hi_o;
wire                        ex_wreg_lo_o;
wire[`RegWidth-1:0]         ex_wdata_lo_o;
wire                        ex_wreg_LLbit_o;
wire                        ex_wreg_LLbit_wb_o;
wire                        ex_wdata_LLbit_o;
wire [`RegAddrBusWidth-1:0] ex_wd_cp0_o;
wire                        ex_wreg_cp0_o;
wire [`RegWidth-1:0]		ex_wdata_cp0_o;
wire [`InstAddrBusWidth-1:0]ex_pc;
wire [31:0]                 ex_excepttype;

////连接EX/MEM模块的输出与访存阶段MEM模块的输入
//wire mem_wreg_i;
//wire[`RegAddrBusWidth-1:0] mem_wd_i;
//wire[`RegWidth-1:0] mem_wdata_i;
//wire mem_wreg_real_i;
//wire                        mem_wreg_hi_i;
//wire[`RegWidth-1:0]         mem_wdata_hi_i;
//wire                        mem_wreg_lo_i;
//wire[`RegWidth-1:0]         mem_wdata_lo_i;

////连接访存阶段MEM模块的输出与MEM/WB模块的输入
//wire mem_wreg_o;
//wire[`RegAddrBusWidth-1:0] mem_wd_o;
//wire[`RegWidth-1:0] mem_wdata_o;
//wire mem_wreg_real_o;
//wire                        mem_wreg_hi_o;
//wire[`RegWidth-1:0]         mem_wdata_hi_o;
//wire                        mem_wreg_lo_o;
//wire[`RegWidth-1:0]         mem_wdata_lo_o;

//连接MEM/WB模块的输出与回写阶段的输入	
wire wb_wreg_i;
wire[`RegAddrBusWidth-1:0] wb_wd_i;
wire[`RegWidth-1:0] wb_wdata_i;
wire wb_wreg_real_i;
wire                        wb_wreg_hi_i;
wire[`RegWidth-1:0]         wb_wdata_hi_i;
wire                        wb_wreg_lo_i;
wire[`RegWidth-1:0]         wb_wdata_lo_i;
wire                        wb_wreg_LLbit_i;
wire                        wb_wreg_LLbit_wb_i;
wire                        wb_wdata_LLbit_i;
wire [`RegAddrBusWidth-1:0] wb_wd_cp0;
wire                        wb_wreg_cp0;
wire [`RegWidth-1:0]		wb_wdata_cp0;

//连接译码阶段ID模块与通用寄存器Regfile模块
wire wreg_real;//有些回写只是回写oitf，不回写到regfile
wire reg1_read;
wire reg2_read;
wire[`RegWidth-1:0] reg1_data;
wire[`RegWidth-1:0] reg2_data;
wire[`RegAddrBusWidth-1:0] reg1_addr;
wire[`RegAddrBusWidth-1:0] reg2_addr;


wire						 rehi;
wire[`RegWidth-1:0]         rdatahi;
wire						 relo;
wire[`RegWidth-1:0]         rdatalo;
wire                        reLLbit;
wire                        rdataLLbit;
wire                        cp0_read;     
wire [`RegAddrBusWidth-1:0] cp0_addr;
wire [`RegWidth-1:0]        cp0_data;

wire                        oitfrd_match_disprs1;
wire                        oitfrd_match_disprs2;
wire                        oitfhi_match;
wire                        oitflo_match;
wire                        oitfLLbit_match;
wire                        oitfrd_cp0_match_disprs;
wire                        oitf_rd_match;
wire                        oitf_match;

wire[5:0]                   pause;
wire                        pausereq_from_id;	
wire                        pausereq_from_ex;
wire                        pausereq_from_jp;
//div
                        
wire  [`RegWidth-1:0]           div_opdata1;
wire  [`RegWidth-1:0]           div_opdata2; 
wire                            div_start;   
wire                            signed_div;  
wire  [`DoubleRegWidth-1:0]     div_result;
wire                            div_ready;

//exception type
wire     [`RegWidth-1:0]     cp0_count;
wire     [`RegWidth-1:0]     cp0_compare;
wire     [`RegWidth-1:0]     cp0_status;
wire     [`RegWidth-1:0]     cp0_cause;
wire     [`RegWidth-1:0]     cp0_epc;
wire     [`RegWidth-1:0]     cp0_config;
wire     [`RegWidth-1:0]     cp0_prid;
wire                         exception_en;
wire [31:0]                  exception_type;
wire                         is_exception;
wire                         is_interrupt;
wire [`InstAddrBusWidth-1:0] pc_next;
wire                         is_slot;
wire [`RegWidth-1:0]         pc_exception_jump;
wire                         pc_exception_flush;	

assign oitf_rd_match = oitfrd_match_disprs1|oitfrd_match_disprs2;
assign oitf_match = oitf_rd_match|oitfhi_match|oitflo_match|oitfLLbit_match|oitfrd_cp0_match_disprs;
assign wreg_real = wb_wreg_i&wb_wreg_real_i;
regfile u_regfile(
	//写端口
	.we(wreg_real),
	.waddr(wb_wd_i),
	.wdata(wb_wdata_i),
	
	//读端口1
	.re1(reg1_read),
	.raddr1(reg1_addr),
	.rdata1(reg1_data),
	
	//读端口2
	.re2(reg2_read),
	.raddr2(reg2_addr),
	.rdata2(reg2_data),
	

    .clk(clk),
	.rst_n(rst_n)
);
oitf u_oitf(
    //fifo的变化
    .wreg(id_wreg_o),
    .wreg_i_rdidx(id_wd_o),
   
    .wreg_wb(wb_wreg_i),
    .wreg_wb_i_rdidx(wb_wd_i),
    
    //fifo的比对及结果
    
    .readen1(reg1_read),
    .readidx1(reg1_addr),
    .readen2(reg2_read),
    .readidx2(reg2_addr),
     
    .oitfrd_match_disprs1(oitfrd_match_disprs1),
    .oitfrd_match_disprs2(oitfrd_match_disprs2),
   
   
	.clk(clk),
	.rst_n(rst_n)
);
reghilo u_reghilo(
	.wehi(wb_wreg_hi_i),
	.wdatahi(wb_wdata_hi_i),

	.welo(wb_wreg_lo_i),
	.wdatalo(wb_wdata_lo_i),

	.rehi(rehi),
	.rdatahi(rdatahi),
	
	.relo(relo),
	.rdatalo(rdatalo),
	
    .clk(clk),
	.rst_n(rst_n)
	
);
//wb_wdata_hi_i
oitfhi u_oitfhi(
    .wreg(id_wreg_hi_o),
    .wreg_wb(wb_wreg_hi_i),
    .readenhi(rehi),
    .oitfhi_match(oitfhi_match),
	.clk(clk),
	.rst_n(rst_n)
);
oitflo u_oitflo(
    .wreg(id_wreg_lo_o),    
    .wreg_wb(wb_wreg_lo_i),
    .readenlo(relo),
    .oitflo_match(oitflo_match),
	.clk(clk),
	.rst_n(rst_n)
);
regLLbit u_regLLbit(
	//写端口lo
	.weLLbit(wb_wreg_LLbit_i),
	.wdataLLbit(wb_wdata_LLbit_i),
	//读端口lo
	.reLLbit(reLLbit),
	.rdataLLbit(rdataLLbit),

    .clk(clk),
	.rst_n(rst_n)
    );
oitfLLbit u_oitfLLbit(
    //fifo的变化
    .wreg(id_wreg_LLbit_o),
    .wreg_wb(wb_wreg_LLbit_wb_i),
    
    .readenLLbit(reLLbit),
    .oitfLLbit_match(oitfLLbit_match),
    
	.clk(clk),
	.rst_n(rst_n)
);

cp0_reg u_cp0_reg(
	.we_i(wb_wreg_cp0),
	.waddr_i(wb_wd_cp0),
	.data_i(wb_wdata_cp0),

	.rd_i(cp0_read),
	.raddr_i(cp0_addr),
	.data_o(cp0_data),
	
	.int_i(int_i),

	.count_o(cp0_count),
	.compare_o(cp0_compare),
	.status_o(cp0_status),
	.cause_o(cp0_cause),
	.epc_o(cp0_epc),
	.config_o(cp0_config),
	.prid_o(cp0_prid),
    
	.timer_int_o(timer_int_o),
    
    //异常相关
    .exception_en(exception_en),
    .is_exception(is_exception),
    .is_interrupt(is_interrupt),
	.excepttype_i(exception_type),
	.pc_next(pc_next),
	.is_slot(is_slot),

    .clk(clk),
	.rst_n(rst_n)
);
oitfcp0 u_oitfcp0(
    //fifo的变化
    .cp0_wreg(id_wreg_cp0),
    .cp0_wreg_i_rdidx(id_wd_cp0),
  
    .cp0_wreg_wb(wb_wreg_cp0),
    .cp0_wreg_wb_i_rdidx(wb_wd_cp0),
   
    .cp0_readen(cp0_read),
    .cp0_readidx(cp0_addr),
    
    .cp0_oitfrd_match_disprs(oitfrd_cp0_match_disprs),
  
	.clk(clk),
	.rst_n(rst_n)
);

    
ctrl u_ctrl(
    .exception_en(exception_en),
	.excepttype_i(exception_type),
	.cp0_epc_i(cp0_epc),
	.pc_exception_jump(pc_exception_jump),
	.pc_exception_flush(pc_exception_flush),
	
	.pausereq_from_id(pausereq_from_id),
	.pausereq_from_ex(pausereq_from_ex),
	.pause(pause),
	.rst_n(rst_n)
);

//pc flash
wire  [`InstAddrBusWidth-1:0]         pc_jump;
wire                                  pc_flush;

wire  [`InstAddrBusWidth-1:0]         id_pc_o;
wire                                  id_pc_flush;
wire  [`RegWidth-1:0]                 id_offset;
wire  [`InstAddrBusWidth-1:0]         ex_pc_o;
wire                                  ex_pc_flush;
wire  [`RegWidth-1:0]                 ex_offset;
wire                                    rom_ce_o_temp;

pc_reg u_pc_reg(
    .pc(pc),
	.ce(rom_ce_o),
	.pause(pause),
	.oitf_match(oitf_match),

	//pc flash
    .pc_jump(pc_jump),
	.pc_flush(pc_flush),
	//exception pc flash
    .pc_exception_jump(pc_exception_jump),
	.pc_exception_flush(pc_exception_flush),

	.clk(clk),
    .rst_n(rst_n)
);


assign rom_addr_o = pc;// 

id u_id(
		.pc_i(pc),
		.inst_i(pc_exception_flush?`InstBusWidth'h00000000:rom_data_i),//

		.reg1_data_i(reg1_data),
		.reg2_data_i(reg2_data),

		//送到regfile的信息
		.reg1_read_o(reg1_read),
		.reg2_read_o(reg2_read), 	  

		.reg1_addr_o(reg1_addr),
		.reg2_addr_o(reg2_addr), 
        //与reghilo的接口
        .reghi_read_o(rehi),
        .reghi_data_i(rdatahi),
        
        .reglo_read_o(relo),
        .reglo_data_i(rdatalo),
        //与regLLbit的接口
	    .regLLbit_read_o(reLLbit),
	    .regLLbit_data_i(rdataLLbit),
        //与cp0的接口
	    .cp0_read_o(cp0_read),     
	    .cp0_addr_o(cp0_addr), 	      
	    .cp0_data_i(cp0_data),
		//送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.reg1_o(id_reg1_o),
		.reg2_o(id_reg2_o),
		.wd_o(id_wd_o),
		.wreg_o(id_wreg_o),
	    .wreg_hi_o(id_wreg_hi_o),           //译码后是否写HI的寄存器
        .wreg_lo_o(id_wreg_lo_o),           //译码后是否写LO的寄存器
        .reghi_o(id_reg_hi_o),              //译码后的源操作数hi
        .reglo_o(id_reg_lo_o),              //译码后的源操作数lo
	    .wreg_LLbit_o(id_wreg_LLbit_o),     //译码后是否写LLbit的寄存器
	    .regLLbit_o(id_regLLbit_o),         //译码后的源操作数LLbit
	    .wd_cp0_o(id_wd_cp0),               //译码后写入的目的寄存器
	    .wreg_cp0_o(id_wreg_cp0),             //译码后是否写入目的寄存器

        .id_to_pausereq(pausereq_from_id),

		.oitf_match(oitf_rd_match),
        .oitf_hi_match(oitfhi_match),
        .oitf_lo_match(oitflo_match),
        .oitf_LLbit_match(oitfLLbit_match),
        .oitf_cp0_match(oitfrd_cp0_match_disprs),
	    .pause(pause),
	    
	    //jump
	    //.pc_flush_en(pc_flush_delay_one),
	    .pc_o(id_pc_o),
	    .pc_flush(id_pc_flush),
	    
	    .offset(id_offset),
	    
		.rst_n(rst_n)
    );

id_ex u_id_ex(
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),
		.id_wreg(id_wreg_o),
	    .id_wreg_hi(id_wreg_hi_o),
		.id_wreg_lo(id_wreg_lo_o),
		.id_reghi(id_reg_hi_o),
		.id_reglo(id_reg_lo_o),
        .id_wreg_LLbit(id_wreg_LLbit_o),
	    .id_regLLbit(id_regLLbit_o),
	    .id_wd_cp0(id_wd_cp0),
	    .id_wreg_cp0(id_wreg_cp0),
    	.id_pc(id_pc_o),
	    .id_pc_flush(id_pc_flush),
	    .id_offset(id_offset),
	
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_wd(ex_wd_i),
		.ex_wreg(ex_wreg_i),
        .ex_wreg_hi(ex_wreg_hi_i),
    	.ex_wreg_lo(ex_wreg_lo_i),
    	.ex_reghi(ex_reg_hi_i),
    	.ex_reglo(ex_reg_lo_i),
    	.ex_wreg_LLbit(ex_wreg_LLbit_i),
	    .ex_regLLbit(ex_regLLbit_i),
        .ex_wd_cp0(ex_wd_cp0),
	    .ex_wreg_cp0(ex_wreg_cp0),
	    .ex_pc(ex_pc_o),
	    .ex_pc_flush(ex_pc_flush),
	    .ex_offset(ex_offset),
    	
        .pause(pause),
		.oitf_match(oitf_rd_match),
        .oitf_hi_match(oitfhi_match),
        .oitf_lo_match(oitflo_match),
        .oitf_LLbit_match(oitfLLbit_match),
        .oitf_cp0_match(oitfrd_cp0_match_disprs),

		.clk(clk),
		.rst_n(rst_n)//&(~pc_exception_flush)
	);
//ex_mem wires
wire [`AluOpBusWidth-1:0]            ex_mem_aluop;
wire [`DataAddrBusWidth-1:0]         ex_mem_addr;
wire [`RegWidth-1:0]                 ex_mem_reg2;
wire                                 ex_mem_wreg;
wire                                 ex_wreg_LLbit;
wire                                 ex_wdata_LLbit;
wire [`RegWidth-1:0]                 ex_mem_data;
wire [3:0]				              ex_mem_sel;
wire                                 ex_mem_data_vaild;
wire                                 ex_mem_is_load;
wire                                 ex_mem_is_store;
wire                                 ex_mem_load_pause;
ex u_ex(
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.reg1_i(ex_reg1_i),
		.reg2_i(ex_reg2_i),
		.wd_i(ex_wd_i),
		.wreg_i(ex_wreg_i),
        .wreg_hi_i(ex_wreg_hi_i),
        .wreg_lo_i(ex_wreg_lo_i),
        .reghi_i(ex_reg_hi_i),
        .reglo_i(ex_reg_lo_i),
        .wreg_LLbit_i(ex_wreg_LLbit_i),
	    .regLLbit_i(ex_regLLbit_i),
	    .wd_cp0_i(ex_wd_cp0),
	    .wreg_cp0_i(ex_wreg_cp0),        
	    .pc_i(ex_pc_o),
	    .pc_flush_i(ex_pc_flush),

	    .offset_i(ex_offset),

	    //EX模块的输出到EX/MEM模块信息
		.wd_o(ex_wd_o),
		.wreg_o(ex_wreg_o),
		.wdata_o(ex_wdata_o),
		.wreg_real_o(ex_wreg_real_o),
        .wreg_hi_o(ex_wreg_hi_o),
        .wdata_hi_o(ex_wdata_hi_o),
        .wreg_lo_o(ex_wreg_lo_o),
        .wdata_lo_o(ex_wdata_lo_o),
	    .wreg_LLbit_o(ex_wreg_LLbit_o),
	    .wreg_LLbit_wb_o(ex_wreg_LLbit_wb_o),
	    .wdata_LLbit_o(ex_wdata_LLbit_o),        
	    .wd_cp0_o(ex_wd_cp0_o),
	    .wreg_cp0_o(ex_wreg_cp0_o),
	    .wdata_cp0_o(ex_wdata_cp0_o),
	    .pc_o(ex_pc),
	    .excepttype_o(ex_excepttype),
        //div
        .div_opdata1_o(div_opdata1),
	    .div_opdata2_o(div_opdata2),
	    .div_start_o(div_start),
	    .signed_div_o(signed_div),
        .div_result_i(div_result),
	    .div_ready_i(div_ready),

        .ex_to_pausereq(pausereq_from_ex),
        //.jp_to_pausereq(pausereq_from_jp),

        //jump
        .pc_jump_o(pc_jump),
        .pc_flush_o(pc_flush),
        
			//mem
	    .mem_aluop_o(ex_mem_aluop),
        .mem_addr_o(ex_mem_addr),
	    .mem_reg2_o(ex_mem_reg2),
	    .mem_wreg_o(ex_mem_wreg),
	    .mem_wreg_LLbit(ex_wreg_LLbit),
	    .mem_wdata_LLbit(ex_wdata_LLbit),
	    .mem_data_i(ex_mem_data),
	    .mem_sel_i(ex_mem_sel),
	    .mem_data_vaild_i(ex_mem_data_vaild),
	    .mem_is_load_i(ex_mem_is_load),
	    .mem_is_store_i(ex_mem_is_store),
	    .mem_load_pause(ex_mem_load_pause),
	    .clk(clk),
	    .rst_n(rst_n)
	);
	
div u_div(

	.signed_div_i(signed_div),
	.opdata1_i(div_opdata1),
	.opdata2_i(div_opdata2),
	.start_i(div_start),
	.annul_i(1'b0),
	
	.result_o(div_result),
	.ready_o(div_ready),
	
    .clk(clk),
	.rst_n(rst_n)

    );

mem u_mem(
	
	//与ex模块的接口	
	.aluop_i(ex_mem_aluop),
    .ex_addr_i(ex_mem_addr),
	.reg2_i(ex_mem_reg2),
	.ex_wreg_i(ex_mem_wreg),
	.ex_wreg_LLbit(ex_wreg_LLbit),
	.ex_wdata_LLbit(ex_wdata_LLbit),
    .oitf_match(oitf_match),
	.ex_data_o(ex_mem_data),
	.ex_sel_o(ex_mem_sel),
	.ex_data_vaild_o(ex_mem_data_vaild),
	.ex_is_load_o(ex_mem_is_load),
	.ex_is_store_o(ex_mem_is_store),
	.ex_load_pause(ex_mem_load_pause),
	//与数据ram的接口
    .mem_addr_o(mem_addr_o),
	.mem_we_o(mem_we_o),
	.mem_sel_o(mem_sel_o),
	.mem_data_o(mem_data_o),
	.mem_ce_o(mem_ce_o),
	.mem_data_i(mem_data_i),


    .clk(clk),
    .rst_n(rst_n)
);



mem_wb u_mem_wb(
	//来自访存阶段的信息	
    .mem_wd(ex_wd_o),
	.mem_wreg(ex_wreg_o),
	.mem_wdata(ex_wdata_o),
	.mem_wreg_real(ex_wreg_real_o),
    .mem_wreg_hi(ex_wreg_hi_o),
    .mem_wdata_hi(ex_wdata_hi_o),
    .mem_wreg_lo(ex_wreg_lo_o),
    .mem_wdata_lo(ex_wdata_lo_o),
	.mem_wreg_LLbit(ex_wreg_LLbit_o),
	.mem_wreg_LLbit_wb(ex_wreg_LLbit_wb_o),
	.mem_wdata_LLbit(ex_wdata_LLbit_o),
	.mem_wd_cp0(ex_wd_cp0_o),
	.mem_wreg_cp0(ex_wreg_cp0_o),
	.mem_wdata_cp0(ex_wdata_cp0_o),

	//送到回写阶段的信息
	.wb_wd(wb_wd_i),
	.wb_wreg(wb_wreg_i),
	.wb_wdata(wb_wdata_i),
	.wb_wreg_real(wb_wreg_real_i),
    .wb_wreg_hi(wb_wreg_hi_i),
    .wb_wdata_hi(wb_wdata_hi_i),
    .wb_wreg_lo(wb_wreg_lo_i),
    .wb_wdata_lo(wb_wdata_lo_i),
	.wb_wreg_LLbit(wb_wreg_LLbit_i),
	.wb_wreg_LLbit_wb(wb_wreg_LLbit_wb_i),
	.wb_wdata_LLbit(wb_wdata_LLbit_i),
	.wb_wd_cp0(wb_wd_cp0),
	.wb_wreg_cp0(wb_wreg_cp0),
	.wb_wdata_cp0(wb_wdata_cp0),

	.pause(pause),
	
	.mem_pc(ex_pc),
	.mem_pc_jump(pc_jump),
	.mem_pc_flush(pc_flush),
    .ex_to_pausereq(pausereq_from_ex),
    
	.excepttype_i(ex_excepttype),
	.cp0_status_i(cp0_status),
	.cp0_cause_i(cp0_cause),
	.cp0_epc_i(cp0_epc),
    
	.exception_en(exception_en),
    .is_exception(is_exception),
    .is_interrupt(is_interrupt),
	.excepttype_o(exception_type),
	.pc_next(pc_next),
	.is_slot(is_slot),

    .clk(clk),
	.rst_n(rst_n)
);
endmodule

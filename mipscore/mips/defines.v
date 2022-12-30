//È«¾Ö
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBusWidth 8
`define AluSelBusWidth 4
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define ExceptionTypeWidth  32

//Ö¸Áî
//logic
`define EXE_ORI                 6'b001101
`define EXE_ANDI                6'b001100
`define EXE_XORI                6'b001110
`define EXE_LUI                 6'b001111
`define EXE_SPECIAL_AND         6'b100100
`define EXE_SPECIAL_OR          6'b100101
`define EXE_SPECIAL_XOR         6'b100110
`define EXE_SPECIAL_NOR         6'b100111

//shift
`define EXE_SPECIAL_SLL         6'b000000
`define EXE_SPECIAL_SRL         6'b000010
`define EXE_SPECIAL_SRA         6'b000011
`define EXE_SPECIAL_SLLV        6'b000100
`define EXE_SPECIAL_SRLV        6'b000110
`define EXE_SPECIAL_SRAV        6'b000111

//nop
`define EXE_NOP                 6'b000000
`define EXE_SPECIAL_SYNC        6'b001111
`define EXE_PREF                6'b110011

//move
`define EXE_SPECIAL_MOVN        6'b001011
`define EXE_SPECIAL_MOVZ        6'b001010
`define EXE_SPECIAL_MFHI        6'b010000
`define EXE_SPECIAL_MFLO        6'b010010
`define EXE_SPECIAL_MTHI        6'b010001
`define EXE_SPECIAL_MTLO        6'b010011

///arithmetic
//simple
`define EXE_SPECIAL_ADD         6'b100000
`define EXE_SPECIAL_ADDU        6'b100001
`define EXE_SPECIAL_SUB         6'b100010
`define EXE_SPECIAL_SUBU        6'b100011
`define EXE_SPECIAL_SLT         6'b101010
`define EXE_SPECIAL_SLTU        6'b101011
`define EXE_ADDI                6'b001000
`define EXE_ADDIU               6'b001001
`define EXE_SLTI                6'b001010
`define EXE_SLTIU               6'b001011
`define EXE_SPECIAL2_CLZ        6'b100000
`define EXE_SPECIAL2_CLO        6'b100001
`define EXE_SPECIAL2_MUL        6'b000010
`define EXE_SPECIAL_MULT        6'b011000
`define EXE_SPECIAL_MULTU       6'b011001
//mul+add
`define EXE_SPECIAL2_MADD       6'b000000
`define EXE_SPECIAL2_MADDU      6'b000001
`define EXE_SPECIAL2_MSUB       6'b000100
`define EXE_SPECIAL2_MSUBU      6'b000101
//div
`define EXE_SPECIAL_DIV         6'b011010
`define EXE_SPECIAL_DIVU        6'b011011

///jump
//jump
`define EXE_SPECIAL_JR          6'b001000
`define EXE_SPECIAL_JALR        6'b001001
`define EXE_J                   6'b000010
`define EXE_JAL                 6'b000011

//branch
`define EXE_BEQ                 6'b000100
//`define EXE_B                 6'b000100
`define EXE_BGTZ                6'b000111
`define EXE_BLEZ                6'b000110
`define EXE_BNE                 6'b000101
`define EXE_REGIMM_BLTZ         6'b000000
`define EXE_REGIMM_BLTZAL       6'b010000
`define EXE_REGIMM_BGEZ         6'b000001
`define EXE_REGIMM_BGEZAL       6'b010001
//`define EXE_REGIMM_BGEZAL_BAL   6'b010001


///load&store
//load
`define EXE_LB                  6'b100000
`define EXE_LBU                 6'b100100
`define EXE_LH                  6'b100001
`define EXE_LHU                 6'b100101
`define EXE_LW                  6'b100011

`define EXE_LWL                 6'b100010
`define EXE_LWR                 6'b100110

`define EXE_LL                  6'b110000

//store
`define EXE_SB                  6'b101000
`define EXE_SH                  6'b101001
`define EXE_SW                  6'b101011

`define EXE_SWL                 6'b101010
`define EXE_SWR                 6'b101110

`define EXE_SC                  6'b111000

///cp0
`define EXE_COP0_MTC0           6'b100100
`define EXE_COP0_MFC0           6'b100000

///exception
//trap
`define EXE_SPECIAL_TEQ         6'b110100
`define EXE_SPECIAL_TGE         6'b110000
`define EXE_SPECIAL_TGEU        6'b110001
`define EXE_SPECIAL_TLT         6'b110010
`define EXE_SPECIAL_TLTU        6'b110011
`define EXE_SPECIAL_TNE         6'b110110
`define EXE_REGIMM_TEQI         6'b001100
`define EXE_REGIMM_TGEI         6'b001000
`define EXE_REGIMM_TGEIU        6'b001001
`define EXE_REGIMM_TLTI         6'b001010
`define EXE_REGIMM_TLTIU        6'b001011
`define EXE_REGIMM_TNEI         6'b001110

//syscall
`define EXE_SPECIAL_SYSCALL     6'b001100

//eret
`define EXE_EXCEPTION_ERET      6'b011000



`define EXE_SPECIAL             6'b000000
`define EXE_SPECIAL2            6'b011100
`define EXE_REGIMM              6'b000001
`define EXE_COP0                6'b010000

///////AluOp
//logic
`define EXE_ORI_OP          8'b00001101
`define EXE_ANDI_OP         8'b00001100
`define EXE_XORI_OP         8'b00001110
`define EXE_LUI_OP          8'b00001111
`define EXE_AND_OP          8'b01100100
`define EXE_OR_OP           8'b01100101
`define EXE_XOR_OP          8'b01100110
`define EXE_NOR_OP          8'b01100111

//shift
`define EXE_SLL_OP          8'b01000000
`define EXE_SRL_OP          8'b01000010
`define EXE_SRA_OP          8'b01000011
`define EXE_SLLV_OP         8'b01000100
`define EXE_SRLV_OP         8'b01000110
`define EXE_SRAV_OP         8'b01000111

//nop
`define EXE_NOP_OP          8'b00000000
`define EXE_SYNC_OP         8'b01001111
`define EXE_PREF_OP         8'b00110011

//move
`define EXE_MOVN_OP         8'b01001011
`define EXE_MOVZ_OP         8'b01001010
`define EXE_MFHI_OP         8'b01010000
`define EXE_MFLO_OP         8'b01010010
`define EXE_MTHI_OP         8'b01010001
`define EXE_MTLO_OP         8'b01010011

//arithmetic
//simple
`define EXE_ADD_OP          8'b01100000
`define EXE_ADDU_OP         8'b01100001
`define EXE_SUB_OP          8'b01100010
`define EXE_SUBU_OP         8'b01100011
`define EXE_SLT_OP          8'b01101010
`define EXE_SLTU_OP         8'b01101011
`define EXE_ADDI_OP         8'b00001000
`define EXE_ADDIU_OP        8'b00001001
`define EXE_SLTI_OP         8'b00001010
`define EXE_SLTIU_OP        8'b00001011
`define EXE_CLZ_OP          8'b10100000
`define EXE_CLO_OP          8'b10100001
`define EXE_MUL_OP          8'b10000010
`define EXE_MULT_OP         8'b01011000
`define EXE_MULTU_OP        8'b01011001
//mul+add
`define EXE_MADD_OP         8'b10000000
`define EXE_MADDU_OP        8'b10000001
`define EXE_MSUB_OP         8'b10000100
`define EXE_MSUBU_OP        8'b10000101
//div
`define EXE_DIV_OP          8'b01011010
`define EXE_DIVU_OP         8'b01011011

///jump
//jump
`define EXE_JR_OP           8'b01001000
`define EXE_JALR_OP         8'b01001001
`define EXE_J_OP            8'b00000010
`define EXE_JAL_OP          8'b00000011

//branch
`define EXE_BEQ_OP          8'b00000100
//`define EXE_B_OP           8'00b000100
`define EXE_BGTZ_OP         8'b00000111
`define EXE_BLEZ_OP         8'b00000110
`define EXE_BNE_OP          8'b00000101
`define EXE_BLTZ_OP         8'b11000000
`define EXE_BLTZAL_OP       8'b11010000
`define EXE_BGEZ_OP         8'b11000001
`define EXE_BGEZAL_OP       8'b11010001
//`define EXE_BGEZAL_BAL_OP   8'b11010001

///load&store
//load
`define EXE_LB_OP           8'b00100000
`define EXE_LBU_OP          8'b00100100
`define EXE_LH_OP           8'b00100001
`define EXE_LHU_OP          8'b00100101
`define EXE_LW_OP           8'b00100011
                            
`define EXE_LWL_OP          8'b00100010
`define EXE_LWR_OP          8'b00100110

`define EXE_LL_OP           8'b00110000
                            
//store
`define EXE_SB_OP           8'b00101000
`define EXE_SH_OP           8'b00101001
`define EXE_SW_OP           8'b00101011
                            
`define EXE_SWL_OP          8'b00101010
`define EXE_SWR_OP          8'b00101110

`define EXE_SC_OP           8'b00111000

///cp0
`define EXE_MTC0_OP         8'b11100100
`define EXE_MFC0_OP         8'b11100000

///exception
//trap
`define EXE_TEQ_OP          8'b01110100
`define EXE_TGE_OP          8'b01110000
`define EXE_TGEU_OP         8'b01110001
`define EXE_TLT_OP          8'b01110010
`define EXE_TLTU_OP         8'b01110011
`define EXE_TNE_OP          8'b01110110
`define EXE_TEQI_OP         8'b11001100
`define EXE_TGEI_OP         8'b11001000
`define EXE_TGEIU_OP        8'b11001001
`define EXE_TLTI_OP         8'b11001010
`define EXE_TLTIU_OP        8'b11001011
`define EXE_TNEI_OP         8'b11001110

//syscall
`define EXE_SYSCALL_OP      8'b01001100

//eret
`define EXE_ERET_OP         8'b11011000


///////AluSel
`define EXE_RES_LOGIC 4'b0001
`define EXE_RES_SHIFT 4'b0010
`define EXE_RES_MOVE 4'b0011	
`define EXE_RES_ARITHMETIC 4'b0100	
`define EXE_RES_MUL 4'b0101
`define EXE_RES_CMUL 4'b0110
`define EXE_RES_DIV 4'b0111
`define EXE_RES_JUMP 4'b1000
`define EXE_RES_BRANCH 4'b1001
`define EXE_RES_LOAD 4'b1010
`define EXE_RES_STORE 4'b1011
`define EXE_RES_CP0 4'b1100
`define EXE_RES_EXCEPTION 4'b1101

`define EXE_RES_3 4'b1110
`define EXE_RES_4 4'b1111

`define EXE_RES_NOP 4'b0000


//Ö¸Áî´æ´¢Æ÷inst_rom
`define InstBusWidth 32
`define InstMemNum 131071
`define InstMemNumLog2 17
`define InstAddrBusWidth 32
`define DataAddrBusWidth 32


//Í¨ÓÃ¼Ä´æÆ÷regfile
`define RegAddrBusWidth 5
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

//oitf
`define OitfDepth   2
`define OitfWidth   1


//³ý·¨div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

//CP0¼Ä´æÆ÷
`define CP0_REG_COUNT    5'b01001      
`define CP0_REG_COMPARE    5'b01011    
`define CP0_REG_STATUS    5'b01100     
`define CP0_REG_CAUSE    5'b01101      
`define CP0_REG_EPC    5'b01110        
`define CP0_REG_PrId    5'b01111       
`define CP0_REG_CONFIG    5'b10000

//exception type
`define EXCEPTION_INT    32'h00000001
`define EXCEPTION_SYSCALL    32'h00000008
`define EXCEPTION_RI    32'h0000000a
`define EXCEPTION_OV    32'h0000000c
`define EXCEPTION_TR    32'h0000000d
`define EXCEPTION_ERET    32'h0000000e
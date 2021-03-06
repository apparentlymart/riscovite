// Generated by opcodes.go from opcodes.txt; do not edit directly

// Full instruction patterns
`define INSTR_BEQ                32'b?????????????????000?????1100011
`define INSTR_BNE                32'b?????????????????001?????1100011
`define INSTR_BLT                32'b?????????????????100?????1100011
`define INSTR_BGE                32'b?????????????????101?????1100011
`define INSTR_BLTU               32'b?????????????????110?????1100011
`define INSTR_BGEU               32'b?????????????????111?????1100011
`define INSTR_JALR               32'b?????????????????000?????1100111
`define INSTR_JAL                32'b?????????????????????????1101111
`define INSTR_LUI                32'b?????????????????????????0110111
`define INSTR_AUIPC              32'b?????????????????????????0010111
`define INSTR_ADDI               32'b?????????????????000?????0010011
`define INSTR_SLLI               32'b000000???????????001?????0010011
`define INSTR_SLTI               32'b?????????????????010?????0010011
`define INSTR_SLTIU              32'b?????????????????011?????0010011
`define INSTR_XORI               32'b?????????????????100?????0010011
`define INSTR_SRLI               32'b000000???????????101?????0010011
`define INSTR_SRAI               32'b010000???????????101?????0010011
`define INSTR_ORI                32'b?????????????????110?????0010011
`define INSTR_ANDI               32'b?????????????????111?????0010011
`define INSTR_ADD                32'b0000000??????????000?????0110011
`define INSTR_SUB                32'b0100000??????????000?????0110011
`define INSTR_SLL                32'b0000000??????????001?????0110011
`define INSTR_SLT                32'b0000000??????????010?????0110011
`define INSTR_SLTU               32'b0000000??????????011?????0110011
`define INSTR_XOR                32'b0000000??????????100?????0110011
`define INSTR_SRL                32'b0000000??????????101?????0110011
`define INSTR_SRA                32'b0100000??????????101?????0110011
`define INSTR_OR                 32'b0000000??????????110?????0110011
`define INSTR_AND                32'b0000000??????????111?????0110011
`define INSTR_ADDIW              32'b?????????????????000?????0011011
`define INSTR_SLLIW              32'b0000000??????????001?????0011011
`define INSTR_SRLIW              32'b0000000??????????101?????0011011
`define INSTR_SRAIW              32'b0100000??????????101?????0011011
`define INSTR_ADDW               32'b0000000??????????000?????0111011
`define INSTR_SUBW               32'b0100000??????????000?????0111011
`define INSTR_SLLW               32'b0000000??????????001?????0111011
`define INSTR_SRLW               32'b0000000??????????101?????0111011
`define INSTR_SRAW               32'b0100000??????????101?????0111011
`define INSTR_LB                 32'b?????????????????000?????0000011
`define INSTR_LH                 32'b?????????????????001?????0000011
`define INSTR_LW                 32'b?????????????????010?????0000011
`define INSTR_LD                 32'b?????????????????011?????0000011
`define INSTR_LBU                32'b?????????????????100?????0000011
`define INSTR_LHU                32'b?????????????????101?????0000011
`define INSTR_LWU                32'b?????????????????110?????0000011
`define INSTR_SB                 32'b?????????????????000?????0100011
`define INSTR_SH                 32'b?????????????????001?????0100011
`define INSTR_SW                 32'b?????????????????010?????0100011
`define INSTR_SD                 32'b?????????????????011?????0100011
`define INSTR_FENCE              32'b?????????????????000?????0001111
`define INSTR_FENCE_I            32'b?????????????????001?????0001111
`define INSTR_MUL                32'b0000001??????????000?????0110011
`define INSTR_MULH               32'b0000001??????????001?????0110011
`define INSTR_MULHSU             32'b0000001??????????010?????0110011
`define INSTR_MULHU              32'b0000001??????????011?????0110011
`define INSTR_DIV                32'b0000001??????????100?????0110011
`define INSTR_DIVU               32'b0000001??????????101?????0110011
`define INSTR_REM                32'b0000001??????????110?????0110011
`define INSTR_REMU               32'b0000001??????????111?????0110011
`define INSTR_MULW               32'b0000001??????????000?????0111011
`define INSTR_DIVW               32'b0000001??????????100?????0111011
`define INSTR_DIVUW              32'b0000001??????????101?????0111011
`define INSTR_REMW               32'b0000001??????????110?????0111011
`define INSTR_REMUW              32'b0000001??????????111?????0111011
`define INSTR_LR_W               32'b00010??00000?????010?????0101111
`define INSTR_SC_W               32'b00011????????????010?????0101111
`define INSTR_LR_D               32'b00010??00000?????011?????0101111
`define INSTR_SC_D               32'b00011????????????011?????0101111
`define INSTR_ECALL              32'b00000000000000000000000001110011
`define INSTR_EBREAK             32'b00000000000100000000000001110011
`define INSTR_URET               32'b00000000001000000000000001110011
`define INSTR_MRET               32'b00110000001000000000000001110011
`define INSTR_DRET               32'b01111011001000000000000001110011
`define INSTR_SFENCE_VMA         32'b0001001??????????000000001110011
`define INSTR_WFI                32'b00010000010100000000000001110011
`define INSTR_CSRRW              32'b?????????????????001?????1110011
`define INSTR_CSRRS              32'b?????????????????010?????1110011
`define INSTR_CSRRC              32'b?????????????????011?????1110011
`define INSTR_CSRRWI             32'b?????????????????101?????1110011
`define INSTR_CSRRSI             32'b?????????????????110?????1110011
`define INSTR_CSRRCI             32'b?????????????????111?????1110011
`define INSTR_CUSTOM0            32'b?????????????????000?????0001011
`define INSTR_CUSTOM0_RS1        32'b?????????????????010?????0001011
`define INSTR_CUSTOM0_RS1_RS2    32'b?????????????????011?????0001011
`define INSTR_CUSTOM0_RD         32'b?????????????????100?????0001011
`define INSTR_CUSTOM0_RD_RS1     32'b?????????????????110?????0001011
`define INSTR_CUSTOM0_RD_RS1_RS2 32'b?????????????????111?????0001011
`define INSTR_CUSTOM1            32'b?????????????????000?????0101011
`define INSTR_CUSTOM1_RS1        32'b?????????????????010?????0101011
`define INSTR_CUSTOM1_RS1_RS2    32'b?????????????????011?????0101011
`define INSTR_CUSTOM1_RD         32'b?????????????????100?????0101011
`define INSTR_CUSTOM1_RD_RS1     32'b?????????????????110?????0101011
`define INSTR_CUSTOM1_RD_RS1_RS2 32'b?????????????????111?????0101011
`define INSTR_CUSTOM2            32'b?????????????????000?????1011011
`define INSTR_CUSTOM2_RS1        32'b?????????????????010?????1011011
`define INSTR_CUSTOM2_RS1_RS2    32'b?????????????????011?????1011011
`define INSTR_CUSTOM2_RD         32'b?????????????????100?????1011011
`define INSTR_CUSTOM2_RD_RS1     32'b?????????????????110?????1011011
`define INSTR_CUSTOM2_RD_RS1_RS2 32'b?????????????????111?????1011011
`define INSTR_CUSTOM3            32'b?????????????????000?????1111011
`define INSTR_CUSTOM3_RS1        32'b?????????????????010?????1111011
`define INSTR_CUSTOM3_RS1_RS2    32'b?????????????????011?????1111011
`define INSTR_CUSTOM3_RD         32'b?????????????????100?????1111011
`define INSTR_CUSTOM3_RD_RS1     32'b?????????????????110?????1111011
`define INSTR_CUSTOM3_RD_RS1_RS2 32'b?????????????????111?????1111011
`define INSTR_SLLI_RV32          32'b0000000??????????001?????0010011
`define INSTR_SRLI_RV32          32'b0000000??????????101?????0010011
`define INSTR_SRAI_RV32          32'b0100000??????????101?????0010011
`define INSTR_RDCYCLE            32'b11000000000000000010?????1110011
`define INSTR_RDTIME             32'b11000000000100000010?????1110011
`define INSTR_RDINSTRET          32'b11000000001000000010?????1110011
`define INSTR_RDCYCLEH           32'b11001000000000000010?????1110011
`define INSTR_RDTIMEH            32'b11001000000100000010?????1110011
`define INSTR_RDINSTRETH         32'b11001000001000000010?????1110011

// ALU Functions
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b1000
`define ALU_SLL  4'b0001
`define ALU_SLT  4'b0010
`define ALU_SLTU 4'b0011
`define ALU_XOR  4'b0100
`define ALU_SRL  4'b0101
`define ALU_SRA  4'b1101
`define ALU_OR   4'b0110
`define ALU_AND  4'b0111

// Multiplier Unit Functions
`define MULU_MUL    3'b000
`define MULU_MULH   3'b001
`define MULU_MULHSU 3'b010
`define MULU_MULHU  3'b011
`define MULU_DIV    3'b100
`define MULU_DIVU   3'b101
`define MULU_REM    3'b110
`define MULU_REMU   3'b111

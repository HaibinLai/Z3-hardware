package VX_gpu_pkg;
    localparam NC_BITS = $clog2(1);
    localparam NW_BITS = $clog2(4);
    localparam NT_BITS = $clog2(64);
    localparam NB_BITS = $clog2(8);
    localparam NC_WIDTH = (((NC_BITS) > 0) ? (NC_BITS) : 1);
    localparam NW_WIDTH = (((NW_BITS) > 0) ? (NW_BITS) : 1);
    localparam NT_WIDTH = (((NT_BITS) > 0) ? (NT_BITS) : 1);
    localparam NB_WIDTH = (((NB_BITS) > 0) ? (NB_BITS) : 1);
    localparam CORE_ID_BITS  = $clog2(1 * 1);
    localparam CORE_ID_WIDTH = (((CORE_ID_BITS) > 0) ? (CORE_ID_BITS) : 1);
    localparam CLUSTER_ID_WIDTH = (((1) > 1) ? $clog2(1) : 1);
    localparam NUM_CTA_MAX = 4;
    localparam NCTA_BITS  = $clog2(NUM_CTA_MAX);
    localparam NCTA_WIDTH = (((NCTA_BITS) > 0) ? (NCTA_BITS) : 1);
    localparam XLENB    = 32 / 8;
    localparam XLENB_W  = $clog2(XLENB);
    localparam BYTESEL_BITS = (XLENB_W + XLENB_W);
    localparam [BYTESEL_BITS-1:0] BYTESEL_DEFAULT = {XLENB_W'(XLENB-1), XLENB_W'(0)};
    localparam RV_REGS = 32;
    localparam RV_REGS_BITS = 5;
    localparam RV_RD  = 0;
    localparam RV_RS1 = 1;
    localparam RV_RS2 = 2;
    localparam RV_RS3 = 3;
    localparam REG_TYPE_I = 0;
    localparam REG_TYPE_F = 1;
    localparam REG_TYPES = 1 + 1;
    localparam NUM_REGS = (REG_TYPES * RV_REGS);
    localparam REG_TYPE_BITS = (((REG_TYPES) > 1) ? $clog2(REG_TYPES) : 1);
    localparam NUM_REGS_BITS = $clog2(NUM_REGS);
    localparam XREG_0      = 0;
    localparam XREG_1      = 1;
    localparam NUM_XREGS   = 2;
    localparam DV_STACK_SIZE = (((64-1) > 0) ? (64-1) : 1);
    localparam DV_STACK_SIZEW = (((DV_STACK_SIZE) > 1) ? $clog2(DV_STACK_SIZE) : 1);
    localparam PERF_CTR_BITS = 44;
    localparam SIMD_COUNT = 64 / 64;
    localparam SIMD_IDX_BITS = $clog2(SIMD_COUNT);
    localparam SIMD_IDX_W = (((SIMD_IDX_BITS) > 0) ? (SIMD_IDX_BITS) : 1);
    localparam NUM_OPCS_BITS = $clog2((((((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) != 0) ? (((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) : 1));
    localparam NUM_OPCS_W = (((NUM_OPCS_BITS) > 0) ? (NUM_OPCS_BITS) : 1);
    localparam BAR_ADDR_BITS = NW_BITS + NB_BITS;
    localparam BAR_ADDR_W = (((BAR_ADDR_BITS) > 0) ? (BAR_ADDR_BITS) : 1);
    localparam BAR_ID_SHIFT = 8;
    localparam BAR_SIZE_W = ((((((NW_WIDTH) > (CORE_ID_WIDTH)) ? (NW_WIDTH) : (CORE_ID_WIDTH))) > ($clog2(32))) ? ((((NW_WIDTH) > (CORE_ID_WIDTH)) ? (NW_WIDTH) : (CORE_ID_WIDTH))) : ($clog2(32)));
    localparam UOP_PACKLD = 0;
    localparam UOP_TCU = UOP_PACKLD + 1;
    localparam UOP_GFX = UOP_TCU + 0;
    localparam UOP_AMO = UOP_GFX + 0;
    localparam UOP_MAX = UOP_AMO + 0;
    localparam UOP_CTR_W = 8;
    localparam CTA_TID_WIDTH = (((NW_BITS + NT_BITS) > 0) ? (NW_BITS + NT_BITS) : 1);
    localparam UUID_WIDTH = 44;
    localparam PC_BITS = 32;
    function automatic logic [32-1:0] to_fullPC(input logic[PC_BITS-1:0] pc);
        to_fullPC = 32'(pc);
    endfunction
    function automatic logic [PC_BITS-1:0] from_fullPC(input logic[32-1:0] pc);
        from_fullPC = pc;
    endfunction
    localparam NUM_SRC_OPDS = 3;
    localparam SRC_OPD_BITS = $clog2(NUM_SRC_OPDS);
    localparam SRC_OPD_WIDTH = (((SRC_OPD_BITS) > 0) ? (SRC_OPD_BITS) : 1);
    localparam NUM_SOCKETS = (((1 / 1) > 0) ? (1 / 1) : 1);
    localparam NUM_STACKS = 1 * NUM_SOCKETS * 1 * 4 * 64;
    localparam [32-1:0] STACK_WINDOW_TOP    = 32'(((64'hFFFC0000) - (((64'hFFFC0000) % (((64) << (13)))))));
    localparam [32-1:0] STACK_WINDOW_SPAN   = 32'(NUM_STACKS) << 13;
    localparam [32-1:0] STACK_WINDOW_BOTTOM = STACK_WINDOW_TOP - STACK_WINDOW_SPAN;
    localparam HART_ID_BITS = CORE_ID_BITS + NW_BITS + NT_BITS;
    localparam HART_ID_WIDTH = (((HART_ID_BITS) > 0) ? (HART_ID_BITS) : 1);
    typedef enum logic [3:0] {
        AMO_OP_LR    = 4'h0,
        AMO_OP_SC    = 4'h1,
        AMO_OP_ADD   = 4'h2,
        AMO_OP_SWAP  = 4'h3,
        AMO_OP_XOR   = 4'h4,
        AMO_OP_OR    = 4'h5,
        AMO_OP_AND   = 4'h6,
        AMO_OP_MIN   = 4'h7,
        AMO_OP_MAX   = 4'h8,
        AMO_OP_CAS   = 4'h9
    } amo_op_e;
    typedef struct packed {
        logic [HART_ID_WIDTH-1:0]   hart_id;
        logic                        amo_unsigned;
        amo_op_e                     amo_op;
        logic                        amo_valid;
    } amo_req_t;
    localparam AMO_REQ_BITS = $bits(amo_req_t);
    typedef struct packed {
        logic                        is_noalloc;     
        amo_req_t                    amo;            
        logic                        is_addr_om;     
        logic                        is_addr_local;  
        logic                        is_addr_io;     
        logic                        is_flush;       
    } mem_bus_attr_t;
    localparam MEM_ATTR_FLUSH_OFFS  = 0;
    localparam MEM_ATTR_IO_OFFS     = 1;
    localparam MEM_ATTR_LOCAL_OFFS  = 2;
    localparam MEM_ATTR_OM_OFFS     = 3;
    localparam MEM_ATTR_AMO_OFFS    = 4;
    localparam MEM_ATTR_NOALLOC_OFFS = MEM_ATTR_AMO_OFFS + AMO_REQ_BITS;
    localparam MEM_ATTR_WIDTH = $bits(mem_bus_attr_t);
    function automatic logic [7:0] cache_bank_hash(input logic [31:0] hi, input integer bits);
        logic [7:0] f;
        f = '0;
        if (bits == 4) begin
            f[0] = hi[11] ^ hi[10] ^ hi[9] ^ hi[8] ^ hi[6] ^ hi[4] ^ hi[3] ^ hi[0];
            f[1] = hi[12] ^ hi[8]  ^ hi[7] ^ hi[6] ^ hi[5] ^ hi[3] ^ hi[1] ^ hi[0];
            f[2] = hi[9]  ^ hi[8]  ^ hi[7] ^ hi[6] ^ hi[4] ^ hi[2] ^ hi[1];
            f[3] = hi[10] ^ hi[9]  ^ hi[8] ^ hi[7] ^ hi[5] ^ hi[3] ^ hi[2];
        end else if (bits == 5) begin
            f[0] = hi[13] ^ hi[12] ^ hi[11] ^ hi[10] ^ hi[9] ^ hi[6] ^ hi[5] ^ hi[3] ^ hi[0];
            f[1] = hi[14] ^ hi[13] ^ hi[12] ^ hi[11] ^ hi[10] ^ hi[7] ^ hi[6] ^ hi[4] ^ hi[1];
            f[2] = hi[14] ^ hi[10] ^ hi[9]  ^ hi[8]  ^ hi[7]  ^ hi[6] ^ hi[3] ^ hi[2] ^ hi[0];
            f[3] = hi[11] ^ hi[10] ^ hi[9]  ^ hi[8]  ^ hi[7]  ^ hi[4] ^ hi[3] ^ hi[1];
            f[4] = hi[12] ^ hi[11] ^ hi[10] ^ hi[9]  ^ hi[8]  ^ hi[5] ^ hi[4] ^ hi[2];
        end else if (bits > 0 && bits <= 8) begin
            for (integer i = 0; i < 15; ++i) begin
                if ((i % bits) == 0) begin
                    f = f ^ (8'(hi >> i) & 8'((1 << bits) - 1));
                end
            end
        end
        return f;
    endfunction
    function automatic logic [15:0] cache_set_hash(input logic [31:0] tag, input integer bits);
        logic [15:0] f;
        f = '0;
        if (bits > 0 && bits <= 16) begin
            for (integer i = 0; i < 32; ++i) begin
                if ((i % bits) == 0) begin
                    f = f ^ (16'(tag >> i) & 16'((1 << bits) - 1));
                end
            end
        end
        return f;
    endfunction
    localparam VX_DCR_ADDR_WIDTH = 12;
    localparam VX_DCR_DATA_WIDTH = 32;
    localparam STALL_TIMEOUT = ((100000) * (((1) << (((0) + (0))))));
    localparam EX_ALU = 0;
    localparam EX_LSU = 1;
    localparam EX_SFU = 2;
    localparam EX_FPU = (EX_SFU + 1);
    localparam EX_TCU = (EX_FPU + 0);
    localparam NUM_EX_UNITS = EX_TCU + 1;
    localparam EX_BITS = $clog2(NUM_EX_UNITS);
    localparam EX_WIDTH = (((EX_BITS) > 0) ? (EX_BITS) : 1);
    localparam SFU_BITS = $clog2(2);
    localparam SFU_WIDTH = (((SFU_BITS) > 0) ? (SFU_BITS) : 1);
    localparam SFU_CSRS = 0;
    localparam SFU_WCTL = 1;
    localparam NUM_SFU_UNITS = (2);
    localparam INST_LUI =        7'b0110111;
    localparam INST_AUIPC =      7'b0010111;
    localparam INST_JAL =        7'b1101111;
    localparam INST_JALR =       7'b1100111;
    localparam INST_B =          7'b1100011;  
    localparam INST_L =          7'b0000011;  
    localparam INST_S =          7'b0100011;  
    localparam INST_I =          7'b0010011;  
    localparam INST_R =          7'b0110011;  
    localparam INST_V =          7'b1010111;  
    localparam INST_FENCE =      7'b0001111;  
    localparam INST_AMO =        7'b0101111;  
    localparam INST_SYS =        7'b1110011;  
    localparam INST_I_W =        7'b0011011;  
    localparam INST_R_W =        7'b0111011;  
    localparam INST_FL =         7'b0000111;  
    localparam INST_FS =         7'b0100111;  
    localparam INST_FMADD =      7'b1000011;
    localparam INST_FMSUB =      7'b1000111;
    localparam INST_FNMSUB =     7'b1001011;
    localparam INST_FNMADD =     7'b1001111;
    localparam INST_FCI =        7'b1010011;  
    localparam INST_EXT1 =       7'b0001011;  
    localparam INST_EXT2 =       7'b0101011;  
    localparam INST_EXT3 =       7'b1011011;  
    localparam INST_EXT4 =       7'b1111011;  
    localparam INST_R_F7_MUL =   7'b0000001;
    localparam INST_R_F7_ZICOND= 7'b0000111;
    localparam INST_FRM_RNE =    3'b000;   
    localparam INST_FRM_RTZ =    3'b001;   
    localparam INST_FRM_RDN =    3'b010;   
    localparam INST_FRM_RUP =    3'b011;   
    localparam INST_FRM_RMM =    3'b100;   
    localparam INST_FRM_DYN =    3'b111;   
    localparam INST_FRM_BITS =   3;
    localparam INST_OP_BITS =    4;
    localparam INST_FMT_BITS =   2;
    localparam INST_ALU_ADD =    4'b0000;
    localparam INST_ALU_LUI =    4'b0010;
    localparam INST_ALU_AUIPC =  4'b0011;
    localparam INST_ALU_SLTU =   4'b0100;
    localparam INST_ALU_SLT =    4'b0101;
    localparam INST_ALU_SUB =    4'b0111;
    localparam INST_ALU_SRL =    4'b1000;
    localparam INST_ALU_SRA =    4'b1001;
    localparam INST_ALU_CZEQ =   4'b1010;
    localparam INST_ALU_CZNE =   4'b1011;
    localparam INST_ALU_AND =    4'b1100;
    localparam INST_ALU_OR =     4'b1101;
    localparam INST_ALU_XOR =    4'b1110;
    localparam INST_ALU_SLL =    4'b1111;
    localparam INST_ALU_BITS =   4;
    localparam ALU_TYPE_BITS =   2;
    localparam ALU_TYPE_ARITH =  0;
    localparam ALU_TYPE_BRANCH = 1;
    localparam ALU_TYPE_MULDIV = 2;
    localparam ALU_TYPE_OTHER =  3;
    function automatic logic [1:0] inst_alu_class(input logic [INST_ALU_BITS-1:0] op);
        return op[3:2];
    endfunction
    function automatic logic inst_alu_signed(input logic [INST_ALU_BITS-1:0] op);
        return op[0];
    endfunction
    function automatic logic inst_alu_is_sub(input logic [INST_ALU_BITS-1:0] op);
        return op[1];
    endfunction
    function automatic logic inst_alu_is_czero(input logic [INST_ALU_BITS-1:0] op);
        return (op[3:1] == 3'b101);
    endfunction
    localparam INST_BR_BEQ =     4'b0000;
    localparam INST_BR_BNE =     4'b0010;
    localparam INST_BR_BLTU =    4'b0100;
    localparam INST_BR_BGEU =    4'b0110;
    localparam INST_BR_BLT =     4'b0101;
    localparam INST_BR_BGE =     4'b0111;
    localparam INST_BR_JAL =     4'b1000;
    localparam INST_BR_JALR =    4'b1001;
    localparam INST_BR_ECALL =   4'b1010;
    localparam INST_BR_EBREAK =  4'b1011;
    localparam INST_BR_URET =    4'b1100;
    localparam INST_BR_SRET =    4'b1101;
    localparam INST_BR_MRET =    4'b1110;
    localparam INST_BR_OTHER =   4'b1111;
    localparam INST_BR_BITS =    4;
    function automatic logic [1:0] inst_br_class(input logic [INST_BR_BITS-1:0] op);
        return {1'b0, ~op[3]};
    endfunction
    function automatic logic inst_br_is_neg(input logic [INST_BR_BITS-1:0] op);
        return op[1];
    endfunction
    function automatic logic inst_br_is_less(input logic [INST_BR_BITS-1:0] op);
        return op[2];
    endfunction
    function automatic logic inst_br_is_static(input logic [INST_BR_BITS-1:0] op);
        return op[3];
    endfunction
    localparam INST_VOTE_ALL =   2'b00;
    localparam INST_VOTE_ANY =   2'b01;
    localparam INST_VOTE_UNI =   2'b10;
    localparam INST_VOTE_BAL =   2'b11;
    localparam INST_SHFL_UP =    2'b00;
    localparam INST_SHFL_DOWN =  2'b01;
    localparam INST_SHFL_BFLY =  2'b10;
    localparam INST_SHFL_IDX =   2'b11;
    localparam INST_VOTE_BITS =  2;
    localparam INST_SHFL_BITS =  2;
    localparam INST_WGATHER =    4'h8;  
    localparam INST_M_MUL =      3'b000;
    localparam INST_M_MULHU =    3'b001;
    localparam INST_M_MULH =     3'b010;
    localparam INST_M_MULHSU =   3'b011;
    localparam INST_M_DIV =      3'b100;
    localparam INST_M_DIVU =     3'b101;
    localparam INST_M_REM =      3'b110;
    localparam INST_M_REMU =     3'b111;
    localparam INST_M_BITS =     3;
    function automatic logic inst_m_signed(input logic [INST_M_BITS-1:0] op);
        return (~op[0]);
    endfunction
    function automatic logic inst_m_is_mulx(input logic [INST_M_BITS-1:0] op);
        return (~op[2]);
    endfunction
    function automatic logic inst_m_is_mulh(input logic [INST_M_BITS-1:0] op);
        return (op[1:0] != 0);
    endfunction
    function automatic logic inst_m_signed_a(input logic [INST_M_BITS-1:0] op);
        return (op[1:0] != 1);
    endfunction
    function automatic logic inst_m_is_rem(input logic [INST_M_BITS-1:0] op);
        return op[1];
    endfunction
    localparam LSU_FMT_B =       3'b000;
    localparam LSU_FMT_H =       3'b001;
    localparam LSU_FMT_W =       3'b010;
    localparam LSU_FMT_D =       3'b011;
    localparam LSU_FMT_BU =      3'b100;
    localparam LSU_FMT_HU =      3'b101;
    localparam LSU_FMT_WU =      3'b110;
    localparam INST_LSU_LB =     4'b0000;
    localparam INST_LSU_LH =     4'b0001;
    localparam INST_LSU_LW =     4'b0010;
    localparam INST_LSU_LD =     4'b0011;  
    localparam INST_LSU_LBU =    4'b0100;
    localparam INST_LSU_LHU =    4'b0101;
    localparam INST_LSU_LWU =    4'b0110;  
    localparam INST_LSU_SB =     4'b1000;
    localparam INST_LSU_SH =     4'b1001;
    localparam INST_LSU_SW =     4'b1010;
    localparam INST_LSU_SD =     4'b1011;  
    localparam INST_LSU_FENCE_IO = 4'b1110;  
    localparam INST_LSU_FENCE =  4'b1111;
    localparam INST_LSU_BITS =   4;
    localparam INST_FENCE_BITS = 1;
    localparam INST_FENCE_D =    1'h0;
    localparam INST_FENCE_I =    1'h1;
    function automatic logic [2:0] inst_lsu_fmt(input logic [INST_LSU_BITS-1:0] op);
        return op[2:0];
    endfunction
    function automatic logic [1:0] inst_lsu_wsize(input logic [INST_LSU_BITS-1:0] op);
        return op[1:0];
    endfunction
    function automatic logic inst_lsu_is_fence(input logic [INST_LSU_BITS-1:0] op);
        return (op[3:1] == 3'b111);
    endfunction
    function automatic logic inst_lsu_is_fence_io(input logic [INST_LSU_BITS-1:0] op);
        return (op == INST_LSU_FENCE_IO);
    endfunction
    localparam INST_FPU_ADD =    4'b0000;  
    localparam INST_FPU_MUL =    4'b0001;
    localparam INST_FPU_MADD =   4'b0010;  
    localparam INST_FPU_NMADD =  4'b0011;  
    localparam INST_FPU_DIV =    4'b0100;
    localparam INST_FPU_SQRT =   4'b0101;
    localparam INST_FPU_F2I =    4'b1000;  
    localparam INST_FPU_F2U =    4'b1001;  
    localparam INST_FPU_I2F =    4'b1010;  
    localparam INST_FPU_U2F =    4'b1011;  
    localparam INST_FPU_CMP =    4'b1100;  
    localparam INST_FPU_F2F =    4'b1101;  
    localparam INST_FPU_MISC =   4'b1110;  
    localparam INST_FPU_F2H =    4'b1111;
    localparam INST_FPU_BITS =   4;
    function automatic logic inst_fpu_is_class(input logic [INST_FPU_BITS-1:0] op, input logic [INST_FRM_BITS-1:0] frm);
        return (op == INST_FPU_MISC && frm == 3);
    endfunction
    function automatic logic inst_fpu_is_mvxw(input logic [INST_FPU_BITS-1:0] op, input logic [INST_FRM_BITS-1:0] frm);
        return (op == INST_FPU_MISC && frm == 4);
    endfunction
    localparam INST_SFU_TMC =    4'h0;
    localparam INST_SFU_WSPAWN = 4'h1;
    localparam INST_SFU_SPLIT =  4'h2;
    localparam INST_SFU_JOIN =   4'h3;
    localparam INST_SFU_BAR =    4'h4;
    localparam INST_SFU_PRED =   4'h5;
    localparam INST_SFU_CSRRW =  4'h6;
    localparam INST_SFU_CSRRS =  4'h7;
    localparam INST_SFU_CSRRC =  4'h8;
    localparam INST_SFU_WSYNC =  4'hA;
    localparam INST_SFU_BITS =   4;
    function automatic logic [3:0] inst_sfu_csr(input logic [2:0] funct3);
        return (4'h6 + 4'(funct3[1:0]) - 4'h1);
    endfunction
    function automatic logic inst_sfu_is_wctl(input logic [INST_SFU_BITS-1:0] op);
        return (op == INST_SFU_TMC)
            || (op == INST_SFU_WSPAWN)
            || (op == INST_SFU_SPLIT)
            || (op == INST_SFU_JOIN)
            || (op == INST_SFU_BAR)
            || (op == INST_SFU_PRED)
            || (op == INST_SFU_WSYNC);
    endfunction
    function automatic logic inst_sfu_is_csr(input logic [INST_SFU_BITS-1:0] op);
        return (op >= 6 && op <= 8);
    endfunction
    localparam ISSUE_ISW_BITS = $clog2(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))));
    localparam ISSUE_ISW_SIZEW = $clog2(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) + 1);
    localparam ISSUE_ISW_W = (((ISSUE_ISW_BITS) > 0) ? (ISSUE_ISW_BITS) : 1);
    localparam PER_ISSUE_WARPS = 4 / ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))));
    localparam ISSUE_WIS_BITS = $clog2(PER_ISSUE_WARPS);
    localparam ISSUE_WIS_W = (((ISSUE_WIS_BITS) > 0) ? (ISSUE_WIS_BITS) : 1);
    localparam NUM_TRAP_CSRS = 5;
    localparam DISPATCH_QSIZE = 4;
    localparam PER_OPC_WARPS = ((PER_ISSUE_WARPS + (((((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) != 0) ? (((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) : 1) - 1) / ((((((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) != 0) ? (((4) / (((4) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) : 1)));
    localparam PER_OPC_NW_BITS = $clog2(PER_OPC_WARPS);
    localparam PER_OPC_NW_W = (((PER_OPC_NW_BITS) > 0) ? (PER_OPC_NW_BITS) : 1);
    function automatic logic [NW_WIDTH-1:0] wis_to_wid(
        input logic [ISSUE_WIS_W-1:0] wis,
        input logic [ISSUE_ISW_W-1:0] isw
    );
        if (ISSUE_WIS_BITS == 0) begin
            wis_to_wid = NW_WIDTH'(isw);
        end else if (ISSUE_ISW_BITS == 0) begin
            wis_to_wid = NW_WIDTH'(wis);
        end else begin
            wis_to_wid = NW_WIDTH'({wis, isw});
        end
    endfunction
    function automatic logic [ISSUE_ISW_W-1:0] wid_to_isw(
        input logic [NW_WIDTH-1:0] wid
    );
        if (ISSUE_ISW_BITS != 0) begin
            wid_to_isw = wid[ISSUE_ISW_W-1:0];
        end else begin
            wid_to_isw = 0;
        end
    endfunction
    function automatic logic [ISSUE_WIS_W-1:0] wid_to_wis(
        input logic [NW_WIDTH-1:0] wid
    );
        if (ISSUE_WIS_BITS != 0) begin
            wid_to_wis = ISSUE_WIS_W'(wid >> ISSUE_ISW_BITS);
        end else begin
            wid_to_wis = 0;
        end
    endfunction
    localparam FETCH_FSW_BITS  = $clog2(((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))))))));
    localparam FETCH_FSW_W     = (((FETCH_FSW_BITS) > 0) ? (FETCH_FSW_BITS) : 1);
    localparam PER_FETCH_WARPS = 4 / ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))));
    localparam FETCH_WFS_BITS  = $clog2(PER_FETCH_WARPS);
    localparam FETCH_WFS_W     = (((FETCH_WFS_BITS) > 0) ? (FETCH_WFS_BITS) : 1);
    function automatic logic [NW_WIDTH-1:0] wfs_to_wid(
        input logic [FETCH_WFS_W-1:0] wfs,
        input logic [FETCH_FSW_W-1:0] fsw
    );
        if (FETCH_WFS_BITS == 0) begin
            wfs_to_wid = NW_WIDTH'(fsw);
        end else if (FETCH_FSW_BITS == 0) begin
            wfs_to_wid = NW_WIDTH'(wfs);
        end else begin
            wfs_to_wid = NW_WIDTH'({wfs, fsw});
        end
    endfunction
    function automatic logic [FETCH_FSW_W-1:0] wid_to_fsw(
        input logic [NW_WIDTH-1:0] wid
    );
        if (FETCH_FSW_BITS != 0) begin
            wid_to_fsw = wid[FETCH_FSW_W-1:0];
        end else begin
            wid_to_fsw = 0;
        end
    endfunction
    localparam FETCH_ALU_PORTS = (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) > ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) ? (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) / ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) : 1;
    localparam FETCH_SFU_PORTS = (1 > ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) ? (1 / ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))) : 1;
    function automatic logic [FETCH_WFS_W-1:0] wid_to_wfs(
        input logic [NW_WIDTH-1:0] wid
    );
        if (FETCH_WFS_BITS != 0) begin
            wid_to_wfs = FETCH_WFS_W'(wid >> FETCH_FSW_BITS);
        end else begin
            wid_to_wfs = 0;
        end
    endfunction
    localparam SFU_BLOCK_BITS  = $clog2(1);
    localparam SFU_BLOCK_W     = (((SFU_BLOCK_BITS) > 0) ? (SFU_BLOCK_BITS) : 1);
    localparam SFU_BLOCK_WARPS = 4 / 1;
    localparam SFU_BLOCK_NW_BITS = $clog2(SFU_BLOCK_WARPS);
    localparam SFU_BLOCK_NW_W  = (((SFU_BLOCK_NW_BITS) > 0) ? (SFU_BLOCK_NW_BITS) : 1);
    function automatic logic [SFU_BLOCK_W-1:0] wid_to_sfu_block(
        input logic [NW_WIDTH-1:0] wid
    );
        if (SFU_BLOCK_BITS != 0) begin
            wid_to_sfu_block = wid[SFU_BLOCK_W-1:0];
        end else begin
            wid_to_sfu_block = 0;
        end
    endfunction
    function automatic logic [SFU_BLOCK_NW_W-1:0] wid_to_sfu_local(
        input logic [NW_WIDTH-1:0] wid
    );
        if (SFU_BLOCK_NW_BITS != 0) begin
            wid_to_sfu_local = SFU_BLOCK_NW_W'(wid >> SFU_BLOCK_BITS);
        end else begin
            wid_to_sfu_local = 0;
        end
    endfunction
    function automatic logic [NW_WIDTH-1:0] sfu_local_to_wid(
        input logic [SFU_BLOCK_NW_W-1:0] lid,
        input logic [SFU_BLOCK_W-1:0]    block
    );
        if (SFU_BLOCK_NW_BITS == 0) begin
            sfu_local_to_wid = NW_WIDTH'(block);
        end else if (SFU_BLOCK_BITS == 0) begin
            sfu_local_to_wid = NW_WIDTH'(lid);
        end else begin
            sfu_local_to_wid = NW_WIDTH'({lid, block});
        end
    endfunction
    localparam BACKEND_SLICES = (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))))
                             && (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))))
                             && (1 == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))))
                             && (!1 || (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))
                             && (!0 || (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))));
    localparam COMPUTE_SLICES = BACKEND_SLICES && (((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))))))) == ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))));
    localparam SLICE_RETIRE = COMPUTE_SLICES && (1 > 1);
    localparam MTX_NT           = 64;
    localparam MTX_NR           = 8;
    localparam MTX_TILE_CAP     = MTX_NT * MTX_NR;
    localparam MTX_LG_TILE_CAP  = $clog2(MTX_TILE_CAP);
    localparam MTX_TILE_EN      = MTX_LG_TILE_CAP / 2;
    localparam MTX_TILE_EM      = MTX_LG_TILE_CAP - MTX_TILE_EN;
    localparam MTX_TILE_M       = 1 << MTX_TILE_EM;
    localparam MTX_TILE_N       = 1 << MTX_TILE_EN;
    localparam MTX_TILE_K       = MTX_TILE_CAP / ((MTX_TILE_M > MTX_TILE_N) ? MTX_TILE_M : MTX_TILE_N);
    localparam MTX_BLOCK_CAP    = MTX_NT;
    localparam MTX_LG_BLOCK_CAP = $clog2(MTX_BLOCK_CAP);
    localparam MTX_BLOCK_EN     = MTX_LG_BLOCK_CAP / 2;
    localparam MTX_BLOCK_EM     = MTX_LG_BLOCK_CAP - MTX_BLOCK_EN;
    localparam MTX_TC_M         = 1 << MTX_BLOCK_EM;
    localparam MTX_TC_N         = 1 << MTX_BLOCK_EN;
    localparam MTX_TC_K         = MTX_BLOCK_CAP / ((MTX_TC_M > MTX_TC_N) ? MTX_TC_M : MTX_TC_N);
    localparam MTX_M_STEPS      = MTX_TILE_M / MTX_TC_M;
    localparam MTX_N_STEPS      = MTX_TILE_N / MTX_TC_N;
    localparam MTX_K_STEPS      = MTX_TILE_K / MTX_TC_K;
    localparam MTX_B_SUB_BLOCKS = MTX_BLOCK_CAP / (MTX_TC_K * MTX_TC_N);
    localparam MTX_NRB          = (MTX_TILE_N * MTX_TILE_K) / MTX_NT;
    localparam MTX_SYM_SPARSE   = (MTX_BLOCK_EM == MTX_BLOCK_EN);
    localparam MTX_LG_M         = $clog2(MTX_M_STEPS);
    localparam MTX_LG_N         = $clog2(MTX_N_STEPS);
    localparam MTX_LG_K         = $clog2(MTX_K_STEPS);
    localparam MTX_LG_B_SB      = $clog2(MTX_B_SUB_BLOCKS);
    localparam MTX_LDM_A        = 5'b00000;  
    localparam MTX_LDM_A_SP     = 5'b00001;  
    localparam MTX_LDM_B        = 5'b00110;  
    localparam MTX_LDM_B_SP     = 5'b00111;  
    localparam MTX_LDM_C        = 5'b01000;  
    localparam MTX_LDM_WG_C     = 5'b11000;  
    localparam MTX_LDM_IDX_A    = 3'd0;
    localparam MTX_LDM_IDX_A_SP = 3'd1;
    localparam MTX_LDM_IDX_B    = 3'd2;
    localparam MTX_LDM_IDX_B_SP = 3'd3;
    localparam MTX_LDM_IDX_C    = 3'd4;
    localparam MTX_LDM_IDX_WG_C = 3'd5;
    localparam MTX_LDM_LG_CS_K  = $clog2(MTX_TC_K * 4);
    localparam MTX_LDM_LG_CS_N  = $clog2(MTX_TC_N * 4);
    localparam MTX_LDM_LG_K_SP  = (MTX_LG_K > 0) ? (MTX_LG_K - 1) : 0;
    localparam MTX_LDM_COL_W    = MTX_LDM_LG_CS_K + 4;
    typedef struct packed {
        logic [1:0]           grp;
        logic [MTX_LDM_COL_W-1:0] col;
    } mtx_ldm_uop_t;
    function automatic logic mtx_ldm_valid(input logic [4:0] shape);
        case (shape)
            MTX_LDM_A,
            MTX_LDM_A_SP,
            MTX_LDM_B,
            MTX_LDM_C,
            MTX_LDM_WG_C: return 1'b1;
            MTX_LDM_B_SP: return 1'(MTX_SYM_SPARSE);
            default:  return 1'b0;
        endcase
    endfunction
    function automatic logic [4:0] mtx_ldm_code(input logic [4:0] shape);
        case (shape)
            MTX_LDM_A:    return 5'(MTX_LDM_IDX_A);
            MTX_LDM_A_SP: return 5'(MTX_LDM_IDX_A_SP);
            MTX_LDM_B:    return 5'(MTX_LDM_IDX_B);
            MTX_LDM_B_SP: return 5'(MTX_LDM_IDX_B_SP);
            MTX_LDM_C:    return 5'(MTX_LDM_IDX_C);
            default:  return 5'(MTX_LDM_IDX_WG_C);
        endcase
    endfunction
    function automatic int unsigned mtx_ldm_count(input logic [2:0] idx);
        case (idx)
            MTX_LDM_IDX_A_SP: return 4;
            MTX_LDM_IDX_B,
            MTX_LDM_IDX_B_SP: return MTX_NRB;
            default:      return 8;
        endcase
    endfunction
    function automatic logic mtx_ldm_is8(input logic [4:0] shape);
        return (mtx_ldm_count(3'(mtx_ldm_code(shape))) == 8);
    endfunction
    function automatic logic [2:0] mtx_ra_off(input logic [(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1:0] m,
                                              input logic [(((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)-1:0] k);
        if (MTX_LG_B_SB == 0) begin
            return 3'({m[0], ~m[(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1], k[0]});
        end else begin
            return 3'({k[0], ~m[0], m[0] ^ k[(((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)-1]});
        end
    endfunction
    function automatic logic [2:0] mtx_rb_off(input logic [(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1:0] n,
                                              input logic [(((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)-1:0] k);
        if (MTX_LG_B_SB == 0) begin
            return 3'({n[0] ^ k[0], ~k[0]});
        end else begin
            return 3'({k[0], k[(((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)-1] ^ n[(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1], ~n[(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1]});
        end
    endfunction
    function automatic logic [2:0] mtx_rc_off(input logic [(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1:0] m,
                                              input logic [(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1:0] n);
        if (MTX_LG_B_SB == 0) begin
            return 3'({m[0], ~m[(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1], ~(m[(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1] ^ n[0])});
        end else begin
            return 3'({n[0], ~m[0], n[(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1]});
        end
    endfunction
    function automatic logic [2:0] mtx_rb_off_sp(input logic [(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1:0] n,
                                                 input logic [(((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)-1:0] k);
        return 3'({n[(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1], ~(n[0] ^ k[0]), ~k[0]});
    endfunction
    function automatic logic [2:0] mtx_rc_off_sp(input logic [(((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)-1:0] m,
                                                 input logic [(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1:0] n);
        return 3'({n[(((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)-1], m[0], ~(m[0] ^ n[0])});
    endfunction
    function automatic mtx_ldm_uop_t mtx_ldm_uop(input logic [2:0] idx, input logic [2:0] e);
        mtx_ldm_uop_t u;
        logic [2:0] m, n, k;
        u = '0;
        m = '0;
        n = '0;
        k = '0;
        case (idx)
            MTX_LDM_IDX_A: begin
                if (MTX_LG_B_SB == 0) begin
                    m = {1'b0, ~e[1], e[2]};
                    k = {2'b0, e[0]};
                end else begin
                    m = {2'b0, ~e[1]};
                    k = {1'b0, e[0] ^ ~e[1], e[2]};
                end
                u.grp = 2'(m);
                u.col = MTX_LDM_COL_W'(k) << MTX_LDM_LG_CS_K;
            end
            MTX_LDM_IDX_A_SP: begin
                u.grp = 2'(e >> MTX_LDM_LG_K_SP);
                u.col = MTX_LDM_COL_W'(e & 3'((1 << MTX_LDM_LG_K_SP) - 1)) << MTX_LDM_LG_CS_K;
            end
            MTX_LDM_IDX_B: begin
                if (MTX_LG_B_SB == 0) begin
                    k = {2'b0, ~e[0]};
                    n = {2'b0, e[1] ^ ~e[0]};
                end else begin
                    n = {2'b0, ~e[0]};
                    k = {1'b0, e[1] ^ ~e[0], e[2]};
                end
                u.grp = 2'(n);
                u.col = MTX_LDM_COL_W'(k) << MTX_LDM_LG_CS_K;
            end
            MTX_LDM_IDX_B_SP: begin
                u.grp = 2'(e);
            end
            MTX_LDM_IDX_C: begin
                if (MTX_LG_B_SB == 0) begin
                    m = {1'b0, ~e[1], e[2]};
                    n = {2'b0, e[0] ^ e[1]};
                end else begin
                    m = {2'b0, ~e[1]};
                    n = {1'b0, e[0], e[2]};
                end
                u.grp = 2'(m);
                u.col = MTX_LDM_COL_W'(n) << MTX_LDM_LG_CS_N;
            end
            default: begin
                u.grp = 2'(e[0]);
                u.col = MTX_LDM_COL_W'(e >> 1) << MTX_LDM_LG_CS_N;
            end
        endcase
        return u;
    endfunction
    function automatic int mtx_ldm_reg(input logic [2:0] idx, input mtx_ldm_uop_t u);
        int unsigned g, c, ck, cn;
        g  = int'(u.grp);
        c  = int'(u.col);
        ck = c >> MTX_LDM_LG_CS_K;
        cn = c >> MTX_LDM_LG_CS_N;
        case (idx)
            MTX_LDM_IDX_A: begin
                if ((ck << MTX_LDM_LG_CS_K) != c || g >= MTX_M_STEPS || ck >= MTX_K_STEPS) begin
                    return -1;
                end
                return int'(mtx_ra_off((((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)'(g), (((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)'(ck)));
            end
            MTX_LDM_IDX_A_SP: begin
                if ((ck << MTX_LDM_LG_CS_K) != c || g >= MTX_M_STEPS || ck >= (1 << MTX_LDM_LG_K_SP)) begin
                    return -1;
                end
                return int'((g << MTX_LDM_LG_K_SP) | ck);
            end
            MTX_LDM_IDX_B: begin
                if ((ck << MTX_LDM_LG_CS_K) != c || (g << MTX_LG_B_SB) >= (((MTX_N_STEPS) > (1 << MTX_LG_B_SB)) ? (MTX_N_STEPS) : (1 << MTX_LG_B_SB)) || ck >= MTX_K_STEPS) begin
                    return -1;
                end
                return int'(mtx_rb_off((((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)'(g << MTX_LG_B_SB), (((MTX_LG_K) > 0) ? (MTX_LG_K) : 1)'(ck)));
            end
            MTX_LDM_IDX_B_SP: begin
                if (c != 0 || g >= MTX_NRB) begin
                    return -1;
                end
                return int'(g);
            end
            MTX_LDM_IDX_C: begin
                if ((cn << MTX_LDM_LG_CS_N) != c || g >= MTX_M_STEPS || cn >= MTX_N_STEPS) begin
                    return -1;
                end
                return int'(mtx_rc_off((((MTX_LG_M) > 0) ? (MTX_LG_M) : 1)'(g), (((MTX_LG_N) > 0) ? (MTX_LG_N) : 1)'(cn)));
            end
            default: begin
                if ((cn << MTX_LDM_LG_CS_N) != c || g >= 2 || cn >= 4) begin
                    return -1;
                end
                return int'((cn << 1) | g);
            end
        endcase
    endfunction
    typedef struct packed {
        logic [64-1:0] tmask;
    } tmc_t;
    typedef struct packed {
        logic [4-1:0]  wmask;
        logic [PC_BITS-1:0]     pc;
    } wspawn_t;
    typedef struct packed {
        logic                   is_dvg;
        logic [64-1:0] then_tmask;
        logic [64-1:0] else_tmask;
        logic [PC_BITS-1:0]     next_pc;
    } split_t;
    typedef struct packed {
        logic [64-1:0] tmask;
        logic [DV_STACK_SIZEW-1:0] stack_ptr;
    } join_t;
    typedef struct packed {
        logic [NB_WIDTH-1:0]    id;
        logic                   is_event;
        logic                   is_global;
        logic                   is_arrive;
        logic                   is_sync;
        logic                   phase;
        logic [BAR_SIZE_W-1:0]  size_m1;
    } barrier_t;
    localparam WSH_BAR    = 2'd0;
    localparam WSH_WSPAWN = 2'd1;
    localparam WSH_EXIT   = 2'd2;
    typedef struct packed {
        logic [1:0]             kind;
        logic                   has_rsp;     
        logic [NW_WIDTH-1:0]    wid;
        barrier_t               bar;
        logic [BAR_ADDR_W-1:0]  bar_addr;
        wspawn_t                wspawn;
        logic [32-1:0] mscratch;   
    } warp_shared_req_t;
    typedef struct packed {
        logic [NB_WIDTH-1:0] id;
        logic [CORE_ID_WIDTH-1:0] size_m1;
        logic [CORE_ID_WIDTH-1:0] core_id;
    } gbar_req_t;
    typedef struct packed {
        logic [NB_WIDTH-1:0] id;
    } gbar_rsp_t;
    typedef struct packed {
        logic [BAR_ADDR_W-1:0] addr;
        logic                  is_done;
    } txbar_t;
    typedef struct packed {
        logic                         rw;
        logic [VX_DCR_ADDR_WIDTH-1:0] addr;
        logic [VX_DCR_DATA_WIDTH-1:0] data;
    } dcr_req_t;
    typedef struct packed {
        logic [VX_DCR_DATA_WIDTH-1:0] data;
    } dcr_rsp_t;
    localparam FRAG_STAMP_BITS = 2 * (15 - 1) + 4 + 16;
    localparam FRAG_QUAD_LANES = 4;
    localparam FRAG_LANE_BITS  = FRAG_STAMP_BITS / FRAG_QUAD_LANES;
    localparam KMU_FRAG_BITS = 0;
    localparam KMU_FRAG_PAYLOAD_BITS = 0;
    localparam KMU_COMPUTE_BITS = 3*32                     
                                + 3*32                     
                                + 3*(CTA_TID_WIDTH+1)      
                                + (CTA_TID_WIDTH+1)        
                                + 3*CTA_TID_WIDTH          
                                + (NW_WIDTH+1)             
                                + 1;                       
    localparam KMU_ARGS_BITS = (((KMU_COMPUTE_BITS) > (KMU_FRAG_PAYLOAD_BITS)) ? (KMU_COMPUTE_BITS) : (KMU_FRAG_PAYLOAD_BITS)) + 1;
    typedef struct packed {
        logic [KMU_ARGS_BITS-KMU_COMPUTE_BITS-1:0] __padding;
        logic [2:0][31:0]              grid_dim;
        logic [2:0][31:0]              block_idx;
        logic [2:0][CTA_TID_WIDTH:0]   block_dim;
        logic [CTA_TID_WIDTH:0]        block_size;
        logic [2:0][CTA_TID_WIDTH-1:0] warp_step;
        logic [NW_WIDTH:0]             cluster_size;
        logic                          is_first_of_cluster;
    } kmu_compute_args_t;
    typedef union packed {
        kmu_compute_args_t  compute;
    } kmu_args_t;
    typedef struct packed {
        logic                              kind;    
        logic [PC_BITS-1:0]                PC;
        logic [PC_BITS-1:0]                entry;
        logic [32-1:0] param;
        logic [7:0]                        ctx_id;
        logic [($clog2((((16384) > (((64) * (2048)))) ? (16384) : (((64) * (2048)))))):0]    aligned_lmem_size;
        kmu_args_t                         args;    
    } kmu_req_t;
    localparam KMU_DATAW = $bits(kmu_req_t);
    localparam KMU_KIND_COMPUTE  = 1'b0;    
    localparam KMU_KIND_FRAGMENT = 1'b1;    
    localparam KMU_KIND_BITS     = 1;
    localparam KMU_DEST_W = ((($clog2(1 * 1)) > 0) ? ($clog2(1 * 1)) : 1);
    localparam KMU_DEST_DIV_SOCKET  = 1;
    localparam KMU_DEST_DIV_CLUSTER = 1;
    localparam KMU_DEST_DIV_DEVICE  = KMU_DEST_DIV_CLUSTER * NUM_SOCKETS;
    typedef struct packed {
        logic [NCTA_WIDTH-1:0] cta_id;
        logic [NW_WIDTH-1:0] cta_rank;
        logic [NW_WIDTH:0] cta_size;
        logic [2:0][31:0] block_idx;
        logic [2:0][CTA_TID_WIDTH:0] block_dim;
        logic [2:0][31:0] grid_dim;
        logic [PC_BITS-1:0] entry;
        logic [32-1:0] param;
        logic [32-1:0] lmem_addr;
        logic [31:0] cluster_size;
    } cta_csrs_t;
    typedef struct packed {
        logic [NW_WIDTH:0]              cta_size;
        logic [2:0][31:0]               block_idx;
        logic [2:0][CTA_TID_WIDTH:0]    block_dim;
        logic [2:0][31:0]               grid_dim;
        logic [PC_BITS-1:0]             entry;
        logic [32-1:0] param;
        logic [32-1:0] lmem_addr;
        logic [31:0]                    cluster_size;
    } cta_ctx_t;
    localparam CTA_TID_LANE_BITS = 3 * CTA_TID_WIDTH;
    localparam LANE_LAUNCH_BITS = CTA_TID_LANE_BITS;
    typedef logic [LANE_LAUNCH_BITS-1:0] cta_lane_t;
    typedef struct packed {
        logic [NW_WIDTH-1:0]                     cta_rank;
        cta_lane_t [64-1:0]     lane_launch;
    } cta_warp_t;
    typedef struct packed {
        logic                   ctx_write;
        logic [NCTA_WIDTH-1:0]  ctx_waddr;
        cta_ctx_t               ctx_wdata;
    } cta_bcast_t;
    typedef struct packed {
        logic                   warp_write;
        logic [NW_WIDTH-1:0]    warp_waddr;
        cta_warp_t              warp_wdata;
        logic                   id_write;
        logic [NW_WIDTH-1:0]    id_wid;
        logic [NCTA_WIDTH-1:0]  id_cta;
    } cta_lane_bcast_t;
    typedef struct packed {
        logic                   valid;
        logic [NW_WIDTH-1:0]    wid;
        logic                   taken;
        logic [PC_BITS-1:0]     dest;
        logic                   is_trap;
        logic                   is_mret;
        logic [3:0]             trap_cause;
    } sched_branch_t;
    typedef struct packed {
        logic                   tmc_valid;
        logic                   split_valid;
        logic                   sjoin_valid;
        logic                   wsync_valid;
        logic [NW_WIDTH-1:0]    wid;
        tmc_t                   tmc;
        split_t                 split;
        join_t                  sjoin;
    } sched_wctl_t;
    typedef struct packed {
        logic                   valid;
        logic [NW_WIDTH-1:0]    wid;
        logic [32-1:0] data;
        logic [NUM_TRAP_CSRS-1:0] trap_valid;
        logic [32-1:0] trap_data;
    } sched_csr_wr_t;
    typedef struct packed {
        logic [64-1:0] thread_mask;
        logic [32-1:0] mscratch;
        logic [32-1:0] mstatus;
        logic [32-1:0] mtvec;
        logic [32-1:0] mepc;
        logic [32-1:0] mcause;
        logic [32-1:0] mtval;
        logic [NW_WIDTH-1:0]    cta_rank;
        cta_lane_t [64-1:0] cta_lane;
    } sched_csr_rd_t;
    localparam INST_ARGS_BITS = 3 + ALU_TYPE_BITS + 20 + 2;
    typedef struct packed {
        logic imm_hi;
        logic imm_x2;
        logic use_PC;
        logic use_imm;
        logic is_w;
        logic [ALU_TYPE_BITS-1:0] xtype;
        logic [19:0] imm20;
    } alu_args_t;
    typedef struct packed {
        logic imm_hi;
        logic imm_x2;
        logic use_PC;
        logic use_imm;
        logic is_rvc;
        logic [ALU_TYPE_BITS-1:0] xtype;
        logic [19:0] imm20;
    } br_args_t;
    typedef struct packed {
        logic [(INST_ARGS_BITS-INST_FRM_BITS-INST_FMT_BITS)-1:0] __padding;
        logic [INST_FRM_BITS-1:0] frm;
        logic [INST_FMT_BITS-1:0] fmt;
    } fpu_args_t;
    typedef struct packed {
        logic [(INST_ARGS_BITS-1-1-12-2-1-1-$bits(amo_op_e)-2-2)-1:0] __padding;
        logic [1:0]                 export_mask;
        logic                       amo_valid;
        logic                       amo_unsigned;
        amo_op_e                    amo_op;
        logic                       amo_aq;
        logic                       amo_rl;
        logic [1:0]                 pack;
        logic                       is_store;
        logic                       is_float;
        logic [11:0]                offset;
    } lsu_args_t;
    typedef struct packed {
        logic [(INST_ARGS_BITS-1-12-5)-1:0] __padding;
        logic use_imm;
        logic [12-1:0] addr;
        logic [4:0] imm5;
    } csr_args_t;
    typedef struct packed {
        logic [(INST_ARGS_BITS-3)-1:0] __padding;
        logic is_cond_neg;
        logic is_sync_bar;
        logic is_bar_arrive;
    } wctl_args_t;
    typedef union packed {
        alu_args_t  alu;
        br_args_t   br;
        fpu_args_t  fpu;
        lsu_args_t  lsu;
        csr_args_t  csr;
        wctl_args_t wctl;
    } op_args_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]  uuid;
        logic [NW_WIDTH-1:0]    wid;
        logic [NCTA_WIDTH-1:0]  cta_id;
        logic [64-1:0] tmask;
        logic [PC_BITS-1:0]     PC;
        logic [31:0]            instr;
    } fetch_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]      uuid;
        logic [NW_WIDTH-1:0]        wid;
        logic [NCTA_WIDTH-1:0]      cta_id;
        logic [64-1:0]    tmask;
        logic [PC_BITS-1:0]         PC;
        logic [EX_BITS-1:0]         ex_type;
        logic [INST_OP_BITS-1:0]    op_type;
        op_args_t                   op_args;
        logic                       wb;
        logic [NUM_XREGS-1:0]       rd_xregs;
        logic [NUM_XREGS-1:0]       wr_xregs;
        logic [NUM_SRC_OPDS-1:0]    used_rs;
        logic [NUM_REGS_BITS-1:0]   rd;
        logic [BYTESEL_BITS-1:0]    bytesel;
        logic [NUM_REGS_BITS-1:0]   rs1;
        logic [NUM_REGS_BITS-1:0]   rs2;
        logic [NUM_REGS_BITS-1:0]   rs3;
    } decode_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]      uuid;
        logic [NW_WIDTH-1:0]        wid;
        logic [NCTA_WIDTH-1:0]      cta_id;
        logic [64-1:0]    tmask;
        logic [PC_BITS-1:0]         PC;
        logic [EX_BITS-1:0]         ex_type;
        logic [INST_OP_BITS-1:0]    op_type;
        op_args_t                   op_args;
        logic                       wb;
        logic [NUM_XREGS-1:0]       rd_xregs;
        logic [NUM_XREGS-1:0]       wr_xregs;
        logic [NUM_SRC_OPDS-1:0]    used_rs;
        logic [NUM_REGS_BITS-1:0]   rd;
        logic [BYTESEL_BITS-1:0]    bytesel;
        logic [NUM_REGS_BITS-1:0]   rs1;
        logic [NUM_REGS_BITS-1:0]   rs2;
        logic [NUM_REGS_BITS-1:0]   rs3;
        logic                       fu_lock;
        logic                       fu_unlock;
    } ibuffer_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]      uuid;
        logic [ISSUE_WIS_W-1:0]     wis;
        logic [NCTA_WIDTH-1:0]      cta_id;
        logic [64-1:0]    tmask;
        logic [PC_BITS-1:0]         PC;
        logic [EX_BITS-1:0]         ex_type;
        logic [INST_OP_BITS-1:0]    op_type;
        op_args_t                   op_args;
        logic                       wb;
        logic [NUM_XREGS-1:0]       wr_xregs;
        logic [NUM_SRC_OPDS-1:0]    used_rs;
        logic [NUM_REGS_BITS-1:0]   rd;
        logic [BYTESEL_BITS-1:0]    bytesel;
        logic [NUM_REGS_BITS-1:0]   rs1;
        logic [NUM_REGS_BITS-1:0]   rs2;
        logic [NUM_REGS_BITS-1:0]   rs3;
    } scoreboard_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]              uuid;
        logic [ISSUE_WIS_W-1:0]             wis;
        logic [NCTA_WIDTH-1:0]              cta_id;
        logic [SIMD_IDX_W-1:0]              sid;
        logic [64-1:0]             tmask;
        logic [PC_BITS-1:0]                 PC;
        logic [EX_BITS-1:0]                 ex_type;
        logic [INST_OP_BITS-1:0]            op_type;
        op_args_t                           op_args;
        logic                               wb;
        logic [NUM_XREGS-1:0]               wr_xregs;
        logic [NUM_REGS_BITS-1:0]           rd;
        logic [BYTESEL_BITS-1:0]            bytesel;
        logic [64-1:0][32-1:0]  rs1_data;
        logic [64-1:0][32-1:0]  rs2_data;
        logic [64-1:0][32-1:0]  rs3_data;
        logic                               sop;
        logic                               eop;
    } operands_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]              uuid;
        logic [ISSUE_WIS_W-1:0]             wis;
        logic [NCTA_WIDTH-1:0]              cta_id;
        logic [SIMD_IDX_W-1:0]              sid;
        logic [64-1:0]             tmask;
        logic [PC_BITS-1:0]                 PC;
        logic                               wb;
        logic [NUM_XREGS-1:0]               wr_xregs;
        logic [NUM_REGS_BITS-1:0]           rd;
        logic [BYTESEL_BITS-1:0]            bytesel;
        logic [INST_OP_BITS-1:0]            op_type;
        op_args_t                           op_args;
        logic [64-1:0][32-1:0]  rs1_data;
        logic [64-1:0][32-1:0]  rs2_data;
        logic [64-1:0][32-1:0]  rs3_data;
        logic                               sop;
        logic                               eop;
    } dispatch_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]              uuid;
        logic [NW_WIDTH-1:0]                wid;
        logic [NCTA_WIDTH-1:0]              cta_id;
        logic [SIMD_IDX_W-1:0]              sid;
        logic [64-1:0]             tmask;
        logic [PC_BITS-1:0]                 PC;
        logic                               wb;
        logic [NUM_XREGS-1:0]               wr_xregs;
        logic [NUM_REGS_BITS-1:0]           rd;
        logic [BYTESEL_BITS-1:0]            bytesel;
        logic [64-1:0][32-1:0]  data;
        logic                               sop;
        logic                               eop;
    } commit_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]              uuid;
        logic [ISSUE_WIS_W-1:0]             wis;
        logic [PER_ISSUE_WARPS-1:0]         eop_wis;  
        logic [NCTA_WIDTH-1:0]              cta_id;
        logic [SIMD_IDX_W-1:0]              sid;
        logic [64-1:0]             tmask;
        logic [PC_BITS-1:0]                 PC;
        logic                               wb;
        logic [NUM_XREGS-1:0]               wr_xregs;
        logic [NUM_REGS_BITS-1:0]           rd;
        logic [64-1:0][XLENB-1:0]  byteen;
        logic [64-1:0][32-1:0]  data;
        logic                               sop;
        logic                               eop;
    } writeback_t;
    typedef struct packed {
        logic [UUID_WIDTH-1:0]              uuid;
        logic [NW_WIDTH-1:0]                wid;
        logic [NCTA_WIDTH-1:0]              cta_id;
        logic [64-1:0]            tmask;
        logic [PC_BITS-1:0]                 PC;
    } schedule_t;
    typedef struct packed { 
        logic [UUID_WIDTH-1:0]           uuid; 
        logic [NW_WIDTH-1:0]             wid; 
        logic [NCTA_WIDTH-1:0]           cta_id; 
        logic [64-1:0]            tmask; 
        logic [(((64 / 64) > 1) ? $clog2(64 / 64) : 1)-1:0] pid; 
        logic                            sop; 
        logic                            eop; 
        logic [PC_BITS-1:0]              PC; 
        logic                            wb; 
        logic [NUM_XREGS-1:0]            wr_xregs; 
        logic [NUM_REGS_BITS-1:0]        rd; 
        logic [BYTESEL_BITS-1:0]         bytesel; 
    } alu_header_t; 
    typedef struct packed { 
        alu_header_t              header; 
        logic [INST_OP_BITS-1:0]         op_type; 
        op_args_t                        op_args; 
        logic [64-1:0][32-1:0] rs1_data; 
        logic [64-1:0][32-1:0] rs2_data; 
        logic [64-1:0][32-1:0] rs3_data; 
    } alu_execute_t; 
    typedef struct packed { 
        alu_header_t              header; 
        logic [64-1:0][32-1:0] data; 
    } alu_result_t;
    typedef struct packed { 
        logic [UUID_WIDTH-1:0]           uuid; 
        logic [NW_WIDTH-1:0]             wid; 
        logic [NCTA_WIDTH-1:0]           cta_id; 
        logic [64-1:0]            tmask; 
        logic [(((64 / 64) > 1) ? $clog2(64 / 64) : 1)-1:0] pid; 
        logic                            sop; 
        logic                            eop; 
        logic [PC_BITS-1:0]              PC; 
        logic                            wb; 
        logic [NUM_XREGS-1:0]            wr_xregs; 
        logic [NUM_REGS_BITS-1:0]        rd; 
        logic [BYTESEL_BITS-1:0]         bytesel; 
    } lsu_header_t; 
    typedef struct packed { 
        lsu_header_t              header; 
        logic [INST_OP_BITS-1:0]         op_type; 
        op_args_t                        op_args; 
        logic [64-1:0][32-1:0] rs1_data; 
        logic [64-1:0][32-1:0] rs2_data; 
        logic [64-1:0][32-1:0] rs3_data; 
    } lsu_execute_t; 
    typedef struct packed { 
        lsu_header_t              header; 
        logic [64-1:0][32-1:0] data; 
    } lsu_result_t;
    typedef struct packed { 
        logic [UUID_WIDTH-1:0]           uuid; 
        logic [NW_WIDTH-1:0]             wid; 
        logic [NCTA_WIDTH-1:0]           cta_id; 
        logic [64-1:0]            tmask; 
        logic [(((64 / 64) > 1) ? $clog2(64 / 64) : 1)-1:0] pid; 
        logic                            sop; 
        logic                            eop; 
        logic [PC_BITS-1:0]              PC; 
        logic                            wb; 
        logic [NUM_XREGS-1:0]            wr_xregs; 
        logic [NUM_REGS_BITS-1:0]        rd; 
        logic [BYTESEL_BITS-1:0]         bytesel; 
    } sfu_header_t; 
    typedef struct packed { 
        sfu_header_t              header; 
        logic [INST_OP_BITS-1:0]         op_type; 
        op_args_t                        op_args; 
        logic [64-1:0][32-1:0] rs1_data; 
        logic [64-1:0][32-1:0] rs2_data; 
        logic [64-1:0][32-1:0] rs3_data; 
    } sfu_execute_t; 
    typedef struct packed { 
        sfu_header_t              header; 
        logic [64-1:0][32-1:0] data; 
    } sfu_result_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] reads;
        logic [PERF_CTR_BITS-1:0] writes;
        logic [PERF_CTR_BITS-1:0] read_misses;
        logic [PERF_CTR_BITS-1:0] write_misses;
        logic [PERF_CTR_BITS-1:0] evictions;
        logic [PERF_CTR_BITS-1:0] bank_stalls;
        logic [PERF_CTR_BITS-1:0] mshr_stalls;
        logic [PERF_CTR_BITS-1:0] mem_stalls;
        logic [PERF_CTR_BITS-1:0] crsp_stalls;
    } cache_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] reads;
        logic [PERF_CTR_BITS-1:0] writes;
        logic [PERF_CTR_BITS-1:0] bank_stalls;
        logic [PERF_CTR_BITS-1:0] crsp_stalls;
    } lmem_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] misses;
    } coalescer_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] tlb_reads;
        logic [PERF_CTR_BITS-1:0] tlb_hits;
        logic [PERF_CTR_BITS-1:0] tlb_misses;
        logic [PERF_CTR_BITS-1:0] tlb_evictions;
        logic [PERF_CTR_BITS-1:0] ptw_walks;
        logic [PERF_CTR_BITS-1:0] ptw_latency;
    } mmu_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] reads;
        logic [PERF_CTR_BITS-1:0] writes;
        logic [PERF_CTR_BITS-1:0] latency;
    } mem_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] idles;
        logic [PERF_CTR_BITS-1:0] active_warps;
        logic [PERF_CTR_BITS-1:0] stalled_warps;
        logic [PERF_CTR_BITS-1:0] issued_warps;
        logic [PERF_CTR_BITS-1:0] issued_threads;
        logic [PERF_CTR_BITS-1:0] branches;
        logic [PERF_CTR_BITS-1:0] divergence;
    } sched_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] stalls;
    } fetch_perf_t;
    typedef struct packed {
        logic [PERF_CTR_BITS-1:0] ibf_stalls;
        logic [PERF_CTR_BITS-1:0] scb_stalls;
        logic [PERF_CTR_BITS-1:0] opd_stalls;
        logic [NUM_EX_UNITS-1:0][PERF_CTR_BITS-1:0] dispatch_stalls;
        logic [NUM_EX_UNITS-1:0][PERF_CTR_BITS-1:0] dispatch_instrs;
    } issue_perf_t;
    typedef struct packed {
        cache_perf_t icache;
        cache_perf_t dcache;
        cache_perf_t l2cache;
        cache_perf_t l3cache;
        lmem_perf_t  lmem;
        coalescer_perf_t coalescer;
        mem_perf_t   mem;
    } sysmem_perf_t;
    typedef struct packed {
        sched_perf_t              sched;
        fetch_perf_t              fetch;
        issue_perf_t              issue;
        logic [PERF_CTR_BITS-1:0] ifetches;
        logic [PERF_CTR_BITS-1:0] loads;
        logic [PERF_CTR_BITS-1:0] stores;
        logic [PERF_CTR_BITS-1:0] ifetch_latency;
        logic [PERF_CTR_BITS-1:0] load_latency;
   } pipeline_perf_t;
    localparam LSU_WORD_SIZE        = XLENB;
    localparam LSU_ADDR_WIDTH	    = (32 - $clog2(LSU_WORD_SIZE));
    localparam LSU_MEM_BATCHES      = 1;
    localparam LSU_TAG_ID_BITS      = ($clog2(((((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) < ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64)))))))) ? ((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) : ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64))))))))) + $clog2(LSU_MEM_BATCHES));
    localparam LSU_TAG_WIDTH        = (UUID_WIDTH + LSU_TAG_ID_BITS);
    localparam LSU_NUM_REQS	        = ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) * 64;
    localparam LSU_QUEUE_OUT_SIZE   = (((((((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) < ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64)))))))) ? ((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) : ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64))))))))) > ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)) / LSU_WORD_SIZE)) ? (((((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) < ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64)))))))) ? ((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) : ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64))))))))) : ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)) / LSU_WORD_SIZE));
    localparam LMEM_TAG_WIDTH_BASE  = LSU_TAG_WIDTH + $clog2(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))));
    localparam LMEM_TAG_WIDTH       = LMEM_TAG_WIDTH_BASE;
    localparam LSU_CLIENT_TAG_WIDTH = $bits(lsu_header_t) + INST_LSU_BITS
                                    + (64 * $clog2(LSU_WORD_SIZE))
                                    + (((((((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) < ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64)))))))) ? ((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) : ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64))))))))) > 1) ? $clog2(((((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) < ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64)))))))) ? ((((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) > (256)) ? (256) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))))))) < (32)) ? (32) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((((0) + (((2) * (0))))) + (((2) * (0))))))) + (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64))))))) - (1))) / (((((((1) * (1))) * (((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))) * ((((((64) * (((32) / (8))))) < (64)) ? (((64) * (((32) / (8))))) : (64)))))))))))))) : ((((8) > (((((2) * (4))) * (((64) / (64)))))) ? (8) : (((((2) * (4))) * (((64) / (64))))))))) : 1) + 1;
    typedef struct packed {
        logic                                                       rw;
        logic [64-1:0]                           mask;
        logic [64-1:0][LSU_WORD_SIZE-1:0]        byteen;
        logic [64-1:0][LSU_ADDR_WIDTH-1:0]       addr;
        logic [64-1:0][MEM_ATTR_WIDTH-1:0]       attr;
        logic [64-1:0][(LSU_WORD_SIZE*8)-1:0]    data;
        logic [LSU_CLIENT_TAG_WIDTH-1:0]                            tag;
    } lsu_req_data_t;
    typedef struct packed {
        logic [64-1:0]                           mask;
        logic [64-1:0][(LSU_WORD_SIZE*8)-1:0]    data;
        logic [LSU_CLIENT_TAG_WIDTH-1:0]                            tag;
        logic                                                       sop;
        logic                                                       eop;
    } lsu_rsp_data_t;
    localparam DXA_LMEM_ATTR_W = (BAR_ADDR_W + 1);
    localparam DXA_LMEM_ENGINE_TAG_W = UUID_WIDTH + 1;
    localparam DXA_LMEM_TAG_W = DXA_LMEM_ENGINE_TAG_W + NC_BITS;
    localparam DXA_LMEM_OUT_TAG_W = DXA_LMEM_TAG_W + (((((1) > ((((((1) / (8))) != 0) ? (((1) / (8))) : 1))) ? (1) : ((((((1) / (8))) != 0) ? (((1) / (8))) : 1))) > 1) ? $clog2((((((1) > ((((((1) / (8))) != 0) ? (((1) / (8))) : 1))) ? (1) : ((((((1) / (8))) != 0) ? (((1) / (8))) : 1))) + 1 - 1) / (1))) : 0);
    localparam TCU_LMEM_ATTR_W = 1;
    localparam TCU_LMEM_BLK_TAG_W = UUID_WIDTH + 1;
    localparam TCU_LMEM_NUM_MASTERS = ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) + 1;
    localparam TCU_LMEM_TAG_W = TCU_LMEM_BLK_TAG_W + ((TCU_LMEM_NUM_MASTERS > 1) ? $clog2(((TCU_LMEM_NUM_MASTERS + 1 - 1) / (1))) : 0);
    localparam LMEM_DMA_EN         = (0 + 0) != 0;
    localparam LMEM_DMA_DATA_SIZE  = 64 * LSU_WORD_SIZE;
    localparam LMEM_DMA_ADDR_WIDTH = ($clog2((((16384) > (((64) * (2048)))) ? (16384) : (((64) * (2048)))))) - $clog2(64 * LSU_WORD_SIZE);
    localparam LMEM_DMA_ATTR_W     = (((DXA_LMEM_ATTR_W) > (TCU_LMEM_ATTR_W)) ? (DXA_LMEM_ATTR_W) : (TCU_LMEM_ATTR_W));
    localparam LMEM_DMA_DXA_IDX    = 0;
    localparam LMEM_DMA_TCU_IDX    = LMEM_DMA_DXA_IDX + 0;
    localparam LMEM_DMA_INPUTS     = 0 + 0;
    localparam LMEM_DMA_IN_TAG_MAX = (((DXA_LMEM_OUT_TAG_W) > (TCU_LMEM_TAG_W)) ? (DXA_LMEM_OUT_TAG_W) : (TCU_LMEM_TAG_W));
    localparam LMEM_DMA_TAG_WIDTH  = LMEM_DMA_IN_TAG_MAX + ((LMEM_DMA_INPUTS > 1) ? $clog2(((LMEM_DMA_INPUTS + 1 - 1) / (1))) : 0);
    localparam ICACHE_WORD_SIZE	    = 4;
    localparam ICACHE_ADDR_WIDTH	= (32 - $clog2(ICACHE_WORD_SIZE));
    localparam ICACHE_LINE_SIZE	    = 64;
    localparam ICACHE_NUM_REQS  = ((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))));
    localparam ICACHE_NUM_BANKS = ((2) ** (($clog2(((((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))) & ((-(((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1)))))))))))));
    localparam ICACHE_TAG_ID_BITS	= FETCH_WFS_W;
    localparam ICACHE_FETCH_TAG_WIDTH = (UUID_WIDTH + ICACHE_TAG_ID_BITS);
    localparam ICACHE_TAG_WIDTH_BASE = (ICACHE_FETCH_TAG_WIDTH + 1);
    localparam ICACHE_TAG_WIDTH       = ICACHE_TAG_WIDTH_BASE;
    localparam ICACHE_MEM_DATA_WIDTH = (ICACHE_LINE_SIZE * 8);
    localparam ICACHE_MEM_TAG_WIDTH = 
        (
        (UUID_WIDTH + $clog2(16) + $clog2(((ICACHE_NUM_BANKS + 1 - 1) / (1)))) + ((((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) > 1) ? $clog2(((((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) + 1 - 1) / (1))) : 0));
    localparam DCACHE_WORD_SIZE	    = (((64) < ((((64) < (((((32) / (8))) * (((2) ** (((((($clog2(64))) + (1))) / (2)))))))) ? (64) : (((((32) / (8))) * (((2) ** (((((($clog2(64))) + (1))) / (2)))))))))) ? (64) : ((((64) < (((((32) / (8))) * (((2) ** (((((($clog2(64))) + (1))) / (2)))))))) ? (64) : (((((32) / (8))) * (((2) ** (((((($clog2(64))) + (1))) / (2))))))))));
    localparam DCACHE_ADDR_WIDTH	= (32 - $clog2(DCACHE_WORD_SIZE));
    localparam DCACHE_LINE_SIZE 	= 64;
    localparam DCACHE_SECTOR_SIZE   = 64;
    localparam DCACHE_CHANNELS	    = ((((64 * LSU_WORD_SIZE) / DCACHE_WORD_SIZE) > 0) ? ((64 * LSU_WORD_SIZE) / DCACHE_WORD_SIZE) : 1);
    localparam DCACHE_NUM_REQS	    = ((2) ** (($clog2((((((4) / (16))) != 0) ? (((4) / (16))) : 1))))) * DCACHE_CHANNELS;
    localparam DCACHE_NUM_BANKS     = ((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))));
    localparam L1_MEM_PORTS         = (((((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))) < (2)) ? (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))) : (2));
    localparam DCACHE_MERGED_REQS   = (64 * LSU_WORD_SIZE) / DCACHE_WORD_SIZE;
    localparam DCACHE_MEM_BATCHES   = ((DCACHE_MERGED_REQS + DCACHE_CHANNELS - 1) / (DCACHE_CHANNELS));
    localparam DCACHE_TAG_ID_BITS   = ($clog2(LSU_QUEUE_OUT_SIZE) + $clog2(DCACHE_MEM_BATCHES));
    localparam DCACHE_CORE_TAG_WIDTH = (UUID_WIDTH + DCACHE_TAG_ID_BITS);
    localparam DCACHE_TAG_WIDTH_BASE = (DCACHE_CORE_TAG_WIDTH + 1);
    localparam DCACHE_TAG_WIDTH       = DCACHE_TAG_WIDTH_BASE;
    localparam DCACHE_MEM_DATA_WIDTH = (DCACHE_SECTOR_SIZE * 8);
    localparam DCACHE_MEM_TAG_WIDTH = 
        (
        ((((
        (UUID_WIDTH + $clog2((((((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))))))) > (64)) ? (64) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))))))) < (16)) ? (16) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64)))))))))))) + $clog2(((DCACHE_NUM_BANKS + L1_MEM_PORTS - 1) / (L1_MEM_PORTS))))) > (
        ($clog2(((DCACHE_NUM_REQS + L1_MEM_PORTS - 1) / (L1_MEM_PORTS))) + $clog2(DCACHE_SECTOR_SIZE / DCACHE_WORD_SIZE) + 
        (DCACHE_TAG_WIDTH + ((1 > ((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)) ? $clog2(((1 + ((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) - 1) / (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) : 0))))) ? (
        (UUID_WIDTH + $clog2((((((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))))))) > (64)) ? (64) : (((((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))))))) < (16)) ? (16) : (((2) ** (($clog2(((((((((((460000) / (400))) * (((0) + (((2) * (0))))))) + (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64))))) - (1))) / (((((((((1) * ((((((1) / (1))) != 0) ? (((1) / (1))) : 1)))) * (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) != 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) * (((2) ** (($clog2((((DCACHE_NUM_REQS) < (16)) ? (DCACHE_NUM_REQS) : (16))))))))) * (64)))))))))))) + $clog2(((DCACHE_NUM_BANKS + L1_MEM_PORTS - 1) / (L1_MEM_PORTS))))) : (
        ($clog2(((DCACHE_NUM_REQS + L1_MEM_PORTS - 1) / (L1_MEM_PORTS))) + $clog2(DCACHE_SECTOR_SIZE / DCACHE_WORD_SIZE) + 
        (DCACHE_TAG_WIDTH + ((1 > ((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)) ? $clog2(((1 + ((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) - 1) / (((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1)))) : 0))))) + 1) + ((((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) > 1) ? $clog2(((((((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) > 0) ? ((((((1) / (4))) != 0) ? (((1) / (4))) : 1)) : 1) + 1 - 1) / (1))) : 0));
    localparam DCACHE_IS_LLC        = !0 && !0;
    localparam DCACHE_SHARED_LLC    = DCACHE_IS_LLC && (1 == 1)
                                   && (1 == 1) && ((((((1) / (4))) != 0) ? (((1) / (4))) : 1) == 1)
                                   && !0 && !0
                                   && !0 && !0
                                   && !0;
    localparam L1_MEM_TAG_WIDTH     = (((ICACHE_MEM_TAG_WIDTH) > (DCACHE_MEM_TAG_WIDTH)) ? (ICACHE_MEM_TAG_WIDTH) : (DCACHE_MEM_TAG_WIDTH));
    localparam ICACHE_MEM_ARB_IDX   = 0;
    localparam DCACHE_MEM_ARB_IDX   = ICACHE_MEM_ARB_IDX + 1;
    localparam TCACHE_MEM_ARB_IDX   = DCACHE_MEM_ARB_IDX + 1;
    localparam RTCACHE_MEM_ARB_IDX  = TCACHE_MEM_ARB_IDX + 0;
    localparam DXA_MEM_ARB_IDX      = RTCACHE_MEM_ARB_IDX + 0;
    localparam SOCKET_MEM_ARB_REQS  = 2 + 0 + 0 + 0;
    localparam UMMU_TCACHE_IDX      = 0;
    localparam UMMU_RTCACHE_IDX     = UMMU_TCACHE_IDX + 0;
    localparam UMMU_DXA_IDX         = UMMU_RTCACHE_IDX + 0;
    localparam UMMU_NUM_REQS        = 0 + 0 + 0;
    localparam SOCKET_MEM_TAG_W1    = L1_MEM_TAG_WIDTH;
    localparam SOCKET_MEM_TAG_WIDTH = SOCKET_MEM_TAG_W1;
    localparam SOCKET_MEM_ARB_TAG_WIDTH = (SOCKET_MEM_TAG_WIDTH + $clog2(SOCKET_MEM_ARB_REQS));
    localparam L2_WORD_SIZE	        = 64;
    localparam L2_SECTOR_SIZE       = 64;
    localparam L2_SOCKET_REQS       = NUM_SOCKETS * L1_MEM_PORTS;
    localparam L2_GFX_REQS          = 0 + 0;
    localparam L2_GFX_RASTER_IDX    = L2_SOCKET_REQS;
    localparam L2_GFX_OM_IDX        = L2_GFX_RASTER_IDX + 0;
    localparam CMMU_RCACHE_IDX      = 0;
    localparam CMMU_OCACHE_IDX      = CMMU_RCACHE_IDX + 0;
    localparam CMMU_NUM_REQS        = 0 + 0;
    localparam PTW_ON_L2            = ((0 != 0)
                                    && (1 == 1)
                                    && (0 != 0)
                                    && (0 == 0)) ? 1 : 0;
    localparam L2_PTW_REQS          = PTW_ON_L2;
    localparam L2_PTW_IDX           = L2_SOCKET_REQS + L2_GFX_REQS;
    localparam L2_NUM_REQS          = L2_SOCKET_REQS + L2_GFX_REQS + L2_PTW_REQS;
    localparam CP_ON_L2             = (((((((1) != (0))) && (((((((((0) == (1))) && (((0) == (0))))) && (((1) == (1))))) || (((0) == (1))))))) != 0)
                                    && (1 == 1)
                                    && (0 != 0)
                                    && (0 == 0)) ? 1 : 0;
    localparam CP_ON_L3             = (((((((1) != (0))) && (((((((((0) == (1))) && (((0) == (0))))) && (((1) == (1))))) || (((0) == (1))))))) != 0) && (0 != 0)) ? 1 : 0;
    localparam L2_CP_IDX            = L2_NUM_REQS;
    localparam L2_CACHE_REQS        = L2_NUM_REQS + CP_ON_L2;
    localparam L2_NUM_BANKS         = ((2) ** (($clog2((((L2_NUM_REQS) < (16)) ? (L2_NUM_REQS) : (16))))));
    localparam L2_MEM_PORTS         = (((L2_NUM_REQS) < (2)) ? (L2_NUM_REQS) : (2));
    localparam L2_TAG_WIDTH         = SOCKET_MEM_ARB_TAG_WIDTH;
    localparam L1_TLB_ID_WIDTH       = $clog2(4);
    localparam SOCKET_NUM_MMUS       = 2;
    localparam TLB_SOCKET_ID_WIDTH   = L1_TLB_ID_WIDTH + ((SOCKET_NUM_MMUS > 1) ? $clog2(((SOCKET_NUM_MMUS + 1 - 1) / (1))) : 0);
    localparam CLUSTER_NUM_TLB_PORTS = NUM_SOCKETS;
    localparam TLB_CLUSTER_ID_WIDTH  = TLB_SOCKET_ID_WIDTH + ((CLUSTER_NUM_TLB_PORTS > 1) ? $clog2(((CLUSTER_NUM_TLB_PORTS + 1 - 1) / (1))) : 0);
    localparam L2_TLB_SLOT_WIDTH     = $clog2(8);
    localparam TLB_DEV_ID_WIDTH      = L2_TLB_SLOT_WIDTH + ((1 > 1) ? $clog2(((1 + 1 - 1) / (1))) : 0);
    localparam L2_MEM_DATA_WIDTH	= (L2_SECTOR_SIZE * 8);
    localparam L2_MEM_TAG_WIDTH     = 
        ($clog2(((L2_CACHE_REQS + L2_MEM_PORTS - 1) / (L2_MEM_PORTS))) + $clog2(L2_SECTOR_SIZE / L2_WORD_SIZE) + L2_TAG_WIDTH);
    localparam L2_IS_LLC            = 0 && !0;
    localparam L2_SHARED_LLC        = L2_IS_LLC && (1 == 1);
    localparam DCACHE_ACQ_FORWARD   = 0 && !L2_SHARED_LLC;
    localparam L3_WORD_SIZE	        = L2_SECTOR_SIZE;
    localparam L3_SECTOR_SIZE       = 64;
    localparam L3_PTW_IDX           = 1 * L2_MEM_PORTS;
    localparam L3_NUM_REQS	        = 1 * L2_MEM_PORTS
                                    + ((0 != 0) && (PTW_ON_L2 == 0) ? 1 : 0);
    localparam L3_CP_IDX            = L3_NUM_REQS;
    localparam L3_CACHE_REQS        = L3_NUM_REQS + CP_ON_L3;
    localparam L3_NUM_BANKS         = ((2) ** (($clog2((((L3_NUM_REQS) < (16)) ? (L3_NUM_REQS) : (16))))));
    localparam L3_MEM_PORTS         = (((L3_NUM_REQS) < (2)) ? (L3_NUM_REQS) : (2));
    localparam L3_TAG_WIDTH	        = L2_MEM_TAG_WIDTH;
    localparam L3_MEM_DATA_WIDTH	= (L3_SECTOR_SIZE * 8);
    localparam L3_MEM_TAG_WIDTH     = 
        ($clog2(((L3_CACHE_REQS + L3_MEM_PORTS - 1) / (L3_MEM_PORTS))) + $clog2(L3_SECTOR_SIZE / L3_WORD_SIZE) + L3_TAG_WIDTH);
    localparam L3_IS_LLC            = 0;
    localparam L3_SHARED_LLC        = L3_IS_LLC;
    localparam CP_MEM_DATA_SIZE     = (CP_ON_L2 != 0) ? L2_WORD_SIZE : L3_WORD_SIZE;
    localparam CP_MEM_ADDR_WIDTH    = 32 - $clog2(CP_MEM_DATA_SIZE);
    localparam CP_SLOT_TAG_WIDTH    = (CP_ON_L2 != 0) ? L2_TAG_WIDTH : L3_TAG_WIDTH;
    localparam CP_MEM_TAG_WIDTH     = CP_SLOT_TAG_WIDTH - UUID_WIDTH - 1;
    localparam VX_MEM_PORTS =           L3_MEM_PORTS;
    localparam VX_MEM_BYTEEN_WIDTH =    L3_SECTOR_SIZE;
    localparam VX_MEM_ADDR_WIDTH =      (32 - $clog2(L3_SECTOR_SIZE));
    localparam VX_MEM_DATA_WIDTH =      (L3_SECTOR_SIZE * 8);
    localparam VX_MEM_TAG_WIDTH =       L3_MEM_TAG_WIDTH;
    function automatic logic [SFU_WIDTH-1:0] op_to_sfu_type(
        input logic [INST_OP_BITS-1:0] op_type
    );
        case (op_type)
            INST_SFU_CSRRW,
            INST_SFU_CSRRS,
            INST_SFU_CSRRC: op_to_sfu_type = SFU_CSRS;
            default: op_to_sfu_type = SFU_WCTL;
        endcase
    endfunction
    function automatic logic [NUM_REGS_BITS-1:0] make_reg_num(input logic [REG_TYPE_BITS-1:0] rtype, logic [RV_REGS_BITS-1:0] idx);
        return (NUM_REGS_BITS'(rtype) << RV_REGS_BITS) | NUM_REGS_BITS'(idx);
    endfunction
    function automatic logic [REG_TYPE_BITS-1:0] get_reg_type(input logic [NUM_REGS_BITS-1:0] reg_num);
        return REG_TYPE_BITS'(reg_num >> RV_REGS_BITS);
    endfunction
    function automatic logic [RV_REGS_BITS-1:0] get_reg_idx(input logic [NUM_REGS_BITS-1:0] reg_num);
        return reg_num[RV_REGS_BITS-1:0];
    endfunction
    function automatic logic [UUID_WIDTH-1:0] get_uop_uuid(input logic [UUID_WIDTH-1:0] uuid, input logic [UOP_CTR_W-1:0] uop_idx);
        logic [31:0] uuid_lo = {uop_idx[0 +: UOP_CTR_W], uuid[0 +: (32 - UOP_CTR_W)]};
        return {uuid[UUID_WIDTH-1:32], uuid_lo};
    endfunction
endpackage
package VX_fpu_pkg;
    import VX_gpu_pkg::*;
    typedef struct packed {
        logic is_normal;
        logic is_zero;
        logic is_subnormal;
        logic is_inf;
        logic is_nan;
        logic is_quiet;
        logic is_signaling;
    } fclass_t;
    typedef struct packed {
        logic NV;  
        logic DZ;  
        logic OF;  
        logic UF;  
        logic NX;  
    } fflags_t;
    typedef struct packed { 
        logic [UUID_WIDTH-1:0]           uuid; 
        logic [NW_WIDTH-1:0]             wid; 
        logic [NCTA_WIDTH-1:0]           cta_id; 
        logic [64-1:0]            tmask; 
        logic [(((64 / 64) > 1) ? $clog2(64 / 64) : 1)-1:0] pid; 
        logic                            sop; 
        logic                            eop; 
        logic [PC_BITS-1:0]              PC; 
        logic                            wb; 
        logic [NUM_XREGS-1:0]            wr_xregs; 
        logic [NUM_REGS_BITS-1:0]        rd; 
        logic [BYTESEL_BITS-1:0]         bytesel; 
    } fpu_header_t; 
    typedef struct packed { 
        fpu_header_t              header; 
        logic [INST_OP_BITS-1:0]         op_type; 
        op_args_t                        op_args; 
        logic [64-1:0][32-1:0] rs1_data; 
        logic [64-1:0][32-1:0] rs2_data; 
        logic [64-1:0][32-1:0] rs3_data; 
    } fpu_execute_t; 
    typedef struct packed { 
        fpu_header_t              header; 
        logic [64-1:0][32-1:0] data; 
    } fpu_result_t;
endpackage
module VortexRecipTop(input wire clk,reset,input wire[31:0] a,b,c,output wire[31:0] result,output wire[4:0] fflags);
 VX_rtu_recip #(.DSP_SEED(1)) dut(.clk(clk),.reset(reset),.enable(1'b1),.mask(1'b1),.x(a),.result(result));
 assign fflags=0;
endmodule
module VX_rtu_recip import VX_gpu_pkg::*, VX_fpu_pkg::*; #(
    parameter LATENCY  = 17,  
    parameter DSP_SEED = 0                     
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        mask,
    input  wire [31:0] x,                      
    output wire [31:0] result                  
);
    localparam [31:0] F32_MAX = 32'h7F7FFFFF;
    if (DSP_SEED != 0) begin : g_dsp_seed
        localparam KIDX = 10;
        localparam SEED_N = 1 << KIDX;
        reg [31:0] seed_rom [0:SEED_N-1];
        initial begin
            for (int i = 0; i < SEED_N; i++) begin
                reg [63:0] d, num;
                d   = 64'(2*SEED_N + 2*i + 1);
                num = (64'd1 << 33) * SEED_N;
                seed_rom[i] = 32'((num + d) / (2 * d));
            end
        end
        wire        s0_sign = x[31];
        wire [7:0]  s0_exp  = x[30:23];
        wire [22:0] s0_frac = x[22:0];
        wire [23:0] s0_A    = {1'b1, s0_frac};            
        wire [30:0] s0_afx  = {s0_A, 7'b0};               
        wire        s0_inf  = (s0_exp == 8'h00);          
        wire        s0_zero = (s0_exp == 8'hFF);          
        wire        s0_nan  = s0_zero && (s0_frac != 23'd0);
        wire [KIDX-1:0] s0_idx = s0_frac[22 -: KIDX];
        reg        s1_sign, s1_inf, s1_zero, s1_nan;
        reg [7:0]  s1_exp;
        reg [30:0] s1_afx;
        reg [31:0] s1_y;                                  
        always_ff @(posedge clk) if (enable) begin
            s1_sign <= s0_sign; s1_inf <= s0_inf; s1_zero <= s0_zero; s1_nan <= s0_nan;
            s1_exp  <= s0_exp;  s1_afx <= s0_afx;
            s1_y    <= seed_rom[s0_idx];                  
        end
        wire [62:0] s1_ay = s1_afx * s1_y;                
        wire [31:0] s1_p  = 32'(s1_ay >> 31);             
        wire [31:0] s1_t  = 32'h8000_0000 - s1_p;         
        reg        s2_sign, s2_inf, s2_zero, s2_nan;
        reg [7:0]  s2_exp;
        reg [30:0] s2_afx;
        reg [31:0] s2_y0, s2_t;
        always_ff @(posedge clk) if (enable) begin
            s2_sign <= s1_sign; s2_inf <= s1_inf; s2_zero <= s1_zero; s2_nan <= s1_nan;
            s2_exp  <= s1_exp;  s2_afx <= s1_afx;
            s2_y0   <= s1_y;    s2_t   <= s1_t;
        end
        wire [63:0] s2_yt = s2_y0 * s2_t;                 
        wire [31:0] s2_y1 = 32'(s2_yt >> 30);             
        reg        s3_sign, s3_inf, s3_zero, s3_nan;
        reg [7:0]  s3_exp;
        reg [30:0] s3_afx;
        reg [31:0] s3_y1;
        always_ff @(posedge clk) if (enable) begin
            s3_sign <= s2_sign; s3_inf <= s2_inf; s3_zero <= s2_zero; s3_nan <= s2_nan;
            s3_exp  <= s2_exp;  s3_afx <= s2_afx;  s3_y1 <= s2_y1;
        end
        wire [62:0] s3_ay = s3_afx * s3_y1;               
        wire [31:0] s3_p  = 32'(s3_ay >> 31);
        wire [31:0] s3_t  = 32'h8000_0000 - s3_p;
        reg        s4_sign, s4_inf, s4_zero, s4_nan;
        reg [7:0]  s4_exp;
        reg [31:0] s4_y1, s4_t;
        always_ff @(posedge clk) if (enable) begin
            s4_sign <= s3_sign; s4_inf <= s3_inf; s4_zero <= s3_zero; s4_nan <= s3_nan;
            s4_exp  <= s3_exp;  s4_y1 <= s3_y1;   s4_t <= s3_t;
        end
        wire [63:0] s4_yt = s4_y1 * s4_t;                 
        wire [31:0] s4_y2 = 32'(s4_yt >> 30);             
        reg        s5_sign, s5_inf, s5_zero, s5_nan;
        reg [7:0]  s5_exp;
        reg [31:0] s5_y2;
        always_ff @(posedge clk) if (enable) begin
            s5_sign <= s4_sign; s5_inf <= s4_inf; s5_zero <= s4_zero; s5_nan <= s4_nan;
            s5_exp  <= s4_exp;  s5_y2 <= s4_y2;
        end
        wire [32:0] s5_2y  = {s5_y2, 1'b0};               
        wire [31:0] s5_d   = s5_2y - 33'h8000_0000;       
        wire [23:0] s5_fr  = s5_d[31:8] + {23'b0, s5_d[7]};   
        wire [8:0]  s5_exf = 9'd253 - {1'b0, s5_exp};
        wire        s5_ovf = s5_fr[23];                   
        wire [7:0]  s5_expf = s5_ovf ? (s5_exf[7:0] + 8'd1) : s5_exf[7:0];
        wire [22:0] s5_frac = s5_ovf ? 23'd0 : s5_fr[22:0];
        assign result = s5_inf  ? F32_MAX
                      : s5_nan  ? 32'h7FC00000
                      : s5_zero ? {s5_sign, 8'h00, 23'd0}
                      :           {s5_sign, s5_expf, s5_frac};
    end else begin : g_lut_nr
        wire [31:0] quot;
        VX_fdiv_unit #(
            .USE_DSP        (0),
            .LATENCY        (LATENCY),
            .SUBNORM_ENABLE (0),
            .EXCEPT_ENABLE  (1)
        ) u_recip (
            .clk     (clk),
            .reset   (reset),
            .enable  (enable),
            .mask    (mask),
            .fmt     ('0),
            .frm     (INST_FRM_RNE),
            .dataa   (32'h3F800000  ),
            .datab   (x),
            .result  (quot),
            . fflags ()
        );
        wire x_zero_q;
        VX_shift_register #(
            .DATAW (1),
            .DEPTH (LATENCY)
        ) sr_zero (
            .clk      (clk),
            .reset    (reset),
            .enable   (enable),
            .data_in  (x[30:23] == 8'd0),
            .data_out (x_zero_q)
        );
        assign result = x_zero_q ? F32_MAX : quot;
    end
endmodule

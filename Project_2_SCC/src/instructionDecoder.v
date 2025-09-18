
module InstructionDecoder (
    I, 
    clk,

    // Register file connections
    read_reg_an,
    read_reg_am,
    read_reg_aa,
    read_n_sp,
    exec_n_mux,
    exec_m_mux,
    immediate,

    // Execute stage
    shamt,
    imm_sz,
    imm_n,
    FnH,
    barrel_op,
    barrel_in_mux,
    barrel_u_in_mux,
    bitext_sign_ext,
    alu_op_a_mux,
    alu_op_b_mux,
    wt_mask,
    alu_invert_b,
    alu_cmd,
    out_mux,
    condition,
    pstate_en,
    pstate_mux,
    br_condition_mux,
    nextPC_mux,
    PC_add_op_mux,

    // Memory stage
    mem_size,
    mem_sign_ext,
    mem_read,
    mem_write,
    mem_addr_mux,
    load_FnH,

    // Writeback stage
    wload_addr,
    write_addr,
    wload_en,
    write_en,

    // Error detection
    decode_err
);


	//Inputs
	input  [31:0] I, // Instruction to be decoded

	//Control Signal Outputs (Register File)
	output reg  [4:0] read_reg_an, //Rn (1st operand)
	output reg  [4:0] read_reg_am, // Rm (2nd Operand)
	output reg  [4:0] read_reg_aa, // Rd?
	output reg        read_n_sp, // Rn or Sp is read (stack ops)
	output reg  [1:0] exec_n_mux, // Source for operand N (Rn, SP)
	output reg        exec_m_mux, // Source for operand M (Rm or immediete)
	output reg [63:0] immediate, // Sign extension immediate if neccessary from instruction

	// To Execute stage (ALU)
	output reg  [5:0] shamt,
	output reg  [5:0] imm_sz,
	output reg        imm_n,
	output reg        FnH,
	output reg  [1:0] barrel_op,
	output reg        barrel_in_mux,
	output reg        barrel_u_in_mux,
	output reg        bitext_sign_ext,
	output reg  [1:0] alu_op_a_mux,
	output reg        alu_op_b_mux,
	output reg        wt_mask,
	output reg        alu_invert_b,
	output reg  [2:0] alu_cmd,
	output reg  [1:0] out_mux,
	output reg  [3:0] condition,
	output reg        pstate_en,
	output reg  [1:0] pstate_mux,
	output reg        br_condition_mux,
	output reg        nextPC_mux,
	output reg        PC_add_op_mux,

	// to memory stage (MEM)
	output reg  [1:0] mem_size,
	output reg        mem_sign_ext,
	output reg        mem_read,
	output reg        mem_write,
	output reg        mem_addr_mux,
	output reg        load_FnH,

	// to writeback stage (WB)
	output reg  [4:0] wload_addr,
	output reg  [4:0] write_addr,
	output reg        wload_en,
	output reg        write_en,

	// Error detection
	output reg [3:0] decode_err


endmodule
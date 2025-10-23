//FORMATTED CODE BY CHAT-GPT, CODE IS DONE BY GROUP 7 HOWEVER
//COMMENTS ALSO ADDED BY CHAT-GPT
module u_code_control (
    input  wire        clk, 
    input  wire        rst,
    input  wire [31:0] ifid_instr,

    output reg         hold_if,
    output reg         uc_active,
    output reg  [7:0]  uc_addr
);
    // State
    reg [1:0] ustate, ustateNext; 
    parameter usIdle = 0, usFilter = 1;

    // Needs own PC according to some classmates?
    reg [31:0] uPC; 
    reg [31:0] uPC_next;

    // Tags
    wire mul  = (ifid_instr[31:25] == 7'b0010000);
    wire muls = (ifid_instr[31:25] == 7'b0011000);

    // Destination, Operand Register Extraction
    wire [3:0] id_rd = (ifid_instr[24:21]); //Destination register
    wire [3:0] id_rn = (ifid_instr[20:17]);//Operand register 1
    wire [15:0] id_rm = (ifid_instr[15:0]);//Operand register 2 / Immediete

    // Helpers
    wire       uc_op = mul | muls;
    wire       start_seq = uc_op;       // placeholder start condition
    reg [7:0]  next_uc_addr;

    // Sequential Logic
    always @(posedge clk) begin
        if (rst) begin
            ustate   <= usIdle;
            uc_addr  <= 8'b00000000; // Default address for uc instruction
            uPC      <= 32'b0;
        end 
        else begin 
            ustate <= ustateNext;
            if (ustate == usFilter) begin
                uc_addr <= (start_seq) ? 8'b00000000 : next_uc_addr;
            end
            uPC <= uPC_next;
        end
    end

    // Combinational Logic
    always @(*) begin
        // defaults
        ustateNext   = ustate;
        next_uc_addr = uc_addr;   // hold by default
        uPC_next     = uPC;
        hold_if      = 1'b0;
        uc_active    = 1'b0;

        case (ustate)
            usIdle: begin
                ustateNext = usIdle;
                if (uc_op) begin
                    ustateNext   = usFilter;
                    hold_if      = 1'b1;
                    uc_active    = 1'b1;
                    next_uc_addr = 8'b00000000;
                end
            end

            usFilter: begin
                ustateNext = usFilter;
                case (ifid_instr[31:25]) // decode opcode field
                    7'b0010000: begin
                        next_uc_addr = 8'b00000000;
                    end
                    default: begin

                    end
                endcase
            end

            default: begin
                ustateNext = usIdle;
            end
        endcase
    end
endmodule

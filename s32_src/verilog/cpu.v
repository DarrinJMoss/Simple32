`timescale 1ps/1ps

module CPU #(
    parameter PROM_SIZE = 65535 * 4,
    parameter RAM_SIZE  = 65535,
    parameter WORD_SIZE = 32
)(
    input           clock,
    input           isReset,

    input           rom_WriteEn,
    input [15 : 0]  rom_WriteAdr,   // The address we want to write the below value to
    input [ 7 : 0]  rom_WriteData   // 8 bit write data to be copied into the ROM
);
    // Opcodes
        // NOTE: OP = 6 bit Opcode (Missing upper 2 bits)
        //       LOP (Long Opcode) = 8 bit Opcode (Contains full bits, need to be implmented individually)
        // Logic 1
            localparam OP_NOP   = 8'b00_000_000;
            localparam OP_AND   = 8'bzz_000_001;
            localparam OP_OR    = 8'bzz_000_010;
            localparam OP_XOR   = 8'bzz_000_011;
            localparam OP_NAND  = 8'bzz_000_100;
            localparam OP_NOR   = 8'bzz_000_101;
            localparam OP_XNOR  = 8'bzz_000_110;
            localparam OP_NOT   = 8'bzz_000_111;
        
        // Logic 2
            localparam OP_ASR   = 8'bzz_001_000;
            localparam OP_ASL   = 8'bzz_001_001;
            localparam OP_LSR   = 8'bzz_001_010;
            localparam OP_LSL   = 8'bzz_001_011;
            localparam OP_TCMP  = 8'bzz_001_100;
            localparam OP_CMP   = 8'bzz_001_101;
            localparam OP_TEST  = 8'bzz_001_110;
        
        // Arithmetic
            localparam OP_ADD   = 8'bzz_010_000;
            localparam OP_SUB   = 8'bzz_010_001;
            localparam OP_MUL   = 8'bzz_010_010;
            localparam OP_DIV   = 8'bzz_010_011;
            localparam OP_MOD   = 8'bzz_010_100;
            localparam OP_SQRT  = 8'bzz_010_101;

            localparam LOP_INX  = 8'b00_010_110;
            localparam LOP_INY  = 8'b01_010_110;
            localparam LOP_INA  = 8'b10_010_110;
            localparam LOP_INB  = 8'b11_010_110;

            localparam LOP_DEX  = 8'b00_010_111;
            localparam LOP_DEY  = 8'b01_010_111;
            localparam LOP_DEA  = 8'b10_010_111;
            localparam LOP_DEB  = 8'b11_010_111;
        
        // Memory - Loading/Storing
            localparam OP_LDX   = 8'bzz_011_000;
            localparam OP_LDY   = 8'bzz_011_001;
            localparam OP_LDA   = 8'bzz_011_010;
            localparam OP_LDB   = 8'bzz_011_011;
            localparam OP_STX   = 8'bzz_011_100;
            localparam OP_STY   = 8'bzz_011_101;
            localparam OP_STA   = 8'bzz_011_110;
            localparam OP_STB   = 8'bzz_011_111;
        
        // Memory - Transferring
            localparam LOP_TAB  = 8'b00_100_000;
            localparam LOP_TAX  = 8'b01_100_000;
            localparam LOP_TAY  = 8'b10_100_000;
            localparam LOP_TAST = 8'b11_100_000;

            localparam LOP_TBA  = 8'b00_100_001;
            localparam LOP_TBX  = 8'b01_100_001;
            localparam LOP_TBY  = 8'b10_100_001;
            localparam LOP_TBST = 8'b11_100_001;

            localparam LOP_TXY  = 8'b00_100_010;
            localparam LOP_TXA  = 8'b01_100_010;
            localparam LOP_TXB  = 8'b10_100_010;
            localparam LOP_TXST = 8'b11_100_010;

            localparam LOP_TYX  = 8'b00_100_011;
            localparam LOP_TYA  = 8'b01_100_011;
            localparam LOP_TYB  = 8'b10_100_011;
            localparam LOP_TYST = 8'b11_100_011;

            localparam LOP_TSTX = 8'b00_100_100;
            localparam LOP_TSTY = 8'b01_100_100;
            localparam LOP_TSTA = 8'b10_100_100;
            localparam LOP_TSTB = 8'b11_100_100;
        
        // Memory - Stack
            localparam LOP_PSHA = 8'b00_101_000;
            localparam LOP_PSHB = 8'b01_101_000;
            localparam LOP_PSHX = 8'b10_101_000;
            localparam LOP_PSHY = 8'b11_101_000;

            localparam LOP_POPA = 8'b00_101_001;
            localparam LOP_POPB = 8'b01_101_001;
            localparam LOP_POPX = 8'b10_101_001;
            localparam LOP_POPY = 8'b11_101_001;

            localparam LOP_PUSP = 8'b00_101_010;
            localparam LOP_POSP = 8'b01_101_010;
            localparam LOP_PUST = 8'b10_101_010;
            localparam LOP_POST = 8'b11_101_010;

            localparam OP_PUSH  = 8'bzz_101_011; // Note PUSH_A is formally undefined, but practically works as a worse version of PSHB
            localparam OP_POP   = 8'bzz_101_100; // Note POP_A is formally undefined, but practically works as a worse version of POPB

            localparam LOP_RET  = 8'b11_101_111;
        
        // Control Flow
            localparam OP_JMP   = 8'bzz_110_000;
            localparam OP_JEQ   = 8'bzz_110_001;
            localparam OP_JL    = 8'bzz_110_010;
            localparam OP_JG    = 8'bzz_110_011;
            localparam OP_JLE   = 8'bzz_110_100;
            localparam OP_JGE   = 8'bzz_110_101;
            localparam OP_JNE   = 8'bzz_110_110;
            localparam OP_CALL  = 8'bzz_110_111;
        
        // Misc
            localparam OP_ERR   = 8'bzz_111_000;

            localparam OP_CLST  = 8'b00_111_001;


    // Program Constants
        localparam STATUS_INITIALIZE        = 3'b000;   // Initialize CPU
        localparam STATUS_FETCH_OPERATION   = 3'b001;   // Fetch instruction
        localparam STATUS_FETCH_IMM_ADD     = 3'b010;   // Get an immediate address
        localparam STATUS_FETCH_IMMEDIATE   = 3'b011;
        localparam STATUS_EXECUTE           = 3'b100;
        localparam STATUS_FETCH_IMM_ADD_OFF = 3'b101;   // Fetch memory at an address + an offsete (X reg)

        localparam OPERATION_INFO_ARITH     = 2'b00;
        localparam OPERATION_INFO_IMMED     = 2'b01;
        localparam OPERATION_INFO_I_ADD     = 2'b10;
        localparam OPERATION_INFO_I_OFF     = 2'b11;

        localparam ERR_NO_ERROR             = 0;
        localparam ERR_INVALID_CPU_STATE    = 1;
        localparam ERR_WRITE_TO_ROM         = 2;

        localparam CYCLE_CNT_INIT           = 4'b1111;


    
    // Other Constants
        localparam TRUE                     = 1'b1;
        localparam FALSE                    = 1'b0;






    // CPU Registers
        reg [7 : 0]             IR;         // Instruction Register
        reg [2 : 0]             cpuStatus;
        reg [WORD_SIZE - 1 : 0] PC;         // Program Counter
        reg [WORD_SIZE - 1 : 0] stackPtr;
        reg [WORD_SIZE - 1 : 0] statusFlags;
        reg [WORD_SIZE - 1 : 0] argContext;
        reg [3 : 0]             iCyclesLeft;// Counts how many cycles left in instruction

    // General-Use Registers
        reg [WORD_SIZE - 1 : 0] r_A;
        reg [WORD_SIZE - 1 : 0] r_B;
        // General-Use
        reg [WORD_SIZE - 1 : 0] r_X;
        reg [WORD_SIZE - 1 : 0] r_Y;

    // Status Flags
        reg fl_Carry;
        reg fl_Negative;
        reg fl_Overflow;
        reg fl_Zero;
        reg fl_Complete;
    
    // Debug stuff
        reg [7 : 0] db_Error;               // Contains debug info to be read by C++ testbench

    // Memory
        reg [7 : 0]             ROM [0 : PROM_SIZE - 1];
        reg [WORD_SIZE - 1 : 0] RAM [0 : RAM_SIZE  - 1];






    // ROM Write Logic
    // 
    always @(posedge clock) begin
        if (rom_WriteEn) begin
            ROM[rom_WriteAdr] = rom_WriteData;
        end
    end






    // CPU Logic
    always @(posedge clock) begin

        if (isReset) begin

            PC <= 0;
            cpuStatus <= STATUS_INITIALIZE;

        end else begin

            // Modify the CPU status
            case (cpuStatus)
                STATUS_INITIALIZE: begin
                    // Initialize values
                    IR              <= 0;
                    PC              <= 0;
                    fetchCounter    <= 0;

                    fl_Carry, fl_Complete, fl_Overflow, fl_Zero, fl_Negative <= FALSE;
                    db_Error <= ERR_NO_ERROR;
                    r_A, r_B, r_X, r_Y, stackPtr <= 0;

                    cpuStatus <= STATUS_FETCH_OPERATION;
                end

                STATUS_FETCH_OPERATION: begin // Get an operation to do
                    
                    // Load the value in ROM pointed to by the PC into the IR and increment the PC
                    IR <= ROM[PC];
                    PC <= PC + 1;

                    // If cannon NOP instruction, do nothing
                    if (IR != 0x00) begin

                        // Decide what to do next using the operation info (upper 2 bits)
                        case ({IR[0], IR[1]})
                            OPERATION_INFO_ARITH: begin // Use values in artimetic registers

                                // Move B into the argument context
                                argContext <= r_B;
                                cpuStatus <= STATUS_EXECUTE;
                                iCyclesLeft <= CYCLE_CNT_INIT;

                            end 
                            OPERATION_INFO_IMMED: begin // Use immediate value
                                
                                cpuStatus <= STATUS_FETCH_IMMEDIATE;

                            end
                            OPERATION_INFO_I_ADD: begin // Use immediate address
                                
                                cpuStatus <= STATUS_FETCH

                            end
                            OPERATION_INFO_I_OFF: begin // Use immediate address + offset in the X register
                                cpuStatus <= STATUS_FETCH_IMM_ADD_OFF
                            end
                        endcase
                    end
                end

                STATUS_FETCH_IMMEDIATE: begin // Immediate Value
                    // Load the value in ROM pointed to by the PC into the IR and increment the PC
                    PC <= PC + 1;

                    argContext <= ROM[PC];
                    cpuStatus <= STATUS_EXECUTE;
                    iCyclesLeft <= CYCLE_CNT_INIT;
                end
                STATUS_FETCH_IMM_ADD: begin // Immediate Address
                    // Load the value in ROM pointed to by the PC into the IR and increment the PC
                    PC <= PC + 1;

                    argContext <= ROM[ROM[PC]];
                    cpuStatus <= STATUS_EXECUTE;
                    iCyclesLeft <= CYCLE_CNT_INIT;
                end
                STATUS_FETCH_IMM_ADD_OFF: begin // Immediate Address + Offset (X REG)
                    // Load the value in ROM pointed to by the PC into the IR and increment the PC
                    PC <= PC + 1;

                    argContext <= ROM[ROM[PC] + r_X];
                    cpuStatus <= STATUS_EXECUTE;
                    iCyclesLeft <= CYCLE_CNT_INIT;
                end

                STATUS_EXECUTE: begin
                    
                    casez (IR)
                        // LOGIC 1
                            OP_NOP: begin       // 6'b000_000
                                // No Operation. Do nothing and immediately return
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end  
                            OP_AND: begin       // 6'b000_001
                                r_A <= argContext & r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_OR: begin        // 6'b000_010
                                r_A <= argContext | r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_XOR: begin       // 6'b000_011
                                r_A <= argContext ^ r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_NAND: begin      // 6'b000_100
                                r_A <= ~(argContext & r_A);
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_NOR: begin       // 6'b000_101
                                r_A <= ~(argContext | r_A);
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_XNOR: begin      // 6'b000_110
                                r_A <= ~(argContext ^ r_A);
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_NOT: begin       // 6'b000_111
                                r_A <= ~argContext;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                        // END LOGIC 1

                        // LOGIC 2
                        // END LOGIC 2

                        // ARITHMETIC
                        // END ARITHMETIC

                        // MEMORY LOADING AND STORING
                            OP_LDX: begin
                                r_X <= argContext;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_LDY: begin
                                r_Y <= argContext;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_LDA: begin
                                r_A <= argContext;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_LDB: begin
                                r_B <= argContext;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end

                            OP_STX: begin
                                RAM[argContext] <= r_X;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_STY: begin
                                RAM[argContext] <= r_Y;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_STA: begin
                                RAM[argContext] <= r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_STB: begin
                                RAM[argContext] <= r_B;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                        // END MEMORY LOADING AND STORING

                        // MEMORY TRANSFERS
                            OP_TAB: begin
                                r_B <= r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TAX: begin
                                r_X <= r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TAY: begin
                                r_Y <= r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TAST: begin
                                statusFlags <= r_A;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end

                            OP_TBA: begin
                                r_A <= r_B;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TBX: begin
                                r_X <= r_B;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TBY: begin
                                r_Y <= r_B;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TBST: begin
                                statusFlags <= r_B;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end

                            OP_TXY: begin
                                r_Y <= r_X;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TXA: begin
                                r_A <= r_X;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TXB: begin
                                r_B <= r_X;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TXST: begin
                                statusFlags <= r_X;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end

                            OP_TYX: begin
                                r_X <= r_Y;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TYA: begin
                                r_A <= r_Y;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TYB: begin
                                r_B <= r_Y;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TYST: begin
                                statusFlags <= r_Y;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end

                            OP_TSTX: begin
                                r_X <= statusFlags;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TSTY: begin
                                r_Y <= statusFlags;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TSTA: begin
                                r_A <= statusFlags;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                            OP_TSTB: begin
                                r_B <= statusFlags;
                                cpuStatus <= STATUS_FETCH_OPERATION;
                            end
                        // END MEMORY TRANSFERS

                        // MEMORY STACK
                        // END MEMORY STACK

                        // CONTROL FLOW
                        // END CONTROL FLOW

                        // MISC
                        // END MISC

                        default: begin      // Invalid operation
                            cpuStatus <= STATUS_FETCH_OPERATION;
                        end
                    endcase

                    iCyclesLeft <= iCyclesLeft - 1;

                    // If this, we're finished
                    if (iCyclesLeft == 0) begin
                        cpuStatus <= STATUS_FETCH_OPERATION
                    end

                end

                default: begin // Invalid state, reset the CPU
                    db_Error    = ERR_INVALID_CPU_STATE;
                    cpuStatus   = STATUS_INITIALIZE;
                end
            endcase
        end

    end
    
endmodule
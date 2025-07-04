module mainDecoder (
    input wire [6:0] opcode,    // opcode from instruction
    output reg [1:0] ALUOp,    // ALU operation
    output reg RegWrite,      // RegWrite Enable
    output reg [1:0] ImmSrc, // Immediate Source Select
    output reg ALUSrc,      // ALU Source Select
    output reg MemWrite,   // Memory Write Enable
    output reg ResultSrc, // Result Source Select
    output reg Branch,   // Branch Signal
    output reg load     // load PC
);

    parameter HLT   = 7'b000_0000,      // Halt instruction opcode
              LD    = 7'b000_0011,     // Load instruction opcode
              ST    = 7'b010_0011,    // Store instruction opcode
              RType = 7'b011_0011,   // R-type instruction opcode
              IType = 7'b001_0011,  // I-type instruction opcode
              BType = 7'b110_0011; // B-type instruction opcode

    always @(*) begin
        // Default values
        RegWrite = 0;
        ALUOp = 2'b00;
        ImmSrc = 2'b00;
        ALUSrc = 0;
        MemWrite = 0;
        ResultSrc = 0;
        Branch = 0;
        load = 1;

        if(|opcode)begin
            load = 1; // If opcode is not zero , load is enabled (not HLT instruction)
            case (opcode)
                LD:begin
                    RegWrite = 1; 
                    ImmSrc = 2'b00; 
                    ALUSrc = 1; 
                    MemWrite = 0; 
                    ResultSrc = 1; 
                    Branch = 0; 
                    ALUOp = 2'b00; 
                end 
                ST:begin
                    RegWrite = 0; 
                    ImmSrc = 2'b01; 
                    ALUSrc = 1; 
                    MemWrite = 1;  
                    Branch = 0; 
                    ALUOp = 2'b00; 
                end 
                RType:begin
                    RegWrite = 1; 
                    ALUSrc = 0; 
                    MemWrite = 0; 
                    ResultSrc = 0; 
                    Branch = 0; 
                    ALUOp = 2'b10; 
                end 
                IType:begin
                    RegWrite = 1; 
                    ImmSrc = 2'b00; 
                    ALUSrc = 1; 
                    MemWrite = 0; 
                    ResultSrc = 0; 
                    Branch = 0; 
                    ALUOp = 2'b10; 
                end
                BType:begin
                    RegWrite = 0; 
                    ImmSrc = 2'b10; 
                    ALUSrc = 0; 
                    MemWrite = 0;  
                    Branch = 1; 
                    ALUOp = 2'b01; 
                end 
                default:begin
                    RegWrite = 0;
                    ALUOp = 2'b00;
                    ImmSrc = 2'b00;
                    ALUSrc = 0;
                    MemWrite = 0;
                    ResultSrc = 0;
                    Branch = 0;
                end  
            endcase
        end else begin
            load = 0; // If opcode is zero, load is disabled (HLT instruction)
        end
    end

    
endmodule

module ALUDecoder (
    input wire [1:0] ALUOp,         // ALU operation type
    input wire [2:0] funct3,       // funct3 from instruction
    input wire funct7,            // funct7 from instruction
    input wire OP5,              // 5th bit of opcode
    output reg [2:0] ALUControl // ALU control signals
);
    always @(*) begin
        ALUControl = 3'b000; // Default value
        casex({ALUOp, funct3, OP5, funct7})
            7'b00_xxx_xx:ALUControl = 3'b000; // ADD
            
            7'b01_000_xx:ALUControl = 3'b010; // SUB
            7'b01_001_xx:ALUControl = 3'b010; // SUB
            7'b01_100_xx:ALUControl = 3'b010; // SUB
            
            7'b10_000_00:ALUControl = 3'b000; // ADD
            7'b10_000_10:ALUControl = 3'b000; // ADD
            7'b10_000_01:ALUControl = 3'b000; // ADD
            
            7'b10_000_11:ALUControl = 3'b010; // SUB

            7'b10_001_xx:ALUControl = 3'b001; // SHL
            7'b10_100_xx:ALUControl = 3'b100; // XOR
            7'b10_101_xx:ALUControl = 3'b101; // SHR
            7'b10_110_xx:ALUControl = 3'b110; // OR
            7'b10_111_xx:ALUControl = 3'b111; // AND

            default: ALUControl = 3'b000;     // Default case

        endcase
    end
endmodule

module ALUDecoder2 (    // Another version of ALUDecoder for same logic
    input wire [1:0] ALUOp,         // ALU operation type
    input wire [2:0] funct3,       // funct3 from instruction
    input wire funct7,            // funct7 from instruction
    input wire OP5,              // 5th bit of opcode
    output reg [2:0] ALUControl // ALU control signals
);
    always @(*) begin
        ALUControl = 3'b000; // Default value
        casex(ALUOp)
            2'b00:ALUControl = 3'b000; // ADD
            
            2'b01:begin
                if((funct3[1] == 0) && !(funct3[0]&funct3[2])) ALUControl = 3'b010; //SUB 
            end
            
            2'b10:begin
                if((funct3 == 3'b000) && (OP5 & funct7)) ALUControl = 3'b010; //SUB
                else ALUControl = funct3; // For other operations (funct3)
            end

            default: ALUControl = 3'b000; // Default case

        endcase
    end   
endmodule

module CU (
    input wire [6:0] opcode,                // opcode from instruction
    input wire [2:0] funct3,               // funct3 from instruction
    input wire funct7,                    // funct7 from instruction
    input wire zero,                     // zero flag from ALU
    input wire sign,                    // sign flag from ALU
    output wire PCSrc,                 // PCSrc Select
    output wire ResultSrc,            // ResultSrc Select
    output wire MemWrite,            // Memory Write Enable
    output wire [2:0] ALUControl,   // ALU Control signals
    output wire ALUSrc,            // ALU Srouce Select
    output wire [1:0] ImmSrc,     // Immediate Source Select
    output wire RegWrite,        // Register Write Enable
    output wire load            // load PC
);

    wire Branch;        // Branch is high if the instruction is a branch instruction
    wire [1:0] ALUOp;   // ALUOp selects the ALU operation type
    wire [1:0] sel;     // sel is used to select the output of the mux for PCSrc
    wire out;           // out is the output of the mux for PCSrc

    mainDecoder md (
        .opcode(opcode),
        .ALUOp(ALUOp),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .load(load)
    );

    ALUDecoder aluDec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .OP5(opcode[5]),
        .ALUControl(ALUControl)
    );

    assign sel = {funct3[2], funct3[0]}; // sel is derived from funct3 bits 2 and 0

    mux4to1 mux (
        .A(zero),
        .B(~zero),
        .C(sign),
        .D(32'b0),
        .sel(sel),
        .out(out)
    );

    assign PCSrc = Branch & out; // PCSrc is high if Branch is taken and zero flag is set

endmodule
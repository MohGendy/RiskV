module MC (
    input wire clk,         // Clock signal
    input wire areset       // Asynchronous reset signal
);

    wire [31:0] PC;         // Program Counter
    wire load;              // Load signal for the PC

    wire [31:0] Instr;      // Instruction fetched from memory

    wire PCSrc;             // PC Source Select
    wire ResultSrc;         // Result Source Select
    wire MemWrite;          // Memory Write Enable
    wire [2:0] ALUControl;  // ALU Control signals
    wire ALUSrc;            // ALU Source Select
    wire [1:0] ImmSrc;      // Immediate Source Select
    wire RegWrite;          // Register Write Enable

    wire [31:0] ImmExt;     // Extended Immediate Value

    wire [31:0] RD1;        // Register 1
    wire [31:0] RD2;        // Register 2
    wire [31:0] ALUIn2;     // Second ALU operand, either from register or immediate
    wire [31:0] ALUResult;  // ALU Result
    wire Zero;              // Zero flag
    wire Sign;              // Sign flag

    wire [31:0] ReadData;   // Data read from memory
    wire [31:0] Result;     // Final result to be written back to the register file

    wire [31:0] PCTarget;   // Target PC for branch instruction
    wire [31:0] PCplus4;    // PC plus 4 for instruction fetch
    wire [31:0] PCNext;     // Next PC value to be loaded

    pc pcReg (
        .nextPc(PCNext),
        .clk(clk),
        .areset(areset),
        .load(load),
        .pc(PC)
    );

    InstrMem instrMem (
        .pc(PC),
        .Instr(Instr)
    );

    CU controlUnit (
        .opcode(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7(Instr[30]),
        .zero(Zero),
        .sign(Sign),
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .load(load)
    );

    regFile registerFile (
        .clk(clk),
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WE3(RegWrite),
        .WD3(Result),
        .RD1(RD1),
        .RD2(RD2)
    );

    extend immediateExtender (
        .Instr(Instr),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    mux2to1 aluSrcMux (
        .A(RD2),
        .B(ImmExt),
        .sel(ALUSrc),
        .out(ALUIn2)
    );

    alu ALU (
        .srcA(RD1),
        .srcB(ALUIn2),
        .aluControl(ALUControl),
        .aluResult(ALUResult),
        .zero(Zero),
        .sign(Sign)
    );

    dataMem dataMemory (
        .clk(clk),
        .WE(MemWrite),
        .A(ALUResult),
        .WD(RD2),
        .RD(ReadData)
    );

    mux2to1 resultMux (
        .A(ALUResult),
        .B(ReadData),
        .sel(ResultSrc),
        .out(Result)
    );

    adder pcAdder (
        .A(PC),
        .B(32'b100),
        .SUM(PCplus4)
    );

    adder branchAdder (
        .A(PC),
        .B(ImmExt),
        .SUM(PCTarget)
    );

    mux2to1 pcMux (
        .A(PCplus4),
        .B(PCTarget),
        .sel(PCSrc),
        .out(PCNext)
    );
    
endmodule


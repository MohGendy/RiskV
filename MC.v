module MC (
    input wire clk,
    input wire areset
);

    wire [31:0] PC;
    wire load;

    wire [31:0] Instr;

    wire PCSrc;
    wire ResultSrc;
    wire MemWrite;
    wire [2:0] ALUControl;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire RegWrite;

    wire [31:0] ImmExt;

    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] ALUIn2;
    wire [31:0] ALUResult;
    wire Zero;
    wire Sign;

    wire [31:0] ReadData;
    wire [31:0] Result;

    wire [31:0] PCTarget;
    wire [31:0] PCplus4;
    wire [31:0] PCNext;

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
        .B(ImmExt), // Shift immediate left by 2 for word addressing
        .SUM(PCTarget)
    );

    mux2to1 pcMux (
        .A(PCplus4),
        .B(PCTarget),
        .sel(PCSrc),
        .out(PCNext)
    );
    
endmodule


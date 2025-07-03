module mainDecoder (
    input wire [6:0] opcode,
    output reg [1:0] ALUOp,
    output reg RegWrite,
    output reg [1:0] ImmSrc,
    output reg ALUSrc,
    output reg MemWrite,
    output reg ResultSrc,
    output reg Branch
);
    always @(*) begin
        RegWrite = 0;
        ALUOp = 2'b00;
        ImmSrc = 2'b00;
        ALUSrc = 0;
        MemWrite = 0;
        ResultSrc = 0;
        Branch = 0;
        // Default values
        case (opcode)
            7'b000_0011:begin
                RegWrite = 1; 
                ImmSrc = 2'b00; 
                ALUSrc = 1; 
                MemWrite = 0; 
                ResultSrc = 1; 
                Branch = 0; 
                ALUOp = 2'b00; 
            end 
            7'b010_0011:begin
                RegWrite = 0; 
                ImmSrc = 2'b01; 
                ALUSrc = 1; 
                MemWrite = 1;  
                Branch = 0; 
                ALUOp = 2'b00; 
            end 
            7'b011_0011:begin
                RegWrite = 1; 
                ALUSrc = 0; 
                MemWrite = 0; 
                ResultSrc = 0; 
                Branch = 0; 
                ALUOp = 2'b10; 
            end 
            7'b001_0011:begin
                RegWrite = 1; 
                ImmSrc = 2'b00; 
                ALUSrc = 1; 
                MemWrite = 0; 
                ResultSrc = 0; 
                Branch = 0; 
                ALUOp = 2'b10; 
            end
            7'b110_0011:begin
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
    end

    
endmodule

module ALUDecoder (
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire funct7,
    input wire OP5,
    output reg [2:0] ALUControl
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

            default: ALUControl = 3'b000; // Default case

        endcase
    end
endmodule

module ALUDecoder2 (
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire funct7,
    input wire OP5,
    output reg [2:0] ALUControl
);
    always @(*) begin
        ALUControl = 3'b000; // Default value
        casex(ALUOp)
            2'b00:ALUControl = 3'b000; // ADD
            
            2'b01:begin
                if((funct3[1] == 0) && !(funct3[0]&funct3[2])) ALUControl = 3'b010; //SUB 
            end
            
            2'b10:begin
                if((funct3 == 3'b000) && (OP5&funct7)) ALUControl = 3'b010; //SUB
                else ALUControl = funct3; // For other operations
            end

            default: ALUControl = 3'b000; // Default case

        endcase
    end   
endmodule

module CU (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire funct7,
    input wire zero,
    input wire sign,
    output wire PCSrc,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [2:0] ALUControl,
    output wire ALUSrc,
    output wire [1:0] ImmSrc,
    output wire RegWrite
);

    wire Branch;
    wire [1:0] ALUOp;
    wire [1:0] sel;
    wire out;

    mainDecoder md (
        .opcode(opcode),
        .ALUOp(ALUOp),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch)
    );

    ALUDecoder aluDec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .OP5(opcode[5]),
        .ALUControl(ALUControl)
    );

    assign sel = {funct3[2], funct3[0]};

    mux4to1 mux (
        .A(zero),
        .B(~zero),
        .C(sign),
        .D(0),
        .sel(sel),
        .out(out)
    );

    assign PCSrc = Branch & out; // PCSrc is high if Branch is taken and zero flag is set

endmodule
module alu (
    input wire [31:0] srcA,
    input wire [31:0] srcB,
    input wire [2:0] aluControl,
    output reg [31:0] aluResult,
    output reg zero,
    output reg sign
);

always @(*) begin
    case(aluControl)
        3'b000: aluResult = srcA + srcB; // ADD
        3'b001: aluResult = srcA << srcB; // SHL
        3'b010: aluResult = srcA - srcB; // SUB
        3'b100: aluResult = srcA ^ srcB; // XOR
        3'b101: aluResult = srcA >> srcB; // SHR
        3'b110: aluResult = srcA | srcB; // OR
        3'b111: aluResult = srcA & srcB; // AND
        default: aluResult = 32'b0; // Default case
    endcase

    // Set zero flag
    zero = (aluResult == 32'b0);
    // Set sign flag
    sign = aluResult[31]; // Most significant bit indicates sign
    
end
    
endmodule

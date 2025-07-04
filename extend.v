module extend (
    input wire [31:0] Instr,   // Instruction input
    input wire [1:0] ImmSrc,  // Immediate source select
    output reg [31:0] ImmExt // Extended immediate output
);
    always @(*) begin
        ImmExt = 32'b0;
        case (ImmSrc)
            2'b00: ImmExt = { {20{Instr[31]}}, Instr[31:20] }; // Sign-extend immediate (I-type)
            2'b01: ImmExt = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] }; // Sign-extend immediate (S-type)
            2'b10: ImmExt = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0 }; // Sign-extend immediate (B-type)
            default: ImmExt = 32'b0; // Default case, should not happen
        endcase
    end
    
endmodule

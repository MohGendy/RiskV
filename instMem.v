module InstrMem (
    input wire [31:0] pc,    // Program counter input
    output reg [31:0] Instr // Instruction output
);
    reg [31:0]mem[0:63]; // Memory array
    always @(pc) begin
        Instr = mem[pc[31:2]]; // Assuming pc is word-aligned
    end
endmodule

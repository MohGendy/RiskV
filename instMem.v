module InstrMem (
    input wire [31:0] pc,
    output reg [31:0] Instr
);
    reg [31:0]mem[0:63];
    always @(pc) begin
        Instr = mem[pc[31:2]]; // Assuming pc is word-aligned
    end
endmodule

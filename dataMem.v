module dataMem (
    input wire clk,
    input wire WE,
    input wire [31:0] A,
    input wire [31:0] WD,
    output reg [31:0] RD
);
    reg [31:0]mem[0:63]; // Memory array with 64 words

    always @(*) begin
        RD = mem[A[31:2]]; // Read data from memory
    end

    always @(posedge clk) begin
        mem[A[31:2]] <= WD; // Write data to memory on clock edge
    end

    
endmodule

module dataMem (
    input wire clk,          // Clock signal
    input wire WE,          // Write Enable signal
    input wire [31:0] A,   // Address input
    input wire [31:0] WD, // Data input
    output reg [31:0] RD // Data output
);
    reg [31:0]mem[0:63]; // Memory array with 64 words

    always @(*) begin
        RD = mem[A[31:2]]; // Read data from memory
    end

    always @(posedge clk) begin
        if (WE) mem[A[31:2]] <= WD; // Write data to memory on clock edge
    end

    
endmodule

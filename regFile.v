module regFile (
    input  wire  clk,           // Clock signal
    input wire  [4:0]A1,       // Address for first read
    input wire  [4:0]A2,      // Address for second read
    input wire  [4:0]A3,     // Address for third read
    input wire  WE3,        // Write Enable signal
    input wire  [31:0]WD3, // Data to write 
    output reg [31:0]RD1, // Data output for first read
    output reg [31:0]RD2 // Data output for second read
);

    reg [31:0]file[0:31];
    always @(*) begin
        RD1 = file[A1]; // Read data from the register file for first read
        RD2 = file[A2]; // Read data from the register file for second read
    end
    always @(posedge clk) begin
        if(WE3) begin
            file[A3] <= WD3; // Write data to the register file
        end
    end
    
endmodule

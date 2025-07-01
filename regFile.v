module regFile (
    input  wire  clk,
    input wire  [4:0]A1,
    input wire  [4:0]A2,
    input wire  [4:0]A3,
    input wire  WE3,
    input wire  [31:0]WD3,
    output reg [31:0]RD1,
    output reg [31:0]RD2
);

    reg [31:0]file[0:31];
    always @(*) begin
        RD1 = file[A1];
        RD2 = file[A2];
    end
    always @(posedge clk) begin
        if(WE3) begin
            file[A3] <= WD3; // Write data to the register file
        end
    end
    
endmodule

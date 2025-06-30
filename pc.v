module pc (
    input wire [31:0] nextPc,
    input wire clk,
    input wire areset,
    input wire load,
    output reg [31:0] pc
);

always @(posedge clk or areset) begin
    if(!areset)begin
        pc <= 32'b0; // Reset the PC to 0
    end else if(load) begin
        pc <= nextPc; // Update PC with the next address
    end
end
    
endmodule

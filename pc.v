module pc (
    input wire [31:0] nextPc, // Next program counter value
    input wire clk,          // Clock signal
    input wire areset,      // Asynchronous reset signal
    input wire load,       // Load signal to update the PC
    output reg [31:0] pc  // Current program counter value
);

always @(posedge clk or areset) begin
    if(!areset)begin
        pc <= 32'b0; // Reset the PC to 0
    end else if(load) begin
        pc <= nextPc; // Update PC with the next address
    end
end
    
endmodule

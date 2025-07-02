module mux2to1 (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire sel,
    output wire [31:0] out

);

    assign out = sel ? B : A;
    
endmodule

module mux4to1 (
    input wire A,
    input wire B,
    input wire C,
    input wire D,
    input wire [1:0] sel,
    output wire out
);

    assign out = (sel == 2'b00) ? A :
                 (sel == 2'b01) ? B :
                 (sel == 2'b10) ? C : D;
    
endmodule

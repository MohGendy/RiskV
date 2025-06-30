module mux (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire sel,
    output wire [31:0] out

);

    assign out = sel ? B : A;
    
endmodule

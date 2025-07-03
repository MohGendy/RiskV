module top (
    
);
    reg clk;
    reg rst;
    integer i;

    MC mc (
        .clk(clk),
        .areset(rst)
    );

    initial begin
        $readmemh("program.txt", mc.instrMem.mem);
        for (i = 0;i < 32 ; i = i+1 ) begin
            mc.registerFile.file[i] = 32'b0; // Initialize register file to zero
        end
        for (i = 0;i < 64 ; i = i+1 ) begin
            mc.dataMemory.mem[i] = 32'b0; // Initialize data memory to zero
        end
        rst = 0;
        #10 rst = 1; // start the system after 10 time units
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10 time units
    end

    initial begin
        #1000;
        $stop; // Stop the simulation after 10000 time units
    end
    

endmodule

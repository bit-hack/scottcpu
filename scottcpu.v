`timescale 1ns / 1ps

module scottcpu_alu(
    input CLK,
    input RST,
    input [7:0] A,
    input [7:0] B,
    input [2:0] OP,
    input Cfin,
    output [7:0] OUT,
    output Cfout,
    output Af,
    output Ef,
    output Zf
);

    wire [7:0] op_xor = A ^ B;
    wire [7:0] op_or  = A | B;
    wire [7:0] op_and = A & B;
    wire [7:0] op_not = ~A;
    wire [7:0] op_shr = { Cfin, A[7:1] };
    wire [7:0] op_shl = { A[6:0], Cfin };
    wire [8:0] op_add = A + B + Cfin;

    wire [7:0] result =
        (OP == 0) ? op_add[7:0] :
        (OP == 1) ? op_shl :
        (OP == 2) ? op_shr :
        (OP == 3) ? op_not :
        (OP == 4) ? op_and :
        (OP == 5) ? op_or  :
        (OP == 6) ? op_xor :
        0;

    assign OUT = result;

    assign Cfout =
        (OP == 0) ? op_add[8:8] :
        (OP == 1) ? A[7:7] :
        (OP == 2) ? A[0:0] :
        0;

    assign Zf = (result == 0);
    assign Ef = (op_xor == 0);
    assign Af = 1; // TODO

endmodule

module top();

    reg CLK;

    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] OUT;

    wire Cfout, Zf, Ef, Af;

    wire [2:0] OP = 3'b0;
    wire Cfin = 1'b1;

    scottcpu_alu alu(
        CLK,
        1'd0,
        A,
        B,
        OP,
        Cfin,
        OUT,
        Cfout,
        Af,
        Ef,
        Zf
    );

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, top);

        #0
        CLK = 1;
        A = 8'd34;
        B = 8'd64;

        #1 CLK = 0;
        #10 $finish;
    end

endmodule

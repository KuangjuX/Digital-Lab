`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/15 08:30:53
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ALU(Arithmetic Logic Unit)
module alu(
    input [3:0] A,
    input [3:0] B,
    input [3:0] aluop,
    output logic [7:0] alures,
    output logic ZF,    // zero
    output logic OF     // overflow
    );
    
    logic [3:0] add_res;
    logic add_out;
    rca add (.cin(0), .A(A), .B(B), .res(add_res), .cout(add_out));
    
    logic [3:0] sub_res;
    logic sub_out;
    rca sub (.cin(1), .A(A), .B(~B), .res(sub_res), .cout(sub_out));
    
    always_comb begin
        unique case(aluop)
            4'b0000: alures = A & B;    // AND
            4'b0001: alures = A | B;    // OR
            4'b0010: alures = A ^ B;    // XOR
            4'b0011: begin alures = ~(A & B); alures[7:4] = 4'd0; end // NAND
            4'b0100: begin alures = ~A; alures[7:4] = 4'd0; end       // NOT
            4'b0101: begin alures = A << B[2:0];  alures[7:4] = 4'd0;  end // SLL
            4'b0110: begin alures = A >> B[2:0];  alures[7:4] = 4'd0;  end // SRL
            4'b0111: begin alures = A >>> B[2:0]; alures[7:4] = 4'd0;  end // SRA
            4'b1000: alures = A * B;    // MULU
            // MUL
            4'b1001:
                begin
                    automatic logic sign = A[3]^B[3];
                    automatic logic [2:0] int_a = A[2:0];
                    automatic logic [2:0] int_b = B[2:0];
                    automatic logic [6:0] mul_res = int_a * int_b;
                    alures = {sign, mul_res};
                end
            // ADD
            4'b1010: 
                begin
                    alures[3:0] = add_res;
                    alures[7:4] = 4'd0;
                    OF = ~(A[3]^B[3])&(alures[3]^A[3]);   
                end
            // ADDU
            4'b1011: 
                begin
                    alures[3:0] = add_res;
                    alures[7:4] = 4'd0;
                end
            // SUB
            4'b1100:
                begin
                    alures[3:0] = sub_res;
                    alures[7:4] = 4'd0;
                    OF = (A[3]^B[3])&(A[3]^alures[3]);
                end
           // SUBU
           4'b1101: 
                begin
                    alures[3:0] = sub_res;
                    alures[7:4] = 4'd0;
                end
           4'b1110: alures = signed'(A) < signed'(B) ? 7'b1:'0; // SLT
           4'b1111: alures = A < B ? 7'b1: '0;  // SLTU
           default: alures = '0;    // default
        endcase
    end
    // zero
    assign ZF = !alures;
endmodule: alu

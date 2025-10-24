`timescale 1ns/1ns
`include "alu.v"
module alu_tb;
    reg [7:0] OPERAND1,OPERAND2;
    reg [2:0] ALUOP;
    wire[7:0] OUTPUT;
  alu alu_test(OPERAND1,OPERAND2,ALUOP,OUTPUT);  
    
    
    initial begin
        //assigning initial values
        OPERAND1=8'b0000_0001;
        OPERAND2=8'b0000_0010;
        ALUOP=3'b001;//add
        #10 OPERAND1 = 8'b000_0101;
        #10 OPERAND2 = 8'b000_0100;
        #10 ALUOP = 3'b010; //and
        #10 ALUOP = 3'b011; //or
        #10 ALUOP = 3'b000; //forward
        #10 OPERAND1 = 8'b1010_0000;
        #10 OPERAND2 = 8'b0000_1010;
        #10 OPERAND1 = 8'b1111_0000;
        #10 ALUOP = 3'b010;
    end
    

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0,alu_tb);
        $monitor($time," OPERAND1=%b,OPERAND2=%b,ALUOP=%b,RESULT=%b\n",OPERAND1,OPERAND2,ALUOP,OUTPUT);
    end
endmodule

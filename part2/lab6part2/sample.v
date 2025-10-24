`timescale 1ns/1ps
module stimulus;
    //Variable Declaration, Ports for the ALU Module
    reg [7:0] OPERAND1, OPERAND2;
    reg [2:0] ALUOP;
    wire [7:0] OUTPUT;

    //initializing ALU module
    alu alu_test(OPERAND1, OPERAND2, ALUOP, OUTPUT);

    initial begin
        //initial values for operand 1 and 2
        OPERAND1 = 8'b0000_0001;
        OPERAND2 = 8'b0000_0010;
        ALUOP = 3'b001; //add

        //assigning different values for the operand1 and operand2 and changing ALUOP
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
        $dumpfile("alu_dump.vcd");
        $dumpvars(0, stimulus);
        $monitor($time,  " OPERAND1 = %b, OPERAND2 = %b, ALUOP = %d, RESULT = %b\n", OPERAND1, OPERAND2, ALUOP, OUTPUT);
    end

endmodule

module alu(
    //Port declaration (ANSI C Style)
    input [7:0] DATA1, DATA2, //8-bit wide input ports 
    input [2:0] SELECT, //3-bit selector (implemented as a mux)
    output reg [7:0] RESULT //8-bit Output  
);

    wire [7:0] results [3:0]; //Array of 3 8-bit wires to store the intermediate results 
    forwarder forward(DATA2, results[0]); //instance of the forwarder module
    adder add(DATA1, DATA2, results[1]); //instance of the adder module
    ander and_gates (DATA1, DATA2, results[2]); //instance of ander
    orModule or_gates (DATA1, DATA2, results[3]); //instance of orModule
    

    //MUX implementation for the Selector
    always @(results[0], results[1], results[2], results[3]) begin
    case (SELECT)
        3'b000: RESULT = results[0]; //if SELECT == 0 -> Select the forwarded output
        3'b001: RESULT = results[1]; //if SELECT == 1 -> Select the addition output
        3'b010: RESULT = results[2]; //if SELECT == 2 -> Select the and output   
        3'b011: RESULT = results[3]; //if SELECT == 3 -> Select the or output
        default: RESULT = 8'h00; //Else Output == 0
    endcase
    end

endmodule


//module to add two 8-bit numbers
module adder(
    //Port Declaration
    input [7:0] DATA1, DATA2, //two 8-bit inputs
    output [7:0] addResult //8-bit output of the addition
);
    //continuos assignment with two unit time delays
    assign #2 addResult = DATA1 + DATA2;

endmodule

//module to forward 8-bit input to the output
module forwarder(
    input [7:0] INPUT, //8-bit input 
    output [7:0] forwardResult //8-bit output
);
    //continuos assignment with 1 unit time delays
    assign #1 forwardResult = INPUT;
endmodule

//module to and the two 8-bit inputs to the outoput
module ander(
    input [7:0] DATA1, DATA2,
    output [7:0] andResult
);
    //continious assignment with 1 unit delay
    assign #1 andResult = DATA1 & DATA2;
endmodule

//module to or the two 8-bit inputs to the output
module orModule(
    input [7:0] DATA1, DATA2,
    output [7:0] orResult
);
    //continuos assignment with 1 unit delay
    assign #1 orResult = DATA1 | DATA2;
endmodule
`timescale 1ns/1ps
module reg_file(input [7:0] IN,
                output reg[7:0] OUT1,OUT2,
                input [2:0] INADDR,OUT1ADD,OUT2ADD, //select which register to move by chosing the required add
                input WRITEEN,CLK,RESET,BUSYWAIT);
    reg [7:0] regArr[7:0];
    integer k; //to loop through registers

    always @(*)begin //reading and asynchronously loading values
        OUT1 <= #2 regArr[OUT1ADD];
        OUT2 <= #2 regArr[OUT2ADD];
    end

// Function to check if a value contains 'X' or 'Z'
function is_valid(input [7:0] value);
    integer i;
    begin
        is_valid = 1'b1; // Assume value is valid
        for (i = 0; i < 8; i = i + 1) begin
            if (value[i] === 1'bx ) begin
                is_valid = 1'b0; // Found an invalid bit
            end
        end
    end
endfunction

always @(posedge CLK) begin
    if (~BUSYWAIT) begin
        if (WRITEEN) begin
            if (is_valid(IN)) begin // Check if IN does not contain any 'X' or 'Z' bits
                #1 regArr[INADDR] = IN;
            end
        end
    end
    
    if (RESET) begin
        for (k = 0; k < 8; k = k + 1) begin
            regArr[k] <= #1 8'h00;
        end
    end
end



endmodule
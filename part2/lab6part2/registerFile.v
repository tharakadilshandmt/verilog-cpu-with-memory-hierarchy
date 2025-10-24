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

    always @(posedge CLK && ~BUSYWAIT) begin
        if (WRITEEN) begin
            #1 regArr[INADDR] = IN;
        end
        if(RESET) begin
            for (k =0 ; k<8 ;k =k+1 ) 
            begin
                regArr[k] <= #1 8'h00;
            end
        end
        
    end

endmodule
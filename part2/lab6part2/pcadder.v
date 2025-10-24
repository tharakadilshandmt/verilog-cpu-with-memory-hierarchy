`timescale 1ns/1ps
module pcadder (
    output reg [31:0] PC,
    input CLK,
    input RESET ,
    input signed [7:0] RD_OFFSET,
    input BRANCH,JUMP,ZERO,CLKPAUSE,BUSYWAIT
);
    wire BEQSELECT;
    reg [31:0] PCPLUS4;
    wire[31:0] BEQADDRESS;
    wire signed [31:0] SHIFTLEFTADDRESS;
    wire[31:0] NEXTPC;
    reg signed [31:0]  SIGNEXTNDVALUE;

       always @(RD_OFFSET) begin
        if(RD_OFFSET[7]==1'b0)begin //if the jump value is posititve(forward) value  convert it into plus value
            SIGNEXTNDVALUE<=  {24'b000000000000000000000000,RD_OFFSET};
        end
        else if(RD_OFFSET[7]==1'b1)begin//if the jump is negative(ackward) value convert it into minus value
            SIGNEXTNDVALUE<={24'b111111111111111111111111,RD_OFFSET};
        end

    end
    always @(PC) begin
        #1 PCPLUS4 <=PC+4;////////////////////////////////////further study
    end
     
    assign #2 SHIFTLEFTADDRESS=(PCPLUS4)+(SIGNEXTNDVALUE<<2);

    and(BEQSELECT,BRANCH,ZERO);
    
    assign BEQADDRESS=BEQSELECT?SHIFTLEFTADDRESS:PCPLUS4;
    assign NEXTPC=JUMP?SHIFTLEFTADDRESS:BEQADDRESS;

    
     always @(posedge CLK) begin
        #1
        if(RESET)begin
            PC<=  0;//if reset is high assgn pc to zero
            //tempPC<=#1 0;
        end
        else if(~BUSYWAIT) begin
            // PC<=#1 tempPC;//EVERY TIME THAT RESET IS NOT HIGH INCREMENT PC AT THE POSEAGE OF CLK
           PC<=  NEXTPC;
        end
           
    end


endmodule
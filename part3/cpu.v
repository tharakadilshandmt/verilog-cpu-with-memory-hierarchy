`include "alu.v"
`include "registerFile.v"
`include "pcadder.v"
`include "dcacheFSM_skeleton.v"
`include "dataMemory2.v"
`timescale 1ns/1ps
module cpu (

    input [31:0] INSTRUCTION,//INSTRUCTION ARRAY
    input CLK,RESET,//TO RESET PC AND CLK TO GIVE PC SEQUENTIALLY
    output wire [31:0] PC,//ADDRESS OF INSTRUCTION
    output wire BUSYWAIT//TO WAIT FOR THE BUSY SIGNAL
  
);
  
    wire [7:0] OPCODE/*BITS[31-24]*/,RD/*BITS[23-16]*/,RT/*BITS[15-8]*/,RS_IMM/*BITS[15-8]*/;
    //SPLITTING INSTRUCTON TO DIFFFRENT CHANNELS
    assign OPCODE=INSTRUCTION[31:24];
    assign  RD=INSTRUCTION[23:16];
    assign RT=INSTRUCTION[15:8];
    assign RS_IMM=INSTRUCTION[7:0];//2ND VALUE AND IMMEDIATE VALUE
    

    //DEFINIG OPCODE OUTPUTS AND INPUTS
    wire WRITEENABLE,MUX1SELECT,MUX2SELECT,BRANCHMUXSELECT,NEXTPCMUXSELECT;//1 BIT CONTROLLERS
    wire [2:0] ALUOP;
    wire [31:0] NEXTPC ;//NEXT PC VALUE
    wire [31:0] JUMPADDRESS;
    wire ZERO,CLKPAUSE,ISFORMDM;// ONLY ZERO INPUT
    
    //INITIALIZING PC ADDER IN CONTROL UNIT
    pcadder addpc(PC,CLK,RESET,RD,BRANCHMUXSELECT,NEXTPCMUXSELECT,ZERO,CLKPAUSE,BUSYWAIT);
    
//ASSIGN ANOTHER VALUE(32 bit) AND ASSIGN EXTENDED RD(8bit)

    
    
//CONNECTING CONTROL UNIT 
control_unit cpu_control(OPCODE,BUSYWAIT,ALUOP,MUX1SELECT,MUX2SELECT,WRITEENABLE,BRANCHMUXSELECT,NEXTPCMUXSELECT,READFROMDM,WRITETODM,CLKPAUSE,ISFORMDM);
 

    //DEFINING REGISTERFILE OUTPUTS AND INPUTS
    wire [2:0] READREG1/*RT*/,READREG2/*RS*/,WRITEREG/*RD*/;
    wire [7:0] ALURESULT /*FINAL RESULT THAT COMES TO STORE IN WRITEREG*/,REGOUT1/*VALUE OF ADDRESS READREG1*/,REGOUT2;/*VALUE OF ADDRESS READREG2*/

    //ASSIGNIGNG VALUES FROM THE SPLITTED OUTPUT TO REGISTER INPUTS(BECAUSE INSTRUCTION OUTPUT HAS LARGER ADDRESS BUT REGISTERGILE HAVE ONLY 8 REGISTERS)

    assign READREG1=RT[2:0];
    assign READREG2=RS_IMM[2:0];//2ND VALUE
    assign WRITEREG=RD[2:0];//FOR WRITE 
    
    //CONNECTING REGFILE TO THE ASSIGNED INPUTS AND OUTPUTS
    reg_file reg_8x8(MUX3OUT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET,BUSYWAIT);
   

    //assigning input and output values to 2SCOMP
    wire [7:0] REGOUT2_2SCOMP;
    twoScomp complement(REGOUT2_2SCOMP,REGOUT2);

    //ASSIGNING INPUT AND OUTPUT VALUES TO MUX1 AND MUX2
    wire [7:0] MUX1OUT,MUX2OUT,MUX3OUT,BRANCHMUXOUT;//AND PC
    //CONECTIING  MUX1TO THE CIRCUIT
    assign MUX1OUT=MUX1SELECT?REGOUT2_2SCOMP:REGOUT2;
    //CONNECTING MUX2 TO OUTPUT
    assign MUX2OUT=MUX2SELECT?MUX1OUT:RS_IMM;
    
    assign MUX3OUT=ISFORMDM?DATAFROMDM:ALURESULT;
    wire READFROMDM,WRITETODM,REGIN;
    wire [7:0] DATAFROMDM;
    alu alu_cpu(REGOUT1,MUX2OUT,ALUOP,ALURESULT,ZERO);

    wire mem_busywait,mem_read,mem_write;
    wire [31:0] mem_writedata,mem_readdata;
    wire [5:0]mem_address;
    
    dcache dcache_cpu(BUSYWAIT,READFROMDM,WRITETODM,REGOUT1,DATAFROMDM,ALURESULT,PC,RESET,CLK,
                      mem_busywait,mem_read,mem_write,mem_writedata,mem_readdata,mem_address);

    data_memory dm2(CLK,RESET,mem_read,mem_write,mem_address,mem_writedata,mem_readdata,mem_busywait);


endmodule

//control_unit
module control_unit (
    input [7:0] OPCODE,
    input BUSYWAIT,
    output reg [2:0]ALUOP,
    output reg MUX1SELECT,MUX2SELECT,WRITEENABLE,BRANCHMUXSELECT,NEXTPCMUXSELECT,READFROMDM,WRITETODM,CLKPAUSE,ISFORMDM
);
always @(*) begin
    CLKPAUSE<=BUSYWAIT;
end
always @(OPCODE) begin
    
     case (OPCODE)
        8'b00000010:begin //ADD
            ALUOP<=#1 3'b001; //TO ADD
            MUX1SELECT<=#1 0; //SELECT POSITIVE VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE
            WRITEENABLE<=#1 1; //ENABLE REGISTER WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0; //SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
        end
        8'b00000011:begin //SUBSTRACT 
            ALUOP<=#1 3'b001; //TO ADD
            MUX1SELECT<=#0 1; //SELECT NEGATIVE VALE (TO SUBSTRACT)
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0; //SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
        end
        8'b00000100:begin
            ALUOP<=#1 3'b010; //TO AND
            MUX1SELECT<=#0 0; //SELECT POSITIVE VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0 ;//SELECT PC+4
            NEXTPCMUXSELECT<=#1 0; //SELECT BRANCHMUX OUPUT(PC+4)
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
        end
        8'b00000101:begin
            ALUOP<=#1 3'b011; //TO OR
            MUX1SELECT<=#0 0; //SELECT POSITIVE VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0; //SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY 
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY          
        end
        8'b00000001:begin
            ALUOP<=#1 3'b000; //TO TO FORWARD(MOV)
            MUX1SELECT<=#0 0; //SELECT POSITIVE VALUE
            MUX2SELECT<=#1 1; //SELECT register VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0 ;//SELECT PC+4
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY 
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
        end
        8'b00000000:begin
            ALUOP<=#1 3'b000; //TO loadi
            MUX1SELECT<=#0 0; //SELECT POSITIVE VALUE(can be removed)
            MUX2SELECT<=#1 0; //SELECT immediate VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0 ;//SELELCT PC+4 IN BEQ
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(BRANCH)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY 
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
            
        end
        ///
        8'b00000111:begin
            //TO BRANCH
            ALUOP<=#1 3'b001; //TO SUBSTRACT    
            MUX1SELECT<=#1 1; //SELECT NEGATIVE VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 0; //DISABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 1 ;//SELELCT BRANCH IF ZERO IS HIGH
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(BRANCH)
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY 
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY
    end
        8'b00000110:begin
           //TO JUMP

            WRITEENABLE<=#1 0; //DISABLE REGISTER FILE TO WRITE
            NEXTPCMUXSELECT<=#1 1 ;//SELECT shiftleft address
            READFROMDM<=#1 0; //DISABLE READ TO DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY 
        end

        8'b00001000:begin
        //lwd
            ALUOP<=#1 3'b000; //TO FORWARD(MOV)    
            MUX1SELECT<=#1 0; //SELECT POSITIVE  VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 1; //ENABLE READ FROM DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY         
            ISFORMDM<=#1 1; //ENABLE WRITE DATAMEMORY TO REGISTOR MEMORY    
        end
        8'b00001001:begin
        //lwi
            ALUOP<=#1 3'b000; //TO FORWARD(MOV)    
            MUX1SELECT<=#1 0; //SELECT POSITIVE  VALUE
            MUX2SELECT<=#1 0; //SELECT IMMMEDIATE VALUE 
            WRITEENABLE<=#1 1; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 1; //ENABLE READ FROM DATA MEMORY
            WRITETODM<=#1 0; //DISABLE WRITE TO DATA MEMORY  
            ISFORMDM<=#1 1; //ENABLE WRITE DATAMEMORY TO REGISTOR MEMORY
        end
        8'b00001010:begin
        //swd
            ALUOP<=#1 3'b000; //TO FORWARD(MOV)    
            MUX1SELECT<=#1 0; //SELECT POSITIVE  VALUE
            MUX2SELECT<=#1 1; //SELECT REGISTER VALUE 
            WRITEENABLE<=#1 0; //DISABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //ENABLE READ FROM DATA MEMORY
            WRITETODM<=#1 1; //ENABLE WRITE TO DATA MEMOR
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY

        end
        8'b00001011:begin
        //swi
            ALUOP<=#1 3'b000; //TO FORWARD(MOV)    
            MUX1SELECT<=#1 0; //SELECT POSITIVE  VALUE
            MUX2SELECT<=#1 0; //SELECT IMMMEDIATE VALUE 
            WRITEENABLE<=#1 0; //ENABLE REGISTER FILE TO WRITE
            BRANCHMUXSELECT<=#1 0; //SELECT PC+4
            NEXTPCMUXSELECT<=#1 0 ;//SELECT BRANCHMUX OUPUT(PC+4)
            READFROMDM<=#1 0; //ENABLE READ FROM DATA MEMORY
            WRITETODM<=#1 1; //DISABLE WRITE TO DATA MEMOR
            ISFORMDM<=#1 0; //DISABLE WRITE DATAMEMORY TO REGISTOR MEMORY

        end
     
    endcase       
    
   

end
    
endmodule




//DEFINING THE CIRCUIT OF TWOSCOMPLEMENT PART
module twoScomp (
    output reg signed [7:0]REGOUT2_2SCOMP,
    input [7:0]REGOUT2
);

//GET THE COMPLEMENT OF THE VALUE
always @(REGOUT2) begin
    #1 REGOUT2_2SCOMP=  ~REGOUT2+1;
end
     
endmodule

module  signExtend (
    input [7:0] input8bit,
    output reg [31:0] output32bit

);
    always @(input8bit) begin
        if(input8bit[7]==1'b0)begin //if the jump value is posititve(forward) value  convert it into plus value
            output32bit<=  {24'b0,input8bit};
        end
        else if(input8bit==1'b1)begin//if the jump is negative(ackward) value convert it into minus value
            output32bit= {24'b1,input8bit};
        end

    end
    
endmodule

module  shiftLeft(
    input [31:0] input32bit,
    output reg [31:0] leftshiftoutput
);
    always @(input32bit) begin
        leftshiftoutput <=input32bit<<2;
    end
endmodule

module jumpAlu (
    input [31:0] PCPLUS4,
    input [31:0] SIGN_EXTEND_VALUE,
    output reg [31:0] JUMPADDRESS
);
    always @(SIGN_EXTEND_VALUE) begin
        JUMPADDRESS<= #2 PCPLUS4 + SIGN_EXTEND_VALUE;
    end    
endmodule


//issues
//loadi is not written in alu
//regwrite time not scheduled properly
//default is not settled

//sign extend
//shiftleft
//jumpalu
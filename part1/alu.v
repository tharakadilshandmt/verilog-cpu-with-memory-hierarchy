


module forwardFunct (
    input signed [7:0] DATA2, output  reg signed [7:0] tempResult
);

     always @(DATA2) begin
        #1 tempResult =DATA2; ////////////what is the differece between bloking always and non blockikg assign
        //why is it not works when we components assigned seperately
        //i cannot untersand how to pass output values registers or wires
        
     end
endmodule

module addFunct (
    input signed [7:0] DATA1, DATA2, output reg  signed [7:0] tempResult
);
    always @(DATA1,DATA2) begin
          #2 tempResult  = DATA1 + DATA2;
    end
      
endmodule

module andFunct (
    input signed [7:0] DATA1, DATA2, output  reg signed [7:0] tempResult
);
always @(DATA1,DATA2) begin 
    #1 tempResult  =  DATA1 & DATA2;  
end

  
endmodule

module orFunct (
    input signed [7:0] DATA1, DATA2, output reg signed [7:0] tempResult
);
always @(DATA1,DATA2) begin
    #1 tempResult =  DATA1 | DATA2;
end
 
endmodule
   



module multiplexer (
    input signed [7:0]tempResult1,tempResult2,tempResult3,tempResult4,
    input [2:0]SELECT,
    output reg signed  [7:0] RESULT
);
    always @(tempResult1, tempResult2, tempResult3, tempResult4,SELECT)
 begin
    case (SELECT)
       3'b000 : RESULT=tempResult1;//FORWARD /////////////////////000 CALUE CAN
       3'b001 : RESULT=tempResult2;//ADD
       3'b010 : RESULT=tempResult3;//AND
       3'b011 : RESULT=tempResult4;//OR
      
       

       default: RESULT=8'h00;
    endcase
    

end

endmodule





module alu (
    input signed[7:0] DATA1,DATA2,input [2:0] SELECT,output signed [7:0] RESULT,output reg ZERO
);
wire [7:0] tempResult1,tempResult2,tempResult3,tempResult4; 


forwardFunct forwardVal(DATA2,tempResult1);
addFunct addVal (DATA1,DATA2,tempResult2);
andFunct andVal(DATA1,DATA2,tempResult3);
orFunct orVal(DATA1,DATA2,tempResult4);
multiplexer mux(tempResult1,tempResult2,tempResult3,tempResult4,SELECT,RESULT);

always @(RESULT) begin

         ZERO=(RESULT!=0)?1'b0:1'b1;//reg 4 value eka zeo wenne aida kyla blnna..zero value eka zero wennatte aida kyla blnna
    
 end


 

    
endmodule







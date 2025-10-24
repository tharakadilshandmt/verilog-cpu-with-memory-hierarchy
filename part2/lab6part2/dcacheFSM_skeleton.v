/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/
`timescale 1ns/1ps
module dcache (
    output reg busywait,//busywait signal for CPU
    input read,//read signal from CPU
    input write,//write signal from CPU
    input [7:0]WRITEDATACPU,//data to be written from CPU
    output reg [7:0]READDATACPU,//data to be read from CPU
    input [7:0]ADDRESSCPU,//address from CPU
    
    input [31:0]pc,
    input reset,
    input clk,

    input mem_busywait,//busywait signal for memory
    output reg mem_read,//read signal to memory
    output reg  mem_write,//write signal to memory
    output reg [31:0] mem_writedata,//data to be written to memory
    input [31:0] mem_readdata,//data to be read from memory
    output reg [5:0] mem_address//address to memory
    );
    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */
    wire [2:0]index;
    wire [1:0]block_offset;
    wire [7:5]tag;
    reg [37:0] datarow;

    reg hit, dirty,valid;
    reg [37:0]cache_array[7:0];
    reg [31:0] tempData;
    assign index = ADDRESSCPU[4:2];
    assign block_offset = ADDRESSCPU[1:0];
    assign tag = ADDRESSCPU[7:5];

// Sequential block for datarow selection
always @(posedge ADDRESSCPU,cache_array[index]) begin
    #1 datarow = cache_array[index];
    valid = datarow[37];
    dirty = datarow[36];
end
reg [2:0]istag;
// Combinational block for hit calculation
always @(*) begin
    hit <= #0.9 (datarow[35:32] == tag) && valid;
    istag<= datarow[35:32];
    

end
  
// Sequential block for memory operations
always @(*) begin
    if (read) begin
        tempData <= #1 datarow[31:0];
    end 
end

always @(*) begin //if hit and read
    if(hit && read && !write)begin
        case(block_offset)
            2'b00: READDATACPU <=  tempData[7:0];
            2'b01: READDATACPU <=  tempData[15:8];
            2'b10: READDATACPU <=  tempData[23:16];
            2'b11: READDATACPU <=  tempData[31:24];
    endcase
    end
    
end

//if hit and write

always @(posedge clk) begin
    if(hit && write && !read)begin
        #1
        case(block_offset)
            2'b00: cache_array[index][7:0] <= WRITEDATACPU;
            2'b01: cache_array[index][15:8] <= WRITEDATACPU;
            2'b10: cache_array[index][23:16] <= WRITEDATACPU;
            2'b11: cache_array[index][31:24] <= WRITEDATACPU;
        endcase
        cache_array[index][36]=1'b1;
    end
end

always @(*) begin
    if(read ||write)begin
        busywait <=1'b1;
    end
    else begin
        busywait<=1'b0;
    end   
    end

  always @(posedge hit ,read,write) begin
        if(hit) begin
            if(read && (!write)) begin
               #1 busywait = 0 ; 
            end
            else if (write && (!read)) begin
                #1 busywait = 0;       
            end
            
            
           
                
            
        end
       
    end




    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, WRITE_BACK = 3'b010;
    reg [2:0] state, next_state;
    
    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  //if it is not dirty and not hit(have to read from memory)
                    next_state = MEM_READ;//read from cache
                else if ((read || write) && dirty && !hit)//if it is dirty and not hit(have toi read/write and write back to memory)
                    next_state =  WRITE_BACK;
                else
                    next_state = IDLE;//if it is hit or not read/write, stay in idle
            
            MEM_READ://read from memory
                if (!mem_busywait)//if memory is not busy
                    next_state = IDLE;//go to idle
                else    
                    next_state = MEM_READ;
            WRITE_BACK://write back to memory
                if (!mem_busywait)
                    next_state = MEM_READ;
                else    
                    next_state = WRITE_BACK;
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                busywait = 0;
            end
            //read from memory
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                busywait = 1;
                #1
                //HOW????
                if(mem_busywait==0 )begin
                    cache_array[index][31:0] = mem_readdata;
                    cache_array[index][35:32] = tag;
                    cache_array[index][36] = 1'b0;//dirty bit
                    cache_array[index][37]= 1'b1;//valid bit
                end
                

            end
            //write back to memory
            WRITE_BACK: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {cache_array[index][7:5], index};
                mem_writedata = cache_array[index][31:0];
                busywait = 1;
                
                if(mem_busywait==0)begin
                    cache_array[index][36] = 1'b0;//dirty bit
                    cache_array[index][37]= 1'b1;//valid bit
                end
            end

            
        endcase
    end

    // sequential logic for state transitioning 
    integer j;
    always @( posedge clk,reset)
    begin
        if(reset)begin
            state = IDLE;
            for (j=0;j<8; j=j+1)begin
                cache_array[j] =38'b00xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;
                
            end
        end
        else begin
            state = next_state;
        end
    end

    /* Cache Controller FSM End */

endmodule
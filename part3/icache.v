`timescale 1ps/1ps

module icache(
    //cpu end
    output reg BUSYWAIT,
    input CLK,
    input RESET,
    output [31:0] INSTRUCTION,
    input [7:0] ADDRESS,
    //memory end
    input  MEM_BUSYWAIT,
    input [127:0] MEM_INSTRUCTION,
    output reg mem_read,
    output reg [5:0] MEM_ADDRESS


);
//cache memory
reg [127:0]icache_array[7:0];
reg [2:0]tag_array[7:0];
reg valid_array[7:0];

//variables for indexing
wire [2:0] tag,istag,index;
wire [1:0] offset;
wire [127:0] instruction_block;
wire valid,hit;

//loaded insruction from memory
reg [31:0] loaded_instruction;

//if addres is loaded active the busywait
always @(ADDRESS) BUSYWAIT = 1'b1;

///////////////////////////////////////////////////////////
//if there is hit when next clk signel start busywait is =0
always @( CLK)begin
    if(hit) BUSYWAIT=1'b0;
end
//extracting the tag,index and offset
assign {tag,index,offset} = ADDRESS;


//indexing the memory block
assign #1 instruction_block =icache_array[index];
assign #1 valid =valid_array[index];
assign #1 istag =tag_array[index];

assign #0.9 hit =(valid &&(istag ==tag));
always @(*)begin
    #1
    case (offset)
        2'b00:loaded_instruction=instruction_block[31:0];
        2'b01:loaded_instruction=instruction_block[63:32];
        2'b10:loaded_instruction=instruction_block[95:64];
        2'b11:loaded_instruction=instruction_block[127:96]; 
     
    endcase
end
assign INSTRUCTION=(hit==1)?loaded_instruction:32'bx;
//FSM
   /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;
    
    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit)
                    next_state = MEM_READ;//read from cache
                else
                    next_state = IDLE;//if it is hit or not read/write, stay in idle
            
            MEM_READ://read from memory
                if (!MEM_BUSYWAIT)//if memory is not busy
                    next_state = IDLE;//go to idle
                else    
                    next_state = MEM_READ;
            
        endcase
    end
    // combinational output logic

    always @(*)
    begin
        case(state)
            IDLE:
            begin
               // BUSYWAIT=0;
                mem_read=0;
                MEM_ADDRESS= 5'dx;
                
            end
            //read from memory
            MEM_READ: 
            begin
                BUSYWAIT=1;
                mem_read=1;
                MEM_ADDRESS= {tag, index};
                #1
                if(MEM_BUSYWAIT==0 )begin
                    icache_array[index] = MEM_INSTRUCTION;
                    MEM_ADDRESS= 5'dx;                   
                    tag_array[index] = tag;
                    valid_array[index] = 1;
            
                                     
                end
                

            end
       endcase
    end
    integer i;
    always @(posedge CLK,RESET)begin
        if(RESET)begin
            state=IDLE;
            for(i=0;i<8;i=i+1)begin
                valid_array[i]=0;
            end
        end
        else begin
            state=next_state;
        end
    end
endmodule
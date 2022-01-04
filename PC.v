`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2021 05:50:24 PM
// Design Name: 
// Module Name: PC
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


module PC(clk, pc, new_pc);
    input [31:00]pc;
    input clk;
    output reg [31:00]new_pc;

    always@(posedge clk)
    begin
        new_pc <= pc;
    end

endmodule

module Adder(pc, new_pc);
    input [31:00]pc;
    output reg [31:00]new_pc;
    
    initial begin
    new_pc = 100;
    end
    
    always@(*)
    begin
        new_pc <= pc+4;
        end
endmodule

module Instruction_Memory(pc,do);
    input [31:00]pc;
    output reg [31:00] do;
    reg[31:00] IM [00:511];
    
    initial begin
    IM[100] = 32'b10001100000000100000000000000000;
    IM[104] = 32'b10001100000000110000000000000100;
    IM[108] = 32'b10001100000001000000000000001000;
    IM[112] = 32'b10001100000001010000000000001100;
    IM[116] = 32'b00000000010010100011000000100000;
    end
    
    always@(pc)
    begin
        do <= IM[pc];
        end
endmodule

module IFID(clk, do,instruction);
    input [31:00]do;
    input clk;
    output reg [31:00]instruction;
    
    always@(posedge clk)
    begin
    instruction <= do;
    end
    
endmodule

module Control_Unit(instruction, wreg, m2reg, wmem, aluc, aluimm, regrt); 
    input [31:00]instruction;
    wire [5:0]op;
    assign op = instruction[31:26];
    wire [5:0]func;
    assign func = instruction[5:0];
    output reg wreg;
    output reg m2reg;
    output reg wmem;
    output reg [3:0] aluc;
    output reg aluimm;
    output reg regrt;
    
    always@(instruction) begin
        case(op)
            6'b100011:
            begin
                wreg <= 1'b1;
                m2reg <= 1'b1;
                wmem <= 1'b0;
                regrt <=1'b1; 
                aluc <= 4'b0010;
                aluimm <= 1'b1;
                end 
             6'b000000:
             begin
                wreg <= 1'b1;
                m2reg <= 1'b0;
                wmem <= 1'b0;
                regrt <= 1'b0;
                aluc <= 4'b0010;
                aluimm <= 1'b0;
                end
                endcase
 end
 endmodule
 
module multiplexer(rd,rt, regrt, out); //why dont we need to passs in instruction for this one but we need to for contorl unit. If we do need it, since its a load word there wouldnt be an "rd" value so should i leave it like this or provide input instructino.
    input [4:0]rd; //inputs testbench 26-22
    input [4:0]rt; //inputs
    input regrt; //selector
    output reg [4:0]out; //output data
    
    always@(rd, rt, regrt) begin
        if (regrt == 1'b0)
            out <= rd;   
        else
            out <= rt;   
end
endmodule

module sign_extender(instruction, imm_out);
    input [31:00]instruction;
    wire [15:0]immediate;
    output reg [31:00] imm_out;
    assign immediate = instruction[15:0];
  
    always@(immediate)begin
        imm_out <= {{8{immediate[7]}}, immediate[7:0]}; //verilog slides
        end
endmodule

module RegFile(clk, instruction, qa, qb, wwreg, wn, d); 

input clk;
input wwreg;
input [4:0] wn;
input [31:00] d;

input [31:00] instruction;
reg [4:0] rt;
reg [4:0] rs;

output reg [31:00] qa;
output reg [31:00] qb;

reg [0:31] RF [31:0];
integer i;

initial begin
for (i=0; i < 32; i = i+1) //for loop mentioned in video to set all the rows of the table to 0
        RF[i] <= 32'd0; //iterates through the reg file rows
end

always@(instruction) begin
    rt <= instruction[20:16]; //since it is lw, what should I set the values of qb to.
    rs <= instruction[25:21];
    end

always@(rt, rs) begin
    qa <= RF[rs]; //since it is lw, what should I set the values of qb to.
    qb <= RF[rt];
    end
    
 always@(negedge clk) begin
    if (wwreg == 1) begin
        RF[wn] <= d;
        end 
    end
endmodule


module IDEXE(clk, wreg, m2reg, wmem, aluc, aluimm, rdrt_output, imm, qa, qb, ewreg, em2reg, ewmem, ealuc, ealuimm, erdrt_output, eimm, eqa, eqb);

input wreg;
input m2reg;
input wmem;
input [3:0]aluc;
input aluimm;
input [4:0]rdrt_output;
input [31:00]imm;
input [31:00]qa;
input [31:00]qb;
input clk;

output reg ewreg;
output reg em2reg;
output reg ewmem;
output reg [3:0]ealuc;
output reg ealuimm;
output reg [4:0]erdrt_output;
output reg [31:00]eimm;
output reg [31:00]eqa;
output reg [31:00]eqb;

always@(posedge clk)begin

    ewreg <= wreg;
    em2reg <= m2reg;
    ewmem <= wmem;
    ealuc <= aluc;
    ealuimm <= aluimm;
    erdrt_output <= rdrt_output;
    eimm <= imm;
    eqa <= qa;
    eqb <= qb;
    
end
endmodule

module multiplexer2(eqb,eimm, ealuimm, mux2_out); 
    input [31:0]eqb; 
    input [31:0]eimm; //inputs
    input ealuimm; //selector
    output reg [31:0]mux2_out; //output data
    
    
    always@(eqb, eimm, ealuimm) begin
        if (ealuimm == 1'b0)
            mux2_out <= eqb;   
        else
            mux2_out <= eimm;   
end
endmodule

module alu(mux2, eqa, ealuc, alu_out);
    input [31:00]eqa;
    input [3:0]ealuc;
    input [31:00]mux2;
    output reg [31:00]alu_out; // need bits when I find out how to do mux
    
    
     always@(eqa, mux2, ealuc) begin
        case(ealuc)
            4'b0010:
            begin
               alu_out <= eqa + mux2;
            end 
endcase
end
endmodule
 
 module EXEMEM(clk, ewreg, em2reg, ewmem, erdrt_output,alu_out, eqb, mwreg, mm2reg, mwmem, mrdrt_output, malu_out, mqb );
    input clk;
    input ewreg;
    input em2reg;
    input ewmem;
    input [4:0]erdrt_output;
    input [31:00]alu_out; 
    input [31:00]eqb;
    
    output reg mwreg;
    output reg mm2reg;
    output reg mwmem;
    output reg [4:0]mrdrt_output;
    output reg [31:00]malu_out; 
    output reg [31:00]mqb;
    
    always@(posedge clk)begin
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        mrdrt_output <= erdrt_output;
        malu_out <= alu_out;
        mqb <= eqb;
        end
        
endmodule


module DataMem(malu_out, mqb, mwmem, dm_out);
    input [31:00]malu_out;
    input [31:00]mqb;
    input mwmem;
    output reg [31:00]dm_out;
    
    reg [0:31] DM [31:0];
    
    initial begin
        DM[0] <= 32'hA00000AA;
        DM[1] <= 32'h10000011;
        DM[2] <= 32'h20000022;
        DM[3] <= 32'h30000033;
        DM[4] <= 32'h40000044;
        DM[5] <= 32'h50000055;
        DM[6] <= 32'h60000066;
        DM[7] <= 32'h70000077;
        DM[8] <= 32'h80000088;
        DM[9] <= 32'h90000099;
    end
    
    
    always@(*) begin
        if (mwmem == 0) begin
            dm_out <= DM[{2'b00,malu_out[31:2]}];
      
        end
        else begin
            DM[{2'b00,malu_out[31:2]}] <= mqb;
            end
    end
endmodule

module MEMWB(clk, mwreg, mm2reg, mrdrt_out, alu_out, dm_out, wwreg, wm2reg, wrdrt_out, walu_out, wdm_out);
    input clk;
    input mwreg;
    input mm2reg;
    input [4:0]mrdrt_out;
    input [31:00]alu_out;
    input [31:00]dm_out;
    
    output reg wwreg;
    output reg wm2reg;
    output reg [4:0]wrdrt_out;
    output reg [31:00]walu_out;
    output reg [31:00]wdm_out;
    
    always@(posedge clk) begin
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wrdrt_out <= mrdrt_out;
        walu_out <= alu_out;
        wdm_out <= dm_out;
        end
    
endmodule

module wmultiplexer(wm2reg, walu_out, wdm_out, wmultiplexer_out);
    input wm2reg;
    input [31:00]walu_out;
    input [31:00]wdm_out;
    output reg [31:00]wmultiplexer_out;
    
    always@(*)begin
       if (wm2reg == 1'b0) begin
         wmultiplexer_out <= walu_out;
       end   
       else begin
          wmultiplexer_out <= wdm_out;
       end
    end
    endmodule

    




        



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2021 12:29:41 PM
// Design Name: 
// Module Name: testbench
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


module testbench(); //everything is wire (inputs and outputs)
    reg clk_tb;
    wire [31:00]pc_tb;
    wire [31:00]new_pc_tb;
    wire [31:00]do_tb;
    wire [31:00]instruction_tb;
    wire wreg_tb;
    wire m2reg_tb;
    wire wmem_tb;
    wire [3:0]aluc_tb;
    wire aluimm_tb;
    wire regrt_tb;
    wire [4:0]multiplexerOut_tb;
    wire [31:0]qa_tb;
    wire [31:0]qb_tb;
    wire [31:00]immOut_tb;
    wire ewreg_tb;
    wire em2reg_tb;
    wire ewmem_tb;
    wire [3:0]ealuc_tb;
    wire ealuimm_tb;
    wire [4:0]emultiplexerOut_tb;
    wire [31:00]eimmOut_tb;
    wire [31:0]eqa_tb;
    wire [31:0]eqb_tb;
    wire [31:00]mux2out_tb;
    wire [31:00]aluout_tb;
    wire mwreg_tb;
    wire mm2reg_tb;
    wire mwmem_tb;
    wire [4:0]mmultiplexerOut_tb;
    wire [31:00]malu_tb;
    wire [31:00]mqb_tb;
    wire [31:00]dmout_tb;
    wire wwreg_tb;
    wire wm2reg_tb;
    wire [4:0]wmultiplexerOut_tb;
    wire [31:00]waluout_tb;
    wire [31:00]wdmout_tb;
    wire [31:00]wmultout_tb;
   
  
    initial begin
    clk_tb = 0;
    end
    
    PC program_tb(clk_tb, pc_tb, new_pc_tb);
    
    Adder adder_tb(new_pc_tb, pc_tb);
    
    Instruction_Memory im_tb(new_pc_tb, do_tb);
    
    IFID ifid_tb(clk_tb, do_tb ,instruction_tb);
    
    Control_Unit CU_tb(instruction_tb, wreg_tb, m2reg_tb, wmem_tb, aluc_tb,aluimm_tb,regrt_tb);
    
    multiplexer MUX_tb(instruction_tb[15:11], instruction_tb[20:16], regrt_tb, multiplexerOut_tb); //not sure how to initialize rd since there is no rd for load word.
    
    RegFile RF_tb(clk_tb, instruction_tb, qa_tb, qb_tb, wwreg_tb, wmultiplexerOut_tb, wmultout_tb);
    
    sign_extender Sign_tb(instruction_tb, immOut_tb);
    
    IDEXE idexe_tb(clk_tb, wreg_tb, m2reg_tb, wmem_tb, aluc_tb, aluimm_tb, multiplexerOut_tb, immOut_tb, qa_tb, qb_tb, ewreg_tb, em2reg_tb, ewmem_tb, ealuc_tb, ealuimm_tb, emultiplexerOut_tb, eimmOut_tb, eqa_tb, eqb_tb);

    multiplexer2 mux2_tb(eqb_tb, eimmOut_tb, ealuimm_tb,mux2out_tb);
    
    alu alu_tb(mux2out_tb,eqa_tb, ealuc_tb, aluout_tb);
    
    EXEMEM exemem_tb(clk_tb, ewreg_tb, em2reg_tb, ewmem_tb, emultiplexerOut_tb, aluout_tb, eqb_tb, mwreg_tb, mm2reg_tb, mwmem_tb, mmultiplexerOut_tb, malu_tb, mqb_tb);
    
    DataMem dm_tb(malu_tb, mqb_tb, mwmem_tb, dmout_tb);
    
    MEMWB memwb_tb(clk_tb, mwreg_tb, mm2reg_tb, mmultiplexerOut_tb, malu_tb, dmout_tb, wwreg_tb, wm2reg_tb, wmultiplexerOut_tb, waluout_tb, wdmout_tb);

    wmultiplexer wmultiplexer_tb(wm2reg_tb, waluout_tb, wdmout_tb, wmultout_tb);



always begin
    #5;
    clk_tb = ~clk_tb;
    end

endmodule

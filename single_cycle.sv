//----------------------------------------------------------------------//
//  Design Note
//----------------------------------------------------------------------//
//  1. Instruction Memory Depth (IMEM): At least 8 kB to run the "isa_1b.hex" or "isa_4b.hex"
//  2. Data        Memory Depth (DMEM): At least 2 kB (0x0000_0000 - 0x0000_07FF)
//  3. IMEM and DMEM are separate memory blocks (Harvard-like structure).


module single_cycle (
    input  logic         i_clk     ,
    input  logic         i_reset   ,
    input  logic [31:0]  i_io_sw   ,
    output logic [31:0]  o_io_ledr ,
    output logic [31:0]  o_io_ledg ,
    output logic [31:0]  o_io_lcd  ,
    output logic [ 6:0]  o_io_hex0 ,
    output logic [ 6:0]  o_io_hex1 ,
    output logic [ 6:0]  o_io_hex2 ,
    output logic [ 6:0]  o_io_hex3 ,
    output logic [ 6:0]  o_io_hex4 ,
    output logic [ 6:0]  o_io_hex5 ,
    output logic [ 6:0]  o_io_hex6 ,
    output logic [ 6:0]  o_io_hex7 ,
    output logic [31:0]  o_pc_debug,
    output logic         o_insn_vld
);



// Top level file of your milestone 2
// Write your code here
logic[31:0] wb_data ; 
logic[31:0] pc_four ; 
logic       pc_sel ; 
logic[31:0] pc_next ; 
logic[31:0] pc ; 
logic[31:0] instr ; 
logic[31:0] alu_data ; 
logic       wren_reg ; 
logic[31:0] rs1_data ; 
logic[31:0] rs2_data ; 
logic[31:0] immediate ;
logic[31:0] opa ; 
logic[31:0] opb ;  


mux2to1 pc_select(.a(alu_data) , .b(pc_four) , .sel(pc_sel) , .c(pc_next)) ; 

pc pc1(.i_clk(i_clk) , .i_reset(i_reset) , .i_pc_next(pc_next) , .o_pc(pc)); 

pc_plus_4 pcplus4(.i_pc(pc),
                  .o_pc_four(pc_four)) ; 

instruction_memory instr_mem(.i_clk(i_clk) , .i_reset(i_reset) , .i_pc(pc) , .o_instr(instr)) ; 

regfile_2 regfile(.i_clk(i_clk), 
                  .i_reset(i_reset),
                  .i_rs1_addr(instr[19:15]),
                  .i_rs2_addr(instr[24:20]),
                  .i_rd_data(wb_data),
                  .i_rd_addr(instr[11:7]),
                  .i_rd_wren(wren_reg),
                  .o_rs1_data(rs1_data),
                  .o_rs2_data(rs2_data)) ; 

immgen immgen1(.i_instruction(instr),
                .o_imm(immediate)) ; 

logic br_unsign , br_less , br_equal ; 
brc brc1(.i_rs1_data(rs1_data),
         .i_rs2_data(rs2_data),
         .i_br_un(br_unsign),
         .o_br_less(br_less),
         .o_br_equal(br_equal)) ; 

logic opasel ; 
mux2to1 opa_sel(.a(pc),
                .b(rs1_data),
                .sel(opasel),
                .c(opa)) ; 

logic opbsel ; 
mux2to1 opb_sel(.a(rs2_data),
                .b(immediate),
                .sel(opbsel),
                .c(opb)) ; 

logic[3:0] alu_op ; 
alu alu1(.i_op_a(opa),
         .i_op_b(opb),
         .i_alu_op(alu_op),
         .o_alu_data(alu_data));

logic[31:0] lsu_data ; 
logic mem_wren ; 
lsu lsu1 (
    .i_clk        (i_clk),
    .i_reset      (i_reset),
    .i_funct3     (instr[14:12]),
    .i_lsu_addr   (alu_data),
    .i_st_data    (rs2_data),
    .i_lsu_wren   (mem_wren),
    .o_ld_data    (lsu_data),
    .o_io_ledr    (o_io_ledr),
    .o_io_ledg    (o_io_ledg),
    .o_io_lcd     (o_io_lcd),
    .o_io_hex0    (o_io_hex0),
    .o_io_hex1    (o_io_hex1),
    .o_io_hex2    (o_io_hex2),
    .o_io_hex3    (o_io_hex3),
    .o_io_hex4    (o_io_hex4),
    .o_io_hex5    (o_io_hex5),
    .o_io_hex6    (o_io_hex6),
    .o_io_hex7    (o_io_hex7),
    .i_io_sw      (i_io_sw)
);

logic[1:0] wbsel ; 
logic[31:0] in_wb[3:0] ; 
assign in_wb[0] = pc_four ; 
assign in_wb[1] = alu_data ; 
assign in_wb[2] = lsu_data ; 
assign in_wb[3] = 32'b0 ; 
mux4to1 wb(.in(in_wb),
           .sel(wbsel),
           .out(wb_data)) ;


logic rd_wren ; 
logic insnvalid ; 
control_unit cu1 (
    .opcode    (instr[6:0]),     
    .funct3    (instr[14:12]),     
    .funct7    (instr[31:25]),     
    .br_less   (br_less),    
    .br_equal  (br_equal),   
    .pc_sel    (pc_sel),    
    .rd_wren   (wren_reg),    
    .br_un     (br_unsign),     
    .opa_sel   (opasel),   
    .opb_sel   (opbsel),    
    .alu_op    (alu_op),     
    .mem_wren  (mem_wren),   
    .wb_sel    (wbsel),     
    .insn_vld  (insnvalid)   
);

register_single pc_debug (
    .i_clk(i_clk),     
    .i_data(pc),   
    .i_reset(i_reset),   
    .i_en(1'b1),        
    .odata(o_pc_debug)  
);

register_single_1b insn_vld (
    .i_clk   (i_clk),     
    .i_data  (insnvalid),   
    .i_reset (i_reset),   
    .i_en    (1'b1),        
    .o_data  (o_insn_vld)  
);

endmodule : single_cycle

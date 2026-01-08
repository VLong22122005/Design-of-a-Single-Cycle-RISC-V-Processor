
module register_single_1b(
    input  logic i_clk ,
    input  logic i_data,
    input  logic i_reset , 
    input  logic i_en ,
    output logic o_data 
);

    always_ff @(posedge i_clk) begin
        if(!i_reset) o_data <= 1'b0 ; 
        else if(i_en) o_data <= i_data ;
    end

endmodule

module add (
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] s
);  
    logic[32:0] c ; 
    
    always_comb begin
    c[0] = 1'b0 ; 
    for(integer i=0 ; i<32; i++) begin
        s[i] = a[i]^b[i]^c[i];
        c[i+1] = a[i]&b[i] | a[i]&c[i] | c[i]&b[i] ;
    end 
    end

endmodule

module sub (
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] s
);  
    logic[32:0] c ; 
    logic[31:0] bnot ; 
    assign bnot = ~b ;
    
    always_comb begin
    c[0] = 1'b1 ;  
    for(integer i=0 ; i<32; i++) begin
        s[i] = a[i]^bnot[i]^c[i];
        c[i+1] = a[i]&bnot[i] | a[i]&c[i] | c[i]&bnot[i] ;
    end 
    end
    //assign cout = a[31]&bnot[31] | a[31]&c[31] | c[31]&bnot[31] ;

endmodule

module slt(
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] o
);
    logic[31:0] s ; 
    logic[32:0] c ; 
    logic[31:0] bnot ; 
    logic overflow ; 
    logic neg ; 
    assign bnot = ~b ;
    
    always_comb begin
    c[0] = 1'b1 ;  
    for(integer i=0 ; i<32; i++) begin
        s[i] = a[i]^bnot[i]^c[i];
        c[i+1] = a[i]&bnot[i] | a[i]&c[i] | c[i]&bnot[i] ;
    end 
    end
    assign overflow = c[32]^c[31];
    assign neg = (overflow&(~s[31])) | ((~overflow)&(s[31])) ; 
    assign o = {31'b0 , neg} ; 

endmodule

module sltu(
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] o
);  
    logic [32:0] s ; 
    logic [32:0] a_33bit ; 
    assign a_33bit = {1'b0, a[31:0]} ; 
    logic [32:0] b_33bit ; 
    assign b_33bit = {1'b0, b[31:0]} ;
    logic[32:0] bnot ; 
    assign bnot = ~b_33bit ;
    logic[33:0] c ;
 
    always_comb begin 
        c[0] = 1 ;
        for(integer i=0 ; i<33; i++) begin
        s[i] = a_33bit[i]^bnot[i]^c[i];
        c[i+1] = a_33bit[i]&bnot[i] | a_33bit[i]&c[i] | c[i]&bnot[i] ;
        end 
    end
    assign o = {31'b0, s[32]} ;
 
endmodule

module sll(
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] c
);
    logic[31:0] temp ; 

    always_comb begin
        temp = a ; 
        if (b[0]) temp = {temp[30:0],  1'b0};
        if (b[1]) temp = {temp[29:0],  2'b0};
        if (b[2]) temp = {temp[27:0],  4'b0};
        if (b[3]) temp = {temp[23:0],  8'b0};
        if (b[4]) temp = {temp[15:0], 16'b0};
    end

    assign c = temp ; 

endmodule


module srl(
    input  logic[31:0] a,
    input  logic[31:0] b,
    output logic[31:0] c
); 
    logic[31:0] temp ; 

    always_comb begin
        temp = a ; 
        if (b[0]) temp = {1'b0 , temp[31:1] };
        if (b[1]) temp = {2'b0 , temp[31:2] };
        if (b[2]) temp = {4'b0 , temp[31:4] };
        if (b[3]) temp = {8'b0 , temp[31:8] };
        if (b[4]) temp = {16'b0, temp[31:16]};
    end

    assign c = temp ;
endmodule

module sra(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] c
); 
 logic[31:0] temp ; 

    always_comb begin
        temp = a ; 
        if (b[0]) temp = {{1{temp[31]}} , temp[31:1] };
        if (b[1]) temp = {{2{temp[31]}} , temp[31:2] };
        if (b[2]) temp = {{4{temp[31]}} , temp[31:4] };
        if (b[3]) temp = {{8{temp[31]}} , temp[31:8] };
        if (b[4]) temp = {{16{temp[31]}}, temp[31:16]};
    end

    assign c = temp ;
endmodule

module alu(
    input  logic[31:0] i_op_a,
    input  logic[31:0] i_op_b,
    input  logic[3:0]  i_alu_op,
    output logic[31:0] o_alu_data
);
    logic[31:0] add_out, sub_out, sll_out, slt_out, sltu_out, srl_out, sra_out; 
    add  add_alu(.a(i_op_a), .b(i_op_b), .s(add_out)) ;
    sub  sub_alu(.a(i_op_a), .b(i_op_b), .s(sub_out)) ;
    sll  sll_alu(.a(i_op_a), .b(i_op_b), .c(sll_out)) ;
    slt  slt_alu(.a(i_op_a), .b(i_op_b), .o(slt_out)) ;
    sltu sltu_alu(.a(i_op_a), .b(i_op_b), .o(sltu_out));
    srl  srl_alu(.a(i_op_a), .b(i_op_b), .c(srl_out)) ;
    sra  sra_alu(.a(i_op_a), .b(i_op_b), .c(sra_out)) ;
    always_comb begin
        case(i_alu_op)
            4'b0000: o_alu_data = add_out ; 
            4'b1000: o_alu_data = sub_out ; 
            4'b0001: o_alu_data = sll_out ; 
            4'b0010: o_alu_data = slt_out ;
            4'b0011: o_alu_data = sltu_out ; 
            4'b0100: o_alu_data = i_op_a ^ i_op_b ; 
            4'b0101: o_alu_data = srl_out ;
            4'b1101: o_alu_data = sra_out ;
            4'b0110: o_alu_data = i_op_a | i_op_b ; 
            4'b0111: o_alu_data = i_op_a & i_op_b ;
            4'b1111: o_alu_data = i_op_b ;    //immediate
            default: o_alu_data = 0 ; 
        endcase
    end

endmodule

module decoder1to2(
    input logic en,
    input logic in,
    output logic[1:0] out
);
    assign out[0] = en & ~in ; 
    assign out[1] = en &  in ; 

 endmodule

module decoder2to4(
    input logic en,
    input logic[1:0] in,
    output logic[3:0] out
);
    logic[1:0] en_wire ;
    decoder1to2 decoder1(.en(en) , .in(in[1]) , .out(en_wire))  ;
    decoder1to2 decoder2(.en(en_wire[0]) , .in(in[0]) , .out(out[1:0]))  ;
    decoder1to2 decoder3(.en(en_wire[1]) , .in(in[0]) , .out(out[3:2]))  ;

endmodule

module decoder3to8(
    input logic en,
    input logic[2:0] in,
    output logic[7:0] out
);
    logic[1:0] en_wire ;
    decoder1to2 decoder1(.en(en) , .in(in[2]) , .out(en_wire))  ;
    decoder2to4 decoder2(.en(en_wire[0]) , .in(in[1:0]) , .out(out[3:0]))  ;
    decoder2to4 decoder3(.en(en_wire[1]) , .in(in[1:0]) , .out(out[7:4]))  ;

endmodule

module decoder4to16(
    input logic en,
    input logic[3:0] in,
    output logic[15:0] out
);
    logic[1:0] en_wire ;
    decoder1to2 decoder1(.en(en) , .in(in[3]) , .out(en_wire))  ;
    decoder3to8 decoder2(.en(en_wire[0]) , .in(in[2:0]) , .out(out[7:0]))  ;
    decoder3to8 decoder3(.en(en_wire[1]) , .in(in[2:0]) , .out(out[15:8]))  ;

endmodule

module decoder5to32(
    input logic en,
    input logic[4:0] in,
    output logic[31:0] out
);
    logic[1:0] en_wire ;
    decoder1to2  decoder1(.en(en) , .in(in[4]) , .out(en_wire))  ;
    decoder4to16 decoder2(.en(en_wire[0]) , .in(in[3:0]) , .out(out[15:0]))  ;
    decoder4to16 decoder3(.en(en_wire[1]) , .in(in[3:0]) , .out(out[31:16]))  ;

endmodule

module mux2to1(
    input  logic[31:0] a ,  
    input  logic[31:0] b ,
    input  logic sel , 
    output logic[31:0] c
) ; 
    logic[31:0] s ; 
    assign s = {32{sel}} ; 
    assign c = (~s & a) | (s & b); 
endmodule

module mux4to1(
    input  logic[31:0] in[3:0] , 
    input  logic[1:0] sel ,
    output logic[31:0] out
);
    logic[31:0] stage[1:0] ; 
    mux2to1 mux1(.a(in[0]) , .b(in[1]) , .sel(sel[0]) , .c(stage[0])) ; 
    mux2to1 mux2(.a(in[2]) , .b(in[3]) , .sel(sel[0]) , .c(stage[1])) ; 
    mux2to1 mux3(.a(stage[0]) , .b(stage[1]) , .sel(sel[1]) , .c(out)) ;

endmodule

module mux8to1(
    input  logic[31:0] in[7:0],
    input  logic[2:0] sel,
    output logic[31:0] out
);
    logic[31:0] stage[1:0] ;
    mux4to1 mux1(.in(in[3:0]) , .sel(sel[1:0]) , .out(stage[0])) ; 
    mux4to1 mux2(.in(in[7:4]) , .sel(sel[1:0]) , .out(stage[1])) ;
    mux2to1 mux3(.a(stage[0]) , .b(stage[1]) , .sel(sel[2]) , .c(out)) ;

endmodule

module mux16to1(
    input  logic[31:0] in[15:0],
    input  logic[3:0] sel,
    output logic[31:0] out
);
    logic[31:0] stage[1:0] ;
    mux8to1 mux1(.in(in[7:0]) , .sel(sel[2:0]) , .out(stage[0])) ; 
    mux8to1 mux2(.in(in[15:8]) , .sel(sel[2:0]) , .out(stage[1])) ;
    mux2to1 mux3(.a(stage[0]) , .b(stage[1]) , .sel(sel[3]) , .c(out)) ;

endmodule

module mux32to1(
    input  logic[31:0] in[31:0],
    input  logic[4:0] sel,
    output logic[31:0] out
);
    logic[31:0] stage[1:0] ;
    mux16to1 mux1(.in(in[15:0]) , .sel(sel[3:0]) , .out(stage[0])) ; 
    mux16to1 mux2(.in(in[31:16]) , .sel(sel[3:0]) , .out(stage[1])) ;
    mux2to1  mux3(.a(stage[0]) , .b(stage[1]) , .sel(sel[4]) , .c(out)) ;

endmodule

module regfile_2(
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [4:0]  i_rs1_addr,
    input  logic [4:0]  i_rs2_addr,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,
    input  logic [4:0]  i_rd_addr,
    input  logic [31:0] i_rd_data,
    input  logic        i_rd_wren
);
    logic [31:0] register [31:0] ;
    logic [31:0] wren ; 
    logic [31:0] reset ; 
    assign reset = {32{i_reset}} ;

    decoder5to32 addr(.en(i_rd_wren) , .in(i_rd_addr) , .out(wren)) ; 

    genvar i ; 
    generate
        for(i = 1 ; i<32 ; i++) begin : reg_block
            register_single Reg(.i_clk(i_clk) ,
                                .i_data(i_rd_data) ,
                                .i_reset(reset[i]) ,
                                .i_en(wren[i]) ,
                                .odata(register[i])) ; 
        end
    endgenerate

    register_single reg0(.i_clk(i_clk) ,
                                .i_data(32'b0) ,
                                .i_reset(reset[0]) ,
                                .i_en(wren[0]) ,
                                .odata(register[0])) ; 

    mux32to1 mux1(.in(register) , .sel(i_rs1_addr) , .out(o_rs1_data)) ; 
    mux32to1 mux2(.in(register) , .sel(i_rs2_addr) , .out(o_rs2_data)) ; 


endmodule 


module lsu (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic[2:0]   i_funct3,

    input  logic [31:0] i_lsu_addr,   
    input  logic [31:0] i_st_data,    
    input  logic        i_lsu_wren,   

    output logic [31:0] o_ld_data,    

    // I/O mapped peripherals
    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [31:0] o_io_lcd,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,

    input  logic [31:0] i_io_sw        
);
    logic[31:0] data_mem , io_ledg , io_ledr , io_lcd , io_sevenseg1 ,io_sevenseg2 , io_sw ;
    assign o_io_ledg = io_ledg ; 
    assign o_io_ledr = io_ledr ; 
    assign o_io_lcd  = io_lcd ; 
    assign {o_io_hex3 , o_io_hex2 , o_io_hex1 , o_io_hex0} = io_sevenseg1[27:0] ; 
    assign {o_io_hex7 , o_io_hex6 , o_io_hex5 , o_io_hex4} = io_sevenseg2[27:0] ;

    logic[31:0] dmem_or_not ;
    slt slt_dmem_or_not(.a(i_lsu_addr), .b(32'h800), .o(dmem_or_not)) ;
    logic is_mem ,  is_ledr , is_ledg , is_lcd , is_sevenseg1 , is_sevenseg2, is_sw ; 
    assign is_mem = dmem_or_not[0] ; 
    assign is_ledr = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1000_0000)) ; 
    assign is_ledg = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1000_1000)) ;
    assign is_lcd = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1000_4000)) ;
    assign is_sevenseg1 = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1000_2000)) ;
    assign is_sevenseg2 = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1000_3000)) ;
    assign is_sw = ~(|((i_lsu_addr & 32'hFFFF_F000) ^ 32'h1001_0000)) ;
 
    always_comb begin
        if(is_mem) 
            o_ld_data = data_mem ;
        else if(is_ledg) o_ld_data = io_ledg ; 
        else if(is_ledr) o_ld_data = io_ledr ; 
        else if(is_lcd)  o_ld_data = io_lcd ;
        else if(is_sevenseg1) o_ld_data = io_sevenseg1 ;
        else if(is_sevenseg2) o_ld_data = io_sevenseg2 ;
        else if(is_sw) o_ld_data = io_sw ;
        else o_ld_data = 32'b0 ; 
    end

    memory dmem(.i_clk(i_clk) , .i_reset(i_reset) , .i_addr(i_lsu_addr) , .i_st_data(i_st_data) , .i_wren(i_lsu_wren&is_mem) , .i_funct3(i_funct3) , .odata(data_mem)) ; 

    register_single ledg(.i_clk(i_clk) , .i_data(i_st_data) , .i_reset(i_reset) , .i_en(i_lsu_wren&is_ledg) , .odata(io_ledg)) ; 
    register_single ledr(.i_clk(i_clk) , .i_data(i_st_data) , .i_reset(i_reset) , .i_en(i_lsu_wren&is_ledr), .odata(io_ledr)) ; 
    register_single lcd(.i_clk(i_clk) , .i_data(i_st_data) , .i_reset(i_reset) , .i_en(i_lsu_wren&is_lcd) , .odata(io_lcd)) ; 
    register_single sevenseg1(.i_clk(i_clk) , .i_data(i_st_data) , .i_reset(i_reset) , .i_en(i_lsu_wren&is_sevenseg1) , .odata(io_sevenseg1)) ; 
    register_single sevenseg2(.i_clk(i_clk) , .i_data(i_st_data) , .i_reset(i_reset) , .i_en(i_lsu_wren&is_sevenseg2) , .odata(io_sevenseg2)) ;  
    register_single sw(.i_clk(i_clk) , .i_data(i_io_sw) , .i_reset(i_reset) , .i_en(is_sw) , .odata(io_sw)) ;

    
    
endmodule

module register_single(
    input logic i_clk ,
    input logic[31:0] i_data,
    input logic i_reset , 
    input logic i_en ,
    output logic[31:0] odata 
);

    always_ff @(posedge i_clk) begin
        if(!i_reset) odata <= 32'b0 ; 
        else if(i_en) odata <= i_data ;
    end

endmodule

module memory (
    input  logic        i_clk,
    input  logic        i_reset,       
    input  logic [31:0] i_addr,        
    input  logic [31:0] i_st_data,       
    input  logic        i_wren,  
    input  logic [2:0]  i_funct3,      
    output logic [31:0] odata
);  
    logic[3:0] bmask1 , bmask2; 
    logic b , h , w , bu , hu ; 
    logic[1:0] b_addr ;  // byte address
    assign b_addr = i_addr[1:0] ; 
    assign b  = ~i_funct3[0] & ~i_funct3[1] & ~i_funct3[2] ; 
    assign h  =  i_funct3[0] & ~i_funct3[1] & ~i_funct3[2] ;
    assign w  = ~i_funct3[0] &  i_funct3[1] & ~i_funct3[2] ;
    assign bu = ~i_funct3[0] & ~i_funct3[1] &  i_funct3[2] ;
    assign hu =  i_funct3[0] & ~i_funct3[1] &  i_funct3[2] ;

    logic[31:0] st_data1 , st_data2 ; 

    always_comb begin    // handle store
        bmask1 = 4'b0 ;
        bmask2 = 4'b0 ; 
        st_data1 = 32'b0 ; 
        st_data2 = 32'b0 ;
        if(b) begin
            case(b_addr)
                2'b00: begin bmask1 = 4'b0001 ; bmask2 = 4'b0000; st_data1 = {24'b0 , i_st_data[7:0]} ; st_data2 = 32'b0; end
                2'b01: begin bmask1 = 4'b0010 ; bmask2 = 4'b0000; st_data1 = {16'b0 , i_st_data[7:0] , 8'b0} ; st_data2 = 32'b0; end
                2'b10: begin bmask1 = 4'b0100 ; bmask2 = 4'b0000; st_data1 = {8'b0 , i_st_data[7:0] , 16'b0} ; st_data2 = 32'b0; end
                2'b11: begin bmask1 = 4'b1000 ; bmask2 = 4'b0000; st_data1 = {i_st_data[7:0] , 24'b0} ; st_data2 = 32'b0; end
            endcase
        end
         else if(h) begin
            case(b_addr)
                2'b00: begin bmask1 = 4'b0011 ; bmask2 = 4'b0000; st_data1 = {16'b0 , i_st_data[15:0]} ; st_data2 = 32'b0; end
                2'b01: begin bmask1 = 4'b0110 ; bmask2 = 4'b0000; st_data1 = {8'b0 , i_st_data[15:0] , 8'b0} ; st_data2 = 32'b0; end
                2'b10: begin bmask1 = 4'b1100 ; bmask2 = 4'b0000; st_data1 = {i_st_data[15:0] , 16'b0} ; st_data2 = 32'b0; end
                2'b11: begin bmask1 = 4'b1000 ; bmask2 = 4'b0001; st_data1 = {i_st_data[7:0] , 24'b0} ; st_data2 = {24'b0 , i_st_data[15:8]}; end
            endcase
        end
         else if(w) begin
            case(b_addr)
                2'b00: begin bmask1 = 4'b1111 ; bmask2 = 4'b0000; st_data1 = i_st_data ; st_data2 = 32'b0; end
                2'b01: begin bmask1 = 4'b1110 ; bmask2 = 4'b0001; st_data1 = {i_st_data[23:0] , 8'b0} ; st_data2 = {24'b0 , i_st_data[31:24]}; end
                2'b10: begin bmask1 = 4'b1100 ; bmask2 = 4'b0011; st_data1 = {i_st_data[15:0] , 16'b0} ; st_data2 = {16'b0 , i_st_data[31:16]}; end
                2'b11: begin bmask1 = 4'b1000 ; bmask2 = 4'b0111; st_data1 = {i_st_data[7:0] , 24'b0} ; st_data2 = {8'b0 , i_st_data[31:8]}; end
            endcase
        end
    end

    (* ramstyle = "M4K" *)logic [31:0] mem [0:400]; 
    logic[31:0] mem_addr , mem_addr_inc ; 
    assign mem_addr = {23'b0 , i_addr[10:2]} ; 
    add add_1(.a(mem_addr) , .b(32'd1) , .s(mem_addr_inc)) ;  

    always_ff @(posedge i_clk) begin 
            if (i_wren) begin
            if (bmask1[0]) mem[mem_addr][7 :0 ] <= st_data1[7:0  ];
            if (bmask1[1]) mem[mem_addr][15:8 ] <= st_data1[15:8 ];
            if (bmask1[2]) mem[mem_addr][23:16] <= st_data1[23:16];
            if (bmask1[3]) mem[mem_addr][31:24] <= st_data1[31:24];
        end
    end

    always_ff @(posedge i_clk) begin 
            if (i_wren) begin
            if (bmask2[0]) mem[mem_addr_inc][7 :0 ] <= st_data2[7:0  ];
            if (bmask2[1]) mem[mem_addr_inc][15:8 ] <= st_data2[15:8 ];
            if (bmask2[2]) mem[mem_addr_inc][23:16] <= st_data2[23:16];
            if (bmask2[3]) mem[mem_addr_inc][31:24] <= st_data2[31:24];
        end
    end


    
    logic[31:0] o_data_mem1 , o_data_mem2 ; 
    assign o_data_mem1 = mem[mem_addr];
    assign o_data_mem2 = mem[mem_addr_inc];

    always_comb begin    // handle load
        odata = 32'b0 ; 
        if(hu) begin
            case(b_addr)
                2'b00: odata = {16'b0 , o_data_mem1[15:8] , o_data_mem1[7:0]} ; 
                2'b01: odata = {16'b0 , o_data_mem1[23:16] , o_data_mem1[15:8]} ;
                2'b10: odata = {16'b0 , o_data_mem1[31:24] , o_data_mem1[23:16]} ;
                2'b11: odata = {16'b0 , o_data_mem2[7:0] , o_data_mem1[31:24]} ;
            endcase
        end

        if(w) begin
            case(b_addr)
                2'b00: odata = {o_data_mem1[31:24] , o_data_mem1[23:16], o_data_mem1[15:8], o_data_mem1[7:0]} ; 
                2'b01: odata = {o_data_mem2[7:0] , o_data_mem1[31:24] , o_data_mem1[23:16], o_data_mem1[15:8]} ;
                2'b10: odata = {o_data_mem2[15:8] , o_data_mem2[7:0] , o_data_mem1[31:24] , o_data_mem1[23:16]} ;
                2'b11: odata = {o_data_mem2[23:16] , o_data_mem2[15:8] , o_data_mem2[7:0] , o_data_mem1[31:24]} ;
            endcase
        end

        if(bu) begin
            case(b_addr)
                2'b00: odata = {24'b0 , o_data_mem1[7:0]} ; 
                2'b01: odata = {24'b0 , o_data_mem1[15:8]} ;
                2'b10: odata = {24'b0 , o_data_mem1[23:16]} ;
                2'b11: odata = {24'b0 , o_data_mem1[31:24]} ;
            endcase
        end

        if(b) begin
            case(b_addr)
                2'b00: odata = {{24{o_data_mem1[7]}} , o_data_mem1[7:0]} ; 
                2'b01: odata = {{24{o_data_mem1[15]}} , o_data_mem1[15:8]} ;
                2'b10: odata = {{24{o_data_mem1[23]}} , o_data_mem1[23:16]} ;
                2'b11: odata = {{24{o_data_mem1[31]}} , o_data_mem1[31:24]} ;
            endcase
        end

        if(h) begin
            case(b_addr)
                2'b00: odata = {{16{o_data_mem1[15]}} , o_data_mem1[15:8] , o_data_mem1[7:0]} ; 
                2'b01: odata = {{16{o_data_mem1[23]}} , o_data_mem1[23:16] , o_data_mem1[15:8]} ;
                2'b10: odata = {{16{o_data_mem1[31]}} , o_data_mem1[31:24] , o_data_mem1[23:16]} ;
                2'b11: odata = {{16{o_data_mem2[7]}} , o_data_mem2[7:0] , o_data_mem1[31:24]} ;
            endcase
        end

    end

    endmodule

module pc_plus_4(
    input  logic[31:0] i_pc,
    output logic[31:0] o_pc_four
) ; 
    logic[31:0] four ; 
    assign four = 32'd4 ; 
    add add_pc_four(.a(i_pc), .b(four), .s(o_pc_four)) ; 
    

endmodule

module instruction_memory (
    input  logic        i_clk,
    input  logic        i_reset,       
    input  logic [31:0] i_pc,     // 2^11 = 2048Byte                         
    output logic [31:0] o_instr       
);

    logic [31:0] imem [0:2047];

    logic [10:0] pc ;
    assign pc = {i_pc[12:2]} ; 

    // initial begin
    //     $readmemh(" ", imem);  load the assembly code file into instruction memory
    // end

    assign o_instr = imem[pc] ; 

endmodule

module immgen(
    input logic[31:0] i_instruction,
    output logic[31:0] o_imm
);

    always_comb begin
        case(i_instruction[6:0]) 
        7'b0010011: o_imm = ({{20{i_instruction[31]}} , i_instruction[31:20]}) & 
                          ({{27{i_instruction[13] | ~i_instruction[12]}} , 5'b11111}) ;  // I-type
        7'b1100111: o_imm = {{20{i_instruction[31]}} , i_instruction[31:20]} ;  //jalr
        7'b0100011: o_imm = {{20{i_instruction[31]}} , i_instruction[31:25] , i_instruction[11:7]} ; // S-type
        7'b0000011: o_imm = {{20{i_instruction[31]}} , i_instruction[31:20]} ;  // load
        7'b1100011: o_imm = {{19{i_instruction[31]}} , i_instruction[31] , i_instruction[7] , i_instruction[30:25],
                            i_instruction[11:8] ,1'b0} ;  // B-type
        7'b1101111: o_imm = {{12{i_instruction[31]}} , i_instruction[19:12], i_instruction[20],
                         i_instruction[30:21], 1'b0} ;   //jal
        7'b0110111: o_imm = {i_instruction[31:12], 12'b0};  // lui
        7'b0010111: o_imm = {i_instruction[31:12], 12'b0};  //auipc
        default : o_imm = 32'b0 ; 
        endcase
    end
endmodule

module control_unit(
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic       br_less,
    input  logic       br_equal,
    output logic       pc_sel,
    output logic       rd_wren,
    output logic       br_un,
    output logic       opa_sel,
    output logic       opb_sel,
    output logic [3:0] alu_op,
    output logic       mem_wren,
    output logic [1:0] wb_sel,
    output logic       insn_vld
);

    localparam [6:0]
        OP_R     = 7'b0110011,
        OP_I     = 7'b0010011,
        OP_L     = 7'b0000011,
        OP_S     = 7'b0100011,
        OP_B     = 7'b1100011,
        OP_LUI   = 7'b0110111,
        OP_AUIPC = 7'b0010111,
        OP_JAL   = 7'b1101111,
        OP_JALR  = 7'b1100111;

    always_comb begin
        pc_sel   = 0;
        rd_wren  = 0;
        br_un    = 0;
        opa_sel  = 0;
        opb_sel  = 0;
        alu_op   = 4'b0000;
        mem_wren = 0;
        wb_sel   = 2'b00; 

        case(opcode)
            OP_R: begin
                opa_sel = 1'b1 ; 
                opb_sel = 1'b0 ; 
                rd_wren = 1'b1 ;
                wb_sel  = 2'b01 ;
                pc_sel  = 1'b1 ; 
                mem_wren = 0;
                alu_op = {funct7[5] , funct3} ;
            end

            OP_I: begin
                opa_sel = 1'b1 ; 
                opb_sel = 1'b1 ; 
                rd_wren = 1'b1 ; 
                wb_sel = 2'b01 ; 
                pc_sel = 1'b1 ;
                mem_wren = 0;
                alu_op = {funct7[5] & (funct3[2] & ~funct3[1] & funct3[0]) , funct3} ; 
            end

            OP_L: begin
                opa_sel = 1'b1 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b10 ;
                rd_wren = 1'b1;
                pc_sel = 1'b1 ;
                alu_op = 4'b0 ; 
                mem_wren = 0;
            end

            OP_S: begin
                opa_sel = 1'b1 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b11 ;
                rd_wren = 1'b0;
                pc_sel = 1'b1 ;
                mem_wren = 1'b1 ;
                alu_op = 4'b0 ; 
            end

            OP_B: begin
                rd_wren = 1'b0 ;
                mem_wren = 1'b0 ;
                opa_sel = 1'b0 ;
                opb_sel = 1'b1 ;
                alu_op = 4'b0000 ; 
                br_un = ~(funct3[2] & funct3[1]) ; 
                case(funct3)
                    3'b000: begin
                        if(br_equal) pc_sel = 1'b0 ;
                        else pc_sel = 1'b1 ; 
                    end

                    3'b001: begin
                        if(br_equal) pc_sel = 1'b1 ;
                        else pc_sel = 1'b0 ; 
                    end

                    3'b100: begin
                        if(br_less) pc_sel = 1'b0 ;
                        else pc_sel = 1'b1 ; 
                    end

                    3'b101: begin
                        if(br_less) pc_sel = 1'b1 ;
                        else pc_sel = 1'b0 ; 
                    end

                    3'b110: begin
                        if(br_less) pc_sel = 1'b0 ;
                        else pc_sel = 1'b1 ; 
                    end

                    3'b111: begin
                        if(br_less) pc_sel = 1'b1 ;
                        else pc_sel = 1'b0 ; 
                    end

                    default: pc_sel = 1'b1 ; 
                endcase
            end

            OP_LUI: begin
                opa_sel = 1'b1 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b01 ;
                rd_wren = 1'b1;
                pc_sel = 1'b1 ;
                mem_wren = 1'b0 ;
                alu_op = 4'b1111 ;
            end

            OP_AUIPC: begin
                opa_sel = 1'b0 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b01 ;
                rd_wren = 1'b1;
                pc_sel = 1'b1 ;
                mem_wren = 1'b0 ;
                alu_op = 4'b0000 ;
            end

            OP_JAL: begin
                opa_sel = 1'b0 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b00 ;
                rd_wren = 1'b1;
                pc_sel = 1'b0 ;
                mem_wren = 1'b0 ;
                alu_op = 4'b0000 ;
            end

            OP_JALR: begin
                opa_sel = 1'b1 ;
                opb_sel = 1'b1 ;
                wb_sel = 2'b00 ;
                rd_wren = 1'b1;
                pc_sel = 1'b0 ;
                mem_wren = 1'b0 ;
                alu_op = 4'b0000 ;
            end

            default: begin
                pc_sel   = 1'b0;
                rd_wren  = 1'b0;
                br_un    = 1'b0;
                opa_sel  = 1'b0;
                opb_sel  = 1'b0;
                alu_op   = 4'b0000;
                mem_wren = 1'b0;
                wb_sel   = 2'b00;
            end

        endcase
    end
   // using this one is also correct
//      always_comb begin
//     pc_sel   = 1'b1;
//     rd_wren  = 1'b0;
//     br_un    = 1'b0;
//     opa_sel  = 1'b0;
//     opb_sel  = 1'b0;
//     alu_op   = 4'b0000;
//     mem_wren = 1'b0;
//     wb_sel   = 2'b00;
    
//     unique case (opcode)
//       OP_R: begin
//         opa_sel=1; rd_wren=1; wb_sel=2'b01;
//         alu_op={funct7[5],funct3};
//       end
//       OP_I: begin
//         opa_sel=1; opb_sel=1; rd_wren=1; wb_sel=2'b01;
//         alu_op={funct7[5]&(funct3==3'b101),funct3};
//       end
//       OP_L: begin
//         opa_sel=1; opb_sel=1; rd_wren=1; wb_sel=2'b10;
//       end
//       OP_S: begin
//         opa_sel=1; opb_sel=1; mem_wren=1;
//       end
//       OP_B: begin
//         opa_sel=0; opb_sel=1;
//         br_un=(funct3[2]&funct3[1]);
//         case(funct3)
//           3'b000: pc_sel = ~br_equal; // BEQ
//           3'b001: pc_sel =  br_equal; // BNE
//           3'b100: pc_sel = ~br_less;  // BLT
//           3'b101: pc_sel =  br_less;  // BGE
//           3'b110: pc_sel = ~br_less;  // BLTU
//           3'b111: pc_sel =  br_less;  // BGEU
//           default: pc_sel=1'b1;
//         endcase
//       end
//       OP_LUI: begin
//         opa_sel=1; opb_sel=1; rd_wren=1; wb_sel=2'b01; alu_op=4'b1111;
//       end
//       OP_AUIPC: begin
//         opa_sel=0; opb_sel=1; rd_wren=1; wb_sel=2'b01;
//       end
//       OP_JAL: begin
//         opa_sel=0; opb_sel=1; rd_wren=1; wb_sel=2'b00; pc_sel=0;
//       end
//       OP_JALR: begin
//         opa_sel=1; opb_sel=1; rd_wren=1; wb_sel=2'b00; pc_sel=0;
//       end
//       default: ; // keep defaults
//     endcase
//   end

    insnvld insn_ckeck(.op(opcode) , .funct3(funct3) , .funct7(funct7) , .valid(insn_vld)) ; 

endmodule

module pc(
    input  logic       i_clk,
    input  logic       i_reset,
    input  logic[31:0] i_pc_next,
    output logic[31:0] o_pc
) ; 
    always_ff @(posedge i_clk) begin
        if(!i_reset) o_pc <= 32'b0 ; 
        else o_pc <= i_pc_next ; 
    end 

endmodule

module insnvld(
    input logic[6:0] op,
    input logic[2:0] funct3,
    input logic[6:0] funct7,
    output logic valid
);

    localparam [6:0]
    OP_R     = 7'b0110011,
    OP_I     = 7'b0010011,
    OP_L     = 7'b0000011,
    OP_S     = 7'b0100011,
    OP_B     = 7'b1100011,
    OP_LUI   = 7'b0110111,
    OP_AUIPC = 7'b0010111,
    OP_JAL   = 7'b1101111,
    OP_JALR  = 7'b1100111;

    always_comb begin
        if(~(|(op^OP_R))) begin
            case(funct3)
                3'b000: begin
                    if(~(|funct7) | ~(|(funct7 ^ 7'b0100000))) valid = 1'b1 ; 
                    else valid = 1'b0 ; 
                end

                3'b001: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b010: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b011: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b100: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b101: begin
                    if(~(|funct7) | ~(|(funct7 ^ 7'b0100000))) valid = 1'b1 ; 
                    else valid = 1'b0 ; 
                end

                3'b110: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b111: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end
            endcase
        end
        else if(~(|(op^OP_I))) begin
            case(funct3)
                3'b000: begin
                    valid = 1'b1 ;
                end

                3'b001: begin
                    if(~(|funct7)) valid = 1'b1 ; 
                    else valid = 1'b0 ;
                end

                3'b010: begin
                    valid = 1'b1 ;
                end

                3'b011: begin
                    valid = 1'b1 ;
                end

                3'b100: begin
                    valid = 1'b1 ;
                end

                3'b101: begin
                    if(~(|funct7) | ~(|(funct7 ^ 7'b0100000))) valid = 1'b1 ; 
                    else valid = 1'b0 ; 
                end

                3'b110: begin
                    valid = 1'b1 ;
                end

                3'b111: begin
                    valid = 1'b1 ;
                end
            endcase
        end
        else if(~(|(op^OP_S))) begin
            case(funct3)
                3'b000 , 3'b001 , 3'b010 : valid = 1'b1 ; 
                default: valid = 1'b0 ;
            endcase
        end
        else if(~(|(op^OP_L))) begin
            case(funct3)
                3'b000 , 3'b001 , 3'b010 , 3'b100 , 3'b101 : valid = 1'b1 ; 
                default: valid = 1'b0 ;
            endcase
        end
        else if(~(|(op^OP_B))) begin
            case(funct3)
                3'b010 , 3'b011 : valid = 1'b0 ; 
                default: valid = 1'b1 ;
            endcase
        end
        else if(~(|(op^OP_JAL))) begin
            valid = 1'b1 ; 
        end
        else if(~(|(op^OP_JALR))) begin
            case(funct3)
                3'b000 : valid = 1'b1 ; 
                default: valid = 1'b0 ;
            endcase
        end
        else if(~(|(op^OP_LUI))) begin
            valid = 1'b1 ;
        end
        else if(~(|(op^OP_AUIPC))) begin
            valid = 1'b1 ;
        end
        else valid = 1'b0 ; 

    end 

endmodule

module brc (
  input  logic [31:0] i_rs1_data,
  input  logic [31:0] i_rs2_data,
  input  logic        i_br_un,     
  output logic        o_br_less,
  output logic        o_br_equal
);
  assign o_br_equal = &(~(i_rs1_data ^ i_rs2_data));
  logic [31:0] eq_mask;  
  logic [31:0] lt_mask; 
  logic        unsigned_less;

  always_comb begin
    eq_mask[31] = 1'b1; 
    for (int i = 30; i >= 0; i--) begin
      eq_mask[i] = eq_mask[i+1] & ~(i_rs1_data[i+1] ^ i_rs2_data[i+1]);
    end
    for (int i = 0; i < 32; i++) begin
      lt_mask[i] = (~i_rs1_data[i]) & i_rs2_data[i] & eq_mask[i];
    end
    unsigned_less = |lt_mask;
  end
  logic sign_rs1, sign_rs2;
  assign sign_rs1 = i_rs1_data[31];
  assign sign_rs2 = i_rs2_data[31];

  logic signed_less;
  always_comb begin
    if (sign_rs1 != sign_rs2)
      signed_less = sign_rs1 & ~sign_rs2; // nếu rs1 âm, rs2 dương
    else
      signed_less = unsigned_less;        // cùng dấu → dùng kết quả unsigned
  end
  assign o_br_less = (i_br_un) ? signed_less : unsigned_less;

endmodule


//use this for misalignedment handling for I/O port
// module io_memory(
//     input logic i_clk ,
//     input logic[31:0] i_data,
//     input logic[31:0] i_addr ,
//     input logic i_reset , 
//     input logic i_en ,
//     input  logic [2:0]  i_funct3,
//     output logic[31:0] odata 
// );  
//     logic[31:0] io_data ; 

//     logic[3:0] bmask; 
//     logic b , h , w , bu , hu ; 
//     logic[1:0] b_addr ;  // byte address
//     assign b_addr = i_addr[1:0] ; 
//     assign b  = ~i_funct3[0] & ~i_funct3[1] & ~i_funct3[2] ; 
//     assign h  =  i_funct3[0] & ~i_funct3[1] & ~i_funct3[2] ;
//     assign w  = ~i_funct3[0] &  i_funct3[1] & ~i_funct3[2] ;
//     assign bu = ~i_funct3[0] & ~i_funct3[1] &  i_funct3[2] ;
//     assign hu =  i_funct3[0] & ~i_funct3[1] &  i_funct3[2] ;

//     logic[31:0] st_data ; 

//     always_comb begin
//         if(b) begin
//             case(b_addr)
//                 2'b00: begin  bmask = 4'b0001 ; st_data = {24'b0 , i_data[7:0]}; end
//                 2'b01: begin  bmask = 4'b0010 ; st_data = {16'b0 , i_data[7:0] , 8'b0}; end
//                 2'b10: begin  bmask = 4'b0100 ; st_data = {8'b0 , i_data[7:0] , 16'b0}; end
//                 2'b11: begin  bmask = 4'b1000 ; st_data = {i_data[7:0] , 24'b0}; end
//             endcase
//         end
//         else if(h) begin
//             case(b_addr)
//                 2'b00: begin  bmask = 4'b0011 ; st_data = {16'b0 , i_data[15:0]}; end
//                 2'b01: begin  bmask = 4'b0110 ; st_data = {8'b0 , i_data[15:0] , 8'b0}; end
//                 2'b10: begin  bmask = 4'b1100 ; st_data = {i_data[15:0] , 16'b0}; end
//                 2'b11: begin  bmask = 4'b1000 ; st_data = {i_data[7:0] , 24'b0}; end
//             endcase
//         end
//         else if(w) begin
//             case(b_addr)
//                 2'b00: begin  bmask = 4'b1111 ; st_data = i_data; end
//                 2'b01: begin  bmask = 4'b1110 ; st_data = {i_data[23:0] , 8'b0}; end
//                 2'b10: begin  bmask = 4'b1100 ; st_data = {i_data[15:0] , 16'b0}; end
//                 2'b11: begin  bmask = 4'b1000 ; st_data = {i_data[7:0] , 24'b0}; end
//             endcase
//         end
//         else begin
//             bmask = 4'b0000 ; st_data = 32'b0 ; 
//         end
//     end 

//     always_ff @(posedge i_clk) begin
//         if(!i_reset) io_data <= 32'b0 ; 
//         else if(i_en) begin
//             if(bmask[0]) io_data[7:0] <= st_data[7:0] ; 
//             if(bmask[1]) io_data[15:8] <= st_data[15:8] ;
//             if(bmask[2]) io_data[23:16] <= st_data[23:16] ;
//             if(bmask[3]) io_data[31:24] <= st_data[31:24] ;
//         end
        
//     end

//     always_comb begin
//         odata = 32'b0 ; 
//         if(b) begin
//             case(b_addr)
//                 2'b00: odata = {{24{io_data[7]}} , io_data[7:0]} ; 
//                 2'b01: odata = {{24{io_data[15]}} , io_data[15:8]} ;
//                 2'b10: odata = {{24{io_data[23]}} , io_data[23:16]} ;
//                 2'b11: odata = {{24{io_data[31]}} , io_data[31:24]} ;
//             endcase
//         end
//         if(h) begin
//             case(b_addr)
//                 2'b00: odata = {{16{io_data[15]}} , io_data[15:0]} ; 
//                 2'b01: odata = {{16{io_data[23]}} , io_data[23:8]} ;
//                 2'b10: odata = {{16{io_data[31]}} , io_data[31:16]} ;
//                 2'b11: odata = {{24{io_data[31]}} , io_data[31:24]} ;
//             endcase
//         end
//         if(w) begin
//             case(b_addr)
//                 2'b00: odata = io_data ; 
//                 2'b01: odata = {8'b0 , io_data[31:8]} ; 
//                 2'b10: odata = {16'b0 , io_data[31:16]} ;
//                 2'b11: odata = {24'b0 , io_data[31:24]} ; 
//             endcase
//         end
//         if(bu) begin
//             case(b_addr)
//                 2'b00: odata = {24'b0 , io_data[7:0]} ; 
//                 2'b01: odata = {24'b0 , io_data[15:8]} ;
//                 2'b10: odata = {24'b0 , io_data[23:16]} ;
//                 2'b11: odata = {24'b0 , io_data[31:24]} ; 
//             endcase
//         end
//         if(hu) begin
//             case(b_addr)
//                 2'b00: odata = {16'b0 , io_data[15:0]} ; 
//                 2'b01: odata = {16'b0 , io_data[23:8]} ;
//                 2'b10: odata = {16'b0 , io_data[31:16]} ;
//                 2'b11: odata = {24'b0 , io_data[31:24]} ;
//             endcase
//         end
//     end 

// endmodule








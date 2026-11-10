module tb_static;
  logic [4:0][9:0] exponents;
  logic [4:0] sel_exp;
  logic [3:0] lane_mask;
  logic [4:0][24:0] sigs_in;
  wire [9:0] max_exp;
  wire [4:0][29:0] sigs_out;
  wire [4:0] sticky_bits, fp_negs;
  VX_tcu_tfr_align #(.N(5),.WI(25),.WO(30)) dut (
    .clk(1'b0),.valid_in(1'b0),.req_id(32'b0),.exponents(exponents),.sel_exp(sel_exp),
    .lane_mask(lane_mask),.sigs_in(sigs_in),.is_int(1'b0),.max_exp(max_exp),
    .sigs_out(sigs_out),.sticky_bits(sticky_bits),.fp_negs(fp_negs));
  initial begin
    exponents='0; sel_exp=5'b00001; lane_mask='0; sigs_in='0;
    exponents[0]=10'd1023; exponents[4]=10'd1020; sigs_in[4]=25'h14d125c;
    #1;
    $display("STATIC1 in=%h internal=%h tz=%0d sticky=%b",sigs_in[4],dut.g_align_lanes[4].mag_shifted,dut.g_align_lanes[4].mag_tz,sticky_bits[4]);
    if (sticky_bits[4] !== 0) $fatal(1,"static1 fail");
    sigs_in[4]=25'h1083132; exponents[4]=10'd622;
    #1;
    $display("STATIC2 in=%h internal=%h tz=%0d sticky=%b",sigs_in[4],dut.g_align_lanes[4].mag_shifted,dut.g_align_lanes[4].mag_tz,sticky_bits[4]);
    sigs_in[4]=25'h14d125c; exponents[4]=10'd1020;
    #1;
    $display("STATIC3 in=%h internal=%h tz=%0d sticky=%b",sigs_in[4],dut.g_align_lanes[4].mag_shifted,dut.g_align_lanes[4].mag_tz,sticky_bits[4]);
    if (sticky_bits[4] !== 0) $fatal(1,"static3 fail");
    $finish;
  end
endmodule

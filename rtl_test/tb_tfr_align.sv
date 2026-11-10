module tb_tfr_align;
  localparam N = 5;
  logic [N-1:0][9:0] exponents;
  logic [N-1:0] sel_exp;
  logic [N-2:0] lane_mask;
  logic [N-1:0][24:0] sigs_in;
  logic is_int;
  wire [9:0] max_exp;
  wire [N-1:0][29:0] sigs_out;
  wire [N-1:0] sticky_bits, fp_negs;
  VX_tcu_tfr_align #(.N(N), .WI(25), .WO(30)) dut (
    .clk(1'b0), .valid_in(1'b0), .req_id(32'b0),
    .exponents(exponents), .sel_exp(sel_exp), .lane_mask(lane_mask),
    .sigs_in(sigs_in), .is_int(is_int),
    .max_exp(max_exp), .sigs_out(sigs_out),
    .sticky_bits(sticky_bits), .fp_negs(fp_negs)
  );
  initial begin
    longint unsigned mag, mask, shifted;
    logic [29:0] expected_out;
    logic [24:0] curr_sig;
    logic [N-1:0][24:0] next_sigs;
    logic [N-1:0][9:0] next_exponents;
    bit expected_sticky, expected_neg, enabled;
    int chosen, delta;
    for (int trial = 0; trial < 10000; trial++) begin
      chosen = $urandom_range(0, N-1);
      sel_exp = '0;
      sel_exp[chosen] = 1'b1;
      for (int i = 0; i < N; i++) begin
        next_exponents[i] = (i == chosen) ? 10'd1023 : 10'(1023 - $urandom_range(0, 1023));
        next_sigs[i] = 25'($urandom);
      end
      exponents = next_exponents;
      sigs_in = next_sigs;
      lane_mask = 4'($urandom);
      is_int = 1'($urandom);
      #1;
      if (max_exp !== 10'd1023) $fatal(1, "bad max exponent");
      for (int i = 0; i < N; i++) begin
        enabled = (i == N-1) || lane_mask[i];
        curr_sig = sigs_in[i];
        mag = (64'(curr_sig[23:0])) << ((i == N-1) ? 1 : 2);
        delta = 1023 - int'(exponents[i]);
        mask = delta >= 26 ? 64'h3ffffff : ((64'd1 << delta) - 1);
        expected_sticky = enabled && ((mag & mask) != 0);
        shifted = (delta >= 26) ? 0 : (mag >> delta);
        expected_neg = enabled && curr_sig[24] && !is_int;
        if (!enabled) expected_out = 30'b0;
        else if (is_int) expected_out = 30'($signed(curr_sig));
        else if (expected_neg) expected_out = ~30'(shifted);
        else expected_out = 30'(shifted);
        if (sticky_bits[i] !== expected_sticky || fp_negs[i] !== expected_neg || sigs_out[i] !== expected_out)
          $fatal(1, "trial %0d lane %0d q %0d mag %0h sticky %b/%b neg %b/%b out %h/%h", trial, i, delta, mag,
                 sticky_bits[i], expected_sticky, fp_negs[i], expected_neg, sigs_out[i], expected_out);
      end
    end
    $display("PASS 10000 Vortex TFR align vectors x 5 lanes");
    $finish;
  end
endmodule

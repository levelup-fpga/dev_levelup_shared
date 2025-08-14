// fir_filter_tb.sv
// SystemVerilog-2012
//
// FIR filter (generate-based multipliers and adders) + testbench.
// - PIPELINED parameter selects pipelined (per-tap registered adders) or non-pipelined (combinational sum, register final).
// - Multiplication stage: generate (one multiply/register per tap).
// - Accumulation stage: generate (adder chain built by generate).
// - data_in_valid controls new sample acceptance.
// - data_out: full accumulator width.
// - data_out_scaled: DATA_WIDTH width, truncated or saturated controlled by SATURATE.
// - TB reads coefs.txt: first line \"DATA_WIDTH=<n> COEF_WIDTH=<m>\", subsequent lines hex words (one per line).
//
// Notes:
// - Simulators differ in text parsing; the TB uses portable $fscanf reading tokens.
// - Because SV generics are static, TB instantiates DUT with a MAX_TAPS (physical array size) and fills only first N_TAPS entries read from file.
// - The code is focused on simulation and clarity for synthesis mapping.

`timescale 1ns/1ps
module fir_filter #(
    parameter int N_TAPS     = 8,       // compile-time physical array size
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 16,
    parameter bit SATURATE   = 1'b1,
    parameter bit PIPELINED  = 1'b1
) (
    input  logic                           clk,
    input  logic                           rst_n,
    input  logic                           data_in_valid,
    input  logic signed [DATA_WIDTH-1:0]   data_in,
    input  logic signed [COEF_WIDTH-1:0]   coef [N_TAPS],
    output logic signed [DATA_WIDTH+COEF_WIDTH+$clog2(N_TAPS)-1:0] data_out,       // safe accumulator width
    output logic signed [DATA_WIDTH-1:0]   data_out_scaled,
    output logic                           valid_out
);

    // local widths
    localparam int PROD_WIDTH = DATA_WIDTH + COEF_WIDTH;
    localparam int ACC_EXTRA  = (N_TAPS > 1) ? $clog2(N_TAPS) : 0;
    localparam int ACC_WIDTH  = PROD_WIDTH + ACC_EXTRA;

    // taps shift register (registered) - single always block is fine
    logic signed [DATA_WIDTH-1:0] taps [N_TAPS];
    integer ii;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (ii = 0; ii < N_TAPS; ii = ii + 1) taps[ii] <= '0;
        end else begin
            if (data_in_valid) begin
                taps[0] <= data_in;
                for (ii = 1; ii < N_TAPS; ii = ii + 1)
                    taps[ii] <= taps[ii-1];
            end
        end
    end

    // Multiplication stage: generate one multiplier/register per tap
    logic signed [PROD_WIDTH-1:0] products [N_TAPS];
    genvar i;
    generate
        for (i = 0; i < N_TAPS; i = i + 1) begin : GEN_MULT
            // each multiplier is registered to align with pipeline, and to avoid large combinational chains
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) products[i] <= '0;
                else if (data_in_valid)
                    products[i] <= $signed(taps[i]) * $signed(coef[i]);
                // else hold previous product (or could clear) - we hold to keep pipeline data
            end
        end
    endgenerate

    // Accumulation stage implemented with generate structure
    // Pipelined: create acc_stage registers where acc_stage[i+1] <= acc_stage[i] + products[i]
    // Non-pipelined: create combinational sum chain sum_comb and register the final sum

    logic signed [ACC_WIDTH-1:0] acc_final;
    // pipelined registers (only used in pipelined mode)
    logic signed [ACC_WIDTH-1:0] acc_stage [0:N_TAPS]; // acc_stage[0] used as zero base

    generate
        if (PIPELINED) begin : GEN_PIPELINED
            // initialize acc_stage[0] on each valid input (we register zero)
            // create per-tap registered adder via generate
            genvar j;
            // register acc_stage[0]
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) acc_stage[0] <= '0;
                else if (data_in_valid) acc_stage[0] <= '0;
            end

            for (j = 0; j < N_TAPS; j = j + 1) begin : GEN_ACC_REGS
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) acc_stage[j+1] <= '0;
                    else if (data_in_valid)
                        acc_stage[j+1] <= acc_stage[j] + $signed({{(ACC_WIDTH-PROD_WIDTH){products[j][PROD_WIDTH-1]}}, products[j]});
                end
            end

            // final stage register already provided by acc_stage[N_TAPS]
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) acc_final <= '0;
                else if (data_in_valid) acc_final <= acc_stage[N_TAPS];
            end
        end else begin : GEN_NONPIPELINED
            // combinational chain sum_comb[0..N_TAPS]
            logic signed [ACC_WIDTH-1:0] sum_comb [0:N_TAPS];
            // base
            assign sum_comb[0] = '0;
            genvar k;
            for (k = 0; k < N_TAPS; k = k + 1) begin : GEN_ACC_COMB
                // each concurrent assignment builds the combinational chain
                assign sum_comb[k+1] = sum_comb[k] + $signed({{(ACC_WIDTH-PROD_WIDTH){products[k][PROD_WIDTH-1]}}, products[k]});
            end
            // register final sum on valid
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) acc_final <= '0;
                else if (data_in_valid) acc_final <= sum_comb[N_TAPS];
            end
        end
    endgenerate

    assign data_out = acc_final;

    // scaled output: truncation or saturation to DATA_WIDTH
    // build max/min values
    localparam logic signed [DATA_WIDTH-1:0] MAX_POS = (2**(DATA_WIDTH-1) - 1);
    localparam logic signed [DATA_WIDTH-1:0] MAX_NEG = -(2**(DATA_WIDTH-1));

    always_comb begin
        // sign-extend comparison values for ACC_WIDTH
        logic signed [ACC_WIDTH-1:0] acc_max = $signed({ { (ACC_WIDTH-DATA_WIDTH) { MAX_POS[DATA_WIDTH-1] } }, MAX_POS });
        logic signed [ACC_WIDTH-1:0] acc_min = $signed({ { (ACC_WIDTH-DATA_WIDTH) { MAX_NEG[DATA_WIDTH-1] } }, MAX_NEG });

        if (SATURATE) begin
            if (acc_final > acc_max) data_out_scaled = MAX_POS;
            else if (acc_final < acc_min) data_out_scaled = MAX_NEG;
            else data_out_scaled = acc_final[DATA_WIDTH-1:0];
        end else begin
            data_out_scaled = acc_final[DATA_WIDTH-1:0];
        end
    end

    // valid_out pipeline: shift data_in_valid through registers to align with processing latency
    localparam int STAGES = (N_TAPS > 1) ? $clog2(N_TAPS) : 0;
    localparam int PIPE_LAT = (PIPELINED) ? (N_TAPS + 1 + STAGES) : 1;
    logic [PIPE_LAT-1:0] valid_shift;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_shift <= '0;
        else valid_shift <= {valid_shift[PIPE_LAT-2:0], data_in_valid};
    end
    assign valid_out = valid_shift[PIPE_LAT-1];

endmodule


// =======================
// Testbench
// =======================
module tb_fir_filter;
    // Simulation parameters
    parameter int MAX_TAPS = 256;
    parameter int SIM_WIDTH = 32; // width for DUT instantiation (supports larger widths for TB)
    parameter real CLK_PERIOD_NS = 20.0; // 50 MHz

    // clock / reset
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #(CLK_PERIOD_NS/2.0) clk = ~clk;
    end

    // file-driven parameters (read at runtime)
    int FILE_DATA_WIDTH;
    int FILE_COEF_WIDTH;
    int FILE_N_TAPS;

    // arrays to hold coefficients (hex input)
    logic signed [SIM_WIDTH-1:0] coef_mem [0:MAX_TAPS-1];

    // DUT interfaces (SIM_WIDTH sized)
    logic data_in_valid;
    logic signed [SIM_WIDTH-1:0] data_in;
    logic signed [SIM_WIDTH-1:0] coefs_for_dut [0:MAX_TAPS-1];
    logic signed [(SIM_WIDTH+SIM_WIDTH+$clog2(MAX_TAPS))-1:0] data_out;
    logic signed [SIM_WIDTH-1:0] data_out_scaled;
    logic valid_out;

    // instantiate DUT (with physical MAX_TAPS and SIM_WIDTH widths)
    fir_filter #(
        .N_TAPS(MAX_TAPS),
        .DATA_WIDTH(SIM_WIDTH),
        .COEF_WIDTH(SIM_WIDTH),
        .SATURATE(1'b1),
        .PIPELINED(1'b1) // toggle to 0 for non-pipelined DUT
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in_valid(data_in_valid),
        .data_in(data_in[SIM_WIDTH-1:0]),
        .coef(coefs_for_dut),
        .data_out(data_out),
        .data_out_scaled(data_out_scaled),
        .valid_out(valid_out)
    );

    // read coefficients file
    initial begin
        FILE_DATA_WIDTH = 16;
        FILE_COEF_WIDTH = 16;
        FILE_N_TAPS = 0;

        string fname = "coefs.txt";
        int fd;
        fd = $fopen(fname, "r");
        if (fd == 0) begin
            $display("ERROR: cannot open %s", fname);
            $finish;
        end

        // read header: expect 'DATA_WIDTH=%d COEF_WIDTH=%d'
        int scanned;
        scanned = $fscanf(fd, "DATA_WIDTH=%d COEF_WIDTH=%d\n", FILE_DATA_WIDTH, FILE_COEF_WIDTH);
        if (scanned != 2) begin
            $display("ERROR: header parse failed, expected 'DATA_WIDTH=<n> COEF_WIDTH=<m>'");
            $fclose(fd);
            $finish;
        end

        // read remaining hex lines until EOF
        FILE_N_TAPS = 0;
        string line;
        // use temporary buffer
        byte buf [256];
        while (!$feof(fd)) begin
            // read token as hex string (skip empty lines)
            line = "";
            int rc = $fgets(line, fd);
            if (rc == 0) break;
            // trim whitespace
            line = line.toupper().split()[$size(line.toupper().split())-1]; // last token (robust); but some SVs may not support split()
            // portable fallback: manually remove leading/trailing spaces:
            // but to keep portable we do a simple $sscanf as hex
            int hv;
            int r = $sscanf(line, "%h", hv);
            if (r == 1) begin
                // sign-extend according to COEF width if desired; here store into SIM_WIDTH
                // treat hv as unsigned hex, then cast to signed with two's complement
                // if hex length indicates sign bit set for FILE_COEF_WIDTH, produce signed value accordingly
                bit signed_flag;
                if (FILE_COEF_WIDTH < SIM_WIDTH) begin
                    // sign-extend manually
                    int signbit = (hv >> (FILE_COEF_WIDTH-1)) & 1;
                    if (signbit) begin
                        // negative: extend with ones
                        int ext = hv | (~((1 << FILE_COEF_WIDTH) - 1));
                        coef_mem[FILE_N_TAPS] = $signed(ext);
                    end else begin
                        coef_mem[FILE_N_TAPS] = $signed(hv);
                    end
                end else begin
                    coef_mem[FILE_N_TAPS] = $signed(hv);
                end
                FILE_N_TAPS++;
                if (FILE_N_TAPS >= MAX_TAPS) begin
                    $display("WARNING: reached MAX_TAPS (%0d); remaining coefs ignored", MAX_TAPS);
                    break;
                end
            end
            // else ignore non-hex lines
        end

        $fclose(fd);
        $display("Loaded coefs: DATA_WIDTH=%0d COEF_WIDTH=%0d TAPS=%0d",
                 FILE_DATA_WIDTH, FILE_COEF_WIDTH, FILE_N_TAPS);

        // create coefs_for_dut: place loaded coefs in first FILE_N_TAPS entries, rest zero
        for (int i = 0; i < MAX_TAPS; i++) begin
            if (i < FILE_N_TAPS) coefs_for_dut[i] = coef_mem[i];
            else                 coefs_for_dut[i] = '0;
        end
    end

    // stimulus: sine-wave generator; scales according to FILE_DATA_WIDTH for amplitude
    initial begin
        // reset
        rst_n = 0;
        data_in_valid = 0;
        data_in = '0;
        #100;
        rst_n = 1;
        // wait a bit for file reading (quick heuristic)
        #100;

        real t = 0.0;
        real FREQ_HZ = 1e3;
        real FS_HZ   = 48e3;
        real amp = (2.0**(FILE_DATA_WIDTH-1)) - 1.0;

        forever begin
            data_in_valid <= 1'b1;
            // compute sample and cast to signed
            real s = $sin(2.0 * 3.141592653589793 * FREQ_HZ * t);
            int sample = $rtoi(s * amp);
            // constrain to DATA_WIDTH signed range
            int maxp = (1 << (FILE_DATA_WIDTH-1)) - 1;
            int minn = - (1 << (FILE_DATA_WIDTH-1));
            if (sample > maxp) sample = maxp;
            if (sample < minn) sample = minn;
            // place into data_in (SIM_WIDTH)
            data_in <= $signed(sample);
            t = t + 1.0 / FS_HZ;
            #(CLK_PERIOD_NS);
        end
    end

    // simple monitor
    initial begin
        #100000; // run time
        $display("Simulation finished (time limit reached)");
        $finish;
    end

endmodule

// -----------------------------
// Example coefs.txt formats (keep beside fir_filter_tb.sv):
//
// For 13-bit width:
// DATA_WIDTH=13 COEF_WIDTH=13
// 0001
// 1FFE
// 0A3C
// FFFF
// 07D0
// 0005
// 0ABC
// 1F00
//
// For 16-bit width:
// DATA_WIDTH=16 COEF_WIDTH=16
// 0001
// FFFE
// 1234
// FFFF
// 07D0
// 0005
// 0ABC
// 1F00
//
// Notes:
// - If your simulator has better text parsing builtins, you can simplify the TB file parsing.
// - If you prefer the DUT to be instantiated with exact N_TAPS and widths, replace MAX_TAPS/SIM_WIDTH and hardcode the generics in the TB (that is simpler).


`timescale 1ns / 10 ps
/*
    Testbench for 9-tap FIR lowpass filter
    Cordic is used to synthesize a noisy signal compromising two sine waves at 2MHz and 30MHz sampled at 500MHz.
    The noisy signal is resamplede at 100MHz before feeding the FIR lowpass filter with a cutoff frequency of ~10MHz.
*/
module fir_tb();
    localparam CORDIC_CLK_PERIOD    = 2;        // To create 500 MHz CORDIC sampling clock
    localparam FIR_CLK_PERIOD       = 10;       // To create 100MHz FIR Lowpass filter sampling clock
    localparam signed [15:0] PI_POS = 16'h6488; // +pi in fixed point format Q(3,13)
    localparam signed [15:0] PI_NEG = 16'h9B78; // -pi in fixed point format Q(3,13)
    localparam PHASE_INC_2MHz       = 200;      // Phase Jump for 2MHz sine wave synthesis
    localparam PHASE_INC_30MHz      = 3000;     // Phase Jump for 30MHz sine wave synthesis
    
    reg cordic_clk   = 1'b0;
    reg fir_clk      = 1'b0;
    reg phase_tvalid = 1'b0;
    
    reg signed [15:0] phase_2MHz = 0;           // 2MHz phase sweep 
    reg signed [15:0] phase_30MHz = 0;          // 30MHz phase sweep
    
    wire sincos_2MHz_tvalid;
    wire signed [15:0] sin_2MHz, cos_2MHz;      // 2MHz sine/cosine wave
    wire sincos_30MHz_tvalid;
    wire signed [15:0] sin_30MHz, cos_30MHz;    // 30MHz sine/cosine wave
    
    reg signed [15:0] noisy_signal = 0;         // Resampled 2MHz sine  + 30MHz sine
    wire signed [15:0] filtered_signal;         // Filtered signal output from FIR lowpass filter
    
    // Synthesize 2MHz sine wave
    cordic_0 cordic_inst_0 (
        .aclk                   (cordic_clk),
        .s_axis_phase_tvalid    (phase_tvalid),
        .s_axis_phase_tdata     (phase_2MHz),
        .m_axis_dout_tvalid     (sincos_2MHz_tvalid),
        .m_axis_dout_tdata      ({sin_2MHz, cos_2MHz})
    );
    
    // Synthesize 30MHz sine wave    
    cordic_0 cordic_inst_1 (
        .aclk                   (cordic_clk),
        .s_axis_phase_tvalid    (phase_tvalid),
        .s_axis_phase_tdata     (phase_30MHz),
        .m_axis_dout_tvalid     (sincos_30MHz_tvalid),
        .m_axis_dout_tdata      ({sin_30MHz, cos_30MHz})
    );
    
    // Phase Sweep
    always @(posedge cordic_clk)
        begin
            phase_tvalid <= 1'b1;
            
            // Sweep phase to synthesize 2MHz sine wave
            if (phase_2MHz + PHASE_INC_2MHz < PI_POS)
                begin
                    phase_2MHz <= phase_2MHz + PHASE_INC_2MHz;
                end
            else
                begin
                    phase_2MHz <= PI_NEG + (phase_2MHz + PHASE_INC_2MHz - PI_POS);
                end
                    
            // Sweep phase to synthesize 30MHz sine wave
            if (phase_30MHz + PHASE_INC_30MHz < PI_POS)
                begin
                    phase_30MHz <= phase_30MHz + PHASE_INC_30MHz;
                end
            else
                begin
                    phase_30MHz <= PI_NEG + (phase_30MHz + PHASE_INC_30MHz - PI_POS);
                end
                            
        end
        
        // Create 500MHz Cordic Block
        always begin
            cordic_clk = #(CORDIC_CLK_PERIOD/2) ~cordic_clk;
        end       
        
        // Create 100MHz FIR Clock
        always begin
            fir_clk = #(FIR_CLK_PERIOD/2) ~fir_clk;
        end   
        
        // Noisy Signal = 2MHz sine wave + 30MHz sine wave
        // Noisy signal is resampled at 100MHz FIR sampling rate
        always @(posedge fir_clk)
            begin
               noisy_signal <= (sin_2MHz + sin_30MHz)/2; 
            end
            
        // Feed noisy signal into FIR lowpass filter
        fir fir_inst(
            .clk             (fir_clk),
            .noisy_signal    (noisy_signal),
            .filtered_signal (filtered_signal)
        );
        
endmodule

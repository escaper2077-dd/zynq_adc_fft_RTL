//****************************************Copyright (c)***********************************//
// Dual ADC with FFT Processing Module
// Modified to add FFT IP Core for frequency domain analysis
//****************************************************************************************//

module hs_dual_ad(
    input                 sys_clk      ,   //System clock
    //AD0
    input     [9:0]       ad0_data     ,   //AD0 data
    input                 ad0_otr      ,   //Overrange flag
    output                ad0_clk      ,   //AD0 sampling clock
    output                ad0_oe       ,   //AD0 output enable
    //AD1
    input     [9:0]       ad1_data     ,   //AD1 data
    input                 ad1_otr      ,   //Overrange flag
    output                ad1_clk      ,   //AD1 sampling clock  
    output                ad1_oe       ,   //AD1 output enable
    //Debug output to prevent optimization
    output                fft_valid_out,
    output                fft_real_out,
    output                fft_imag_out
    );
     
//Wire definitions
wire clk_out1;
wire locked;

//FFT interface signals
wire [31:0] fft_s_axis_data_tdata;
wire        fft_s_axis_data_tvalid;
wire        fft_s_axis_data_tready;
wire        fft_s_axis_data_tlast;
wire [15:0] fft_s_axis_config_tdata;
wire        fft_s_axis_config_tvalid;
wire        fft_s_axis_config_tready;

wire [31:0] fft_m_axis_data_tdata;
wire        fft_m_axis_data_tvalid;
wire        fft_m_axis_data_tready;
wire        fft_m_axis_data_tlast;
wire        fft_event_frame_started;
wire        fft_event_tlast_unexpected;
wire        fft_event_tlast_missing;
wire        fft_event_status_channel_halt;
wire        fft_event_data_in_channel_halt;
wire        fft_event_data_out_channel_halt;

//Control signals
(* mark_debug = "true" *) reg  [9:0]  fft_sample_cnt;
(* mark_debug = "true" *) reg  [9:0]  ad0_data_reg;
(* mark_debug = "true" *) reg         data_valid;
reg         fft_start;
reg         fft_running;
(* dont_touch = "true", mark_debug = "true" *) reg  [15:0] fft_output_real_reg;
(* dont_touch = "true", mark_debug = "true" *) reg  [15:0] fft_output_imag_reg;

//Debug signals for ILA - FFT output is 32-bit (16 real + 16 imag)
(* dont_touch = "true", mark_debug = "true" *) wire        debug_fft_input_valid;
(* dont_touch = "true", mark_debug = "true" *) wire        debug_fft_input_ready;
(* dont_touch = "true", mark_debug = "true" *) wire [15:0] debug_fft_output_real;
(* dont_touch = "true", mark_debug = "true" *) wire [15:0] debug_fft_output_imag;
(* dont_touch = "true", mark_debug = "true" *) wire        debug_fft_output_valid;
(* dont_touch = "true", mark_debug = "true" *) wire        debug_fft_frame_start;

assign debug_fft_input_valid = fft_s_axis_data_tvalid;
assign debug_fft_input_ready = fft_s_axis_data_tready;
assign debug_fft_output_real = fft_output_real_reg;
assign debug_fft_output_imag = fft_output_imag_reg;
assign debug_fft_output_valid = fft_m_axis_data_tvalid;
assign debug_fft_frame_start = fft_event_frame_started;
 //*****************************************************
//*****************************************************
//**                    Main Code
//*****************************************************  
assign  ad0_oe =  1'b0;
assign  ad1_oe =  1'b0;
assign  fft_valid_out = fft_m_axis_data_tvalid;
assign  fft_real_out = |fft_output_real_reg;  // OR all bits to single output
assign  fft_imag_out = |fft_output_imag_reg;  // OR all bits to single output
assign  ad0_clk = ~clk_out1;
assign  ad1_clk = ~clk_out1;

//FFT input data: real part = ad0_data, imaginary part = 0
assign fft_s_axis_data_tdata = {6'd0, ad0_data_reg, 16'd0};
assign fft_s_axis_data_tvalid = data_valid;
assign fft_s_axis_data_tlast = (fft_sample_cnt == 10'd1023) ? 1'b1 : 1'b0;

//FFT config: forward transform
assign fft_s_axis_config_tdata = 16'h0001;  //FWD_INV=1 (forward FFT)
assign fft_s_axis_config_tvalid = fft_start;

//FFT output ready
assign fft_m_axis_data_tready = 1'b1;

//Sample ADC data and generate FFT input stream
always @(posedge clk_out1) begin
    if (!locked) begin
        fft_sample_cnt <= 10'd0;
        ad0_data_reg <= 10'd0;
        data_valid <= 1'b0;
        fft_start <= 1'b0;
        fft_output_real_reg <= 32'd0;
        fft_output_imag_reg <= 32'd0;
    end
    else begin
        ad0_data_reg <= ad0_data;
        
        // Capture FFT output - 32bit: [31:16]=imag, [15:0]=real
        if (fft_m_axis_data_tvalid) begin
            fft_output_real_reg <= fft_m_axis_data_tdata[15:0];
            fft_output_imag_reg <= fft_m_axis_data_tdata[31:16];
        end
        ad0_data_reg <= ad0_data;
        
        // Start FFT once
        if (!fft_running && fft_s_axis_config_tready) begin
            fft_start <= 1'b1;
            fft_running <= 1'b1;
        end
        else begin
            fft_start <= 1'b0;
        end
        
        // Send data when FFT is ready
        if (fft_s_axis_data_tready && fft_running) begin
            if (fft_sample_cnt < 10'd1024) begin
                data_valid <= 1'b1;
                fft_sample_cnt <= fft_sample_cnt + 1'b1;
            end
            else begin
                data_valid <= 1'b0;
                // Keep running to continuously process data
                if (fft_m_axis_data_tlast) begin
                    fft_sample_cnt <= 10'd0;
                end
            end
        end
        else if (!fft_running) begin
            data_valid <= 1'b0;
        end
    end
end

//Clock wizard instance
clk_wiz_0 u_clk_wiz_0 (
    .clk_out1(clk_out1),    // output clk_out1
    .reset(1'b0),           // input reset
    .locked(locked),        // output locked
    .clk_in1(sys_clk)       // input clk_in1
);

//FFT IP Core - matching actual IP ports
xfft_0 u_xfft_0 (
    .aclk(clk_out1),
    .aresetn(locked),
    .s_axis_config_tdata(fft_s_axis_config_tdata),
    .s_axis_config_tvalid(fft_s_axis_config_tvalid),
    .s_axis_config_tready(fft_s_axis_config_tready),
    .s_axis_data_tdata(fft_s_axis_data_tdata),
    .s_axis_data_tvalid(fft_s_axis_data_tvalid),
    .s_axis_data_tready(fft_s_axis_data_tready),
    .s_axis_data_tlast(fft_s_axis_data_tlast),
    .m_axis_data_tdata(fft_m_axis_data_tdata),
    .m_axis_data_tvalid(fft_m_axis_data_tvalid),
    .m_axis_data_tready(fft_m_axis_data_tready),
    .m_axis_data_tlast(fft_m_axis_data_tlast),
    .event_frame_started(fft_event_frame_started),
    .event_tlast_unexpected(fft_event_tlast_unexpected),
    .event_tlast_missing(fft_event_tlast_missing),
    .event_status_channel_halt(fft_event_status_channel_halt),
    .event_data_in_channel_halt(fft_event_data_in_channel_halt),
    .event_data_out_channel_halt(fft_event_data_out_channel_halt)
);

//ILA to monitor ADC and FFT signals - 8 probes configured
//probe4/5 now 16 bits to match actual FFT output
ila_0 u_ila_0 (
    .clk(clk_out1),
    .probe0(ad0_data),                      // [9:0]  ADC0 input
    .probe1(fft_sample_cnt),                // [9:0]  Sample counter
    .probe2(debug_fft_input_valid),         // [0:0]  FFT input valid
    .probe3(debug_fft_input_ready),         // [0:0]  FFT input ready
    .probe4(debug_fft_output_real),         // [15:0] FFT output real
    .probe5(debug_fft_output_imag),         // [15:0] FFT output imag
    .probe6(debug_fft_output_valid),        // [0:0]  FFT output valid
    .probe7(debug_fft_frame_start)          // [0:0]  FFT frame started
);

endmodule


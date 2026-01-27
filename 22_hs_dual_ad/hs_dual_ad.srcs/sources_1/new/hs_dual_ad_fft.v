//****************************************Copyright (c)***********************************//
// Dual ADC with FFT Processing Module
//****************************************************************************************//

module hs_dual_ad(
    input                 sys_clk      ,
    input     [9:0]       ad0_data     ,
    input                 ad0_otr      ,
    output                ad0_clk      ,
    output                ad0_oe       ,
    input     [9:0]       ad1_data     ,
    input                 ad1_otr      ,
    output                ad1_clk      ,
    output                ad1_oe       
    );
     
wire clk_out1;
wire locked;

// FFT interface signals - 32-bit data (16 real + 16 imag)
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

// Control signals
(* dont_touch = "true" *) reg  [9:0]  fft_sample_cnt;
(* dont_touch = "true" *) reg  [9:0]  ad0_data_reg;
(* dont_touch = "true" *) reg         data_valid;
reg         fft_start;
reg         fft_running;
(* dont_touch = "true" *) reg  [15:0] fft_output_real_reg;
(* dont_touch = "true" *) reg  [15:0] fft_output_imag_reg;

// Main assignments
assign ad0_oe  = 1'b0;
assign ad1_oe  = 1'b0;
assign ad0_clk = ~clk_out1;
assign ad1_clk = ~clk_out1;

// FFT input: real=ad0_data (in upper 16 bits), imag=0 (in lower 16 bits)
assign fft_s_axis_data_tdata  = {6'd0, ad0_data_reg, 16'd0};
assign fft_s_axis_data_tvalid = data_valid;
assign fft_s_axis_data_tlast  = (fft_sample_cnt == 10'd1023);

// FFT config
assign fft_s_axis_config_tdata  = 16'h0001;
assign fft_s_axis_config_tvalid = fft_start;

// FFT output ready
assign fft_m_axis_data_tready = 1'b1;

// Main state machine
always @(posedge clk_out1 or negedge locked) begin
    if (!locked) begin
        fft_sample_cnt     <= 10'd0;
        ad0_data_reg       <= 10'd0;
        data_valid         <= 1'b0;
        fft_start          <= 1'b0;
        fft_running        <= 1'b0;
        fft_output_real_reg <= 16'd0;
        fft_output_imag_reg <= 16'd0;
    end
    else begin
        ad0_data_reg <= ad0_data;
        
        // Capture FFT output
        if (fft_m_axis_data_tvalid) begin
            fft_output_real_reg <= fft_m_axis_data_tdata[15:0];
            fft_output_imag_reg <= fft_m_axis_data_tdata[31:16];
        end
        
        // Start FFT config
        if (!fft_running && fft_s_axis_config_tready) begin
            fft_start   <= 1'b1;
            fft_running <= 1'b1;
        end
        else begin
            fft_start <= 1'b0;
        end
        
        // Send data
        if (fft_running && fft_s_axis_data_tready) begin
            if (fft_sample_cnt < 10'd1024) begin
                data_valid     <= 1'b1;
                fft_sample_cnt <= fft_sample_cnt + 1'b1;
            end
            else begin
                data_valid <= 1'b0;
                if (fft_m_axis_data_tlast)
                    fft_sample_cnt <= 10'd0;
            end
        end
    end
end

// Clock Wizard
clk_wiz_0 u_clk_wiz_0 (
    .clk_out1 (clk_out1),
    .reset    (1'b0),
    .locked   (locked),
    .clk_in1  (sys_clk)
);

// FFT IP Core
xfft_0 u_xfft_0 (
    .aclk                       (clk_out1),
    .aresetn                    (locked),
    .s_axis_config_tdata        (fft_s_axis_config_tdata),
    .s_axis_config_tvalid       (fft_s_axis_config_tvalid),
    .s_axis_config_tready       (fft_s_axis_config_tready),
    .s_axis_data_tdata          (fft_s_axis_data_tdata),
    .s_axis_data_tvalid         (fft_s_axis_data_tvalid),
    .s_axis_data_tready         (fft_s_axis_data_tready),
    .s_axis_data_tlast          (fft_s_axis_data_tlast),
    .m_axis_data_tdata          (fft_m_axis_data_tdata),
    .m_axis_data_tvalid         (fft_m_axis_data_tvalid),
    .m_axis_data_tready         (fft_m_axis_data_tready),
    .m_axis_data_tlast          (fft_m_axis_data_tlast),
    .event_frame_started        (fft_event_frame_started),
    .event_tlast_unexpected     (fft_event_tlast_unexpected),
    .event_tlast_missing        (fft_event_tlast_missing),
    .event_status_channel_halt  (fft_event_status_channel_halt),
    .event_data_in_channel_halt (fft_event_data_in_channel_halt),
    .event_data_out_channel_halt(fft_event_data_out_channel_halt)
);

// ILA - 8 probes: 10,10,1,1,16,16,1,1
ila_0 u_ila_0 (
    .clk    (clk_out1),
    .probe0 (ad0_data),              // [9:0]
    .probe1 (fft_sample_cnt),        // [9:0]
    .probe2 (fft_s_axis_data_tvalid),// [0:0]
    .probe3 (fft_s_axis_data_tready),// [0:0]
    .probe4 (fft_output_real_reg),   // [15:0]
    .probe5 (fft_output_imag_reg),   // [15:0]
    .probe6 (fft_m_axis_data_tvalid),// [0:0]
    .probe7 (fft_event_frame_started)// [0:0]
);

endmodule

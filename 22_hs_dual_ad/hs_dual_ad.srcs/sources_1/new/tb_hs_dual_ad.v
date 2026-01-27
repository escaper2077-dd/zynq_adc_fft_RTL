`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
// Testbench for hs_dual_ad module
//****************************************************************************************//

module tb_hs_dual_ad();

    parameter CLK_PERIOD = 20;
    parameter SIM_TIME = 100000;
    
    reg                 sys_clk;
    reg     [9:0]       ad0_data;
    reg                 ad0_otr;
    reg     [9:0]       ad1_data;
    reg                 ad1_otr;
    wire                ad0_clk;
    wire                ad0_oe;
    wire                ad1_clk;
    wire                ad1_oe;
    
    integer sample_cnt;
    integer file_ad0;
    integer file_ad1;
    
    reg [9:0] sin_lut [0:99];
    reg [9:0] cos_lut [0:99];
    
    initial begin
        sys_clk = 1'b0;
    end
    
    always #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    
    hs_dual_ad u_hs_dual_ad(
        .sys_clk    (sys_clk    ),
        .ad0_data   (ad0_data   ),
        .ad0_otr    (ad0_otr    ),
        .ad0_clk    (ad0_clk    ),
        .ad0_oe     (ad0_oe     ),
        .ad1_data   (ad1_data   ),
        .ad1_otr    (ad1_otr    ),
        .ad1_clk    (ad1_clk    ),
        .ad1_oe     (ad1_oe     )
    );
    
    initial begin
        sin_lut[0] = 512; sin_lut[1] = 544; sin_lut[2] = 576; sin_lut[3] = 607; sin_lut[4] = 638;
        sin_lut[5] = 668; sin_lut[6] = 697; sin_lut[7] = 725; sin_lut[8] = 751; sin_lut[9] = 776;
        sin_lut[10] = 799; sin_lut[11] = 820; sin_lut[12] = 839; sin_lut[13] = 856; sin_lut[14] = 871;
        sin_lut[15] = 883; sin_lut[16] = 893; sin_lut[17] = 901; sin_lut[18] = 906; sin_lut[19] = 909;
        sin_lut[20] = 909; sin_lut[21] = 907; sin_lut[22] = 902; sin_lut[23] = 895; sin_lut[24] = 886;
        sin_lut[25] = 875; sin_lut[26] = 861; sin_lut[27] = 845; sin_lut[28] = 828; sin_lut[29] = 808;
        sin_lut[30] = 787; sin_lut[31] = 764; sin_lut[32] = 740; sin_lut[33] = 714; sin_lut[34] = 687;
        sin_lut[35] = 659; sin_lut[36] = 630; sin_lut[37] = 600; sin_lut[38] = 569; sin_lut[39] = 538;
        sin_lut[40] = 506; sin_lut[41] = 474; sin_lut[42] = 442; sin_lut[43] = 410; sin_lut[44] = 378;
        sin_lut[45] = 347; sin_lut[46] = 316; sin_lut[47] = 286; sin_lut[48] = 257; sin_lut[49] = 229;
        sin_lut[50] = 202; sin_lut[51] = 176; sin_lut[52] = 152; sin_lut[53] = 129; sin_lut[54] = 108;
        sin_lut[55] = 88; sin_lut[56] = 71; sin_lut[57] = 55; sin_lut[58] = 41; sin_lut[59] = 30;
        sin_lut[60] = 20; sin_lut[61] = 13; sin_lut[62] = 9; sin_lut[63] = 6; sin_lut[64] = 6;
        sin_lut[65] = 8; sin_lut[66] = 13; sin_lut[67] = 20; sin_lut[68] = 29; sin_lut[69] = 40;
        sin_lut[70] = 54; sin_lut[71] = 70; sin_lut[72] = 87; sin_lut[73] = 107; sin_lut[74] = 128;
        sin_lut[75] = 151; sin_lut[76] = 175; sin_lut[77] = 201; sin_lut[78] = 228; sin_lut[79] = 256;
        sin_lut[80] = 285; sin_lut[81] = 315; sin_lut[82] = 346; sin_lut[83] = 377; sin_lut[84] = 409;
        sin_lut[85] = 441; sin_lut[86] = 473; sin_lut[87] = 505; sin_lut[88] = 537; sin_lut[89] = 568;
        sin_lut[90] = 599; sin_lut[91] = 629; sin_lut[92] = 658; sin_lut[93] = 686; sin_lut[94] = 713;
        sin_lut[95] = 739; sin_lut[96] = 763; sin_lut[97] = 786; sin_lut[98] = 807; sin_lut[99] = 827;
        
        cos_lut[0] = 1023; cos_lut[1] = 1020; cos_lut[2] = 1015; cos_lut[3] = 1008; cos_lut[4] = 999;
        cos_lut[5] = 988; cos_lut[6] = 974; cos_lut[7] = 958; cos_lut[8] = 941; cos_lut[9] = 921;
        cos_lut[10] = 900; cos_lut[11] = 877; cos_lut[12] = 853; cos_lut[13] = 827; cos_lut[14] = 800;
        cos_lut[15] = 772; cos_lut[16] = 743; cos_lut[17] = 713; cos_lut[18] = 682; cos_lut[19] = 651;
        cos_lut[20] = 619; cos_lut[21] = 587; cos_lut[22] = 555; cos_lut[23] = 523; cos_lut[24] = 491;
        cos_lut[25] = 459; cos_lut[26] = 428; cos_lut[27] = 398; cos_lut[28] = 368; cos_lut[29] = 339;
        cos_lut[30] = 311; cos_lut[31] = 284; cos_lut[32] = 259; cos_lut[33] = 235; cos_lut[34] = 213;
        cos_lut[35] = 192; cos_lut[36] = 173; cos_lut[37] = 156; cos_lut[38] = 140; cos_lut[39] = 127;
        cos_lut[40] = 115; cos_lut[41] = 106; cos_lut[42] = 98; cos_lut[43] = 93; cos_lut[44] = 90;
        cos_lut[45] = 89; cos_lut[46] = 90; cos_lut[47] = 93; cos_lut[48] = 98; cos_lut[49] = 106;
        cos_lut[50] = 115; cos_lut[51] = 126; cos_lut[52] = 140; cos_lut[53] = 155; cos_lut[54] = 172;
        cos_lut[55] = 191; cos_lut[56] = 212; cos_lut[57] = 234; cos_lut[58] = 258; cos_lut[59] = 283;
        cos_lut[60] = 310; cos_lut[61] = 338; cos_lut[62] = 367; cos_lut[63] = 397; cos_lut[64] = 427;
        cos_lut[65] = 458; cos_lut[66] = 490; cos_lut[67] = 522; cos_lut[68] = 554; cos_lut[69] = 586;
        cos_lut[70] = 618; cos_lut[71] = 650; cos_lut[72] = 681; cos_lut[73] = 712; cos_lut[74] = 742;
        cos_lut[75] = 771; cos_lut[76] = 799; cos_lut[77] = 826; cos_lut[78] = 852; cos_lut[79] = 876;
        cos_lut[80] = 899; cos_lut[81] = 920; cos_lut[82] = 940; cos_lut[83] = 957; cos_lut[84] = 973;
        cos_lut[85] = 987; cos_lut[86] = 998; cos_lut[87] = 1007; cos_lut[88] = 1014; cos_lut[89] = 1019;
        cos_lut[90] = 1022; cos_lut[91] = 1022; cos_lut[92] = 1020; cos_lut[93] = 1016; cos_lut[94] = 1010;
        cos_lut[95] = 1001; cos_lut[96] = 991; cos_lut[97] = 978; cos_lut[98] = 964; cos_lut[99] = 947;
    end
    
    initial begin
        ad0_data = 10'd0;
        ad0_otr  = 1'b0;
        ad1_data = 10'd0;
        ad1_otr  = 1'b0;
        sample_cnt = 0;
        
        file_ad0 = $fopen("ad0_output.txt", "w");
        file_ad1 = $fopen("ad1_output.txt", "w");
        
        if (file_ad0 == 0 || file_ad1 == 0) begin
            $display("Error: Cannot open output files!");
            $finish;
        end
        
        $fdisplay(file_ad0, "# Time(ns)\tAD0_Data\tAD0_OTR");
        $fdisplay(file_ad1, "# Time(ns)\tAD1_Data\tAD1_OTR");
        
        #100;
        $display("==============================================");
        $display("Simulation started...");
        $display("==============================================");
    end
    
    always @(posedge ad0_clk) begin
        ad0_data <= sin_lut[sample_cnt % 100];
        if (ad0_data > 1020 || ad0_data < 3)
            ad0_otr <= 1'b1;
        else
            ad0_otr <= 1'b0;
    end
    
    always @(posedge ad1_clk) begin
        ad1_data <= cos_lut[sample_cnt % 100];
        if (ad1_data > 1020 || ad1_data < 3)
            ad1_otr <= 1'b1;
        else
            ad1_otr <= 1'b0;
        sample_cnt <= sample_cnt + 1;
    end
    
    always @(posedge ad0_clk) begin
        $fdisplay(file_ad0, "%t\t%d\t%b", $time, ad0_data, ad0_otr);
    end
    
    always @(posedge ad1_clk) begin
        $fdisplay(file_ad1, "%t\t%d\t%b", $time, ad1_data, ad1_otr);
    end
    
    initial begin
        forever begin
            #1000;
            $display("Time=%t ns | AD0=%d (OTR=%b) | AD1=%d (OTR=%b)", 
                     $time, ad0_data, ad0_otr, ad1_data, ad1_otr);
        end
    end
    
    initial begin
        $dumpfile("hs_dual_ad_wave.vcd");
        $dumpvars(0, tb_hs_dual_ad);
    end
    
    initial begin
        #SIM_TIME;
        $fclose(file_ad0);
        $fclose(file_ad1);
        $display("==============================================");
        $display("Simulation finished!");
        $display("AD0 data saved to: ad0_output.txt");
        $display("AD1 data saved to: ad1_output.txt");
        $display("Waveform saved to: hs_dual_ad_wave.vcd");
        $display("==============================================");
        $finish;
    end

endmodule

//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           hs_dual_ad
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        双路模数转换模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

 module hs_dual_ad(
     input                 sys_clk      ,   //系统时钟
     //AD0
     input     [9:0]       ad0_data     ,   //AD0数据
     input                 ad0_otr      ,   //输入电压超过量程标志
     output                ad0_clk      ,   //AD0采样时钟
     output                ad0_oe       ,   //AD0输出使能
     //AD1
     input     [9:0]       ad1_data     ,   //AD1数据
     input                 ad1_otr      ,   //输入电压超过量程标志
     output                ad1_clk      ,   //AD1采样时钟  
     output                ad1_oe           //AD1输出使能
     );
      
 //wire define
 wire clk_out1;
 wire clk_out2;
 //*****************************************************
 //**                    main code
 //*****************************************************  
 assign  ad0_oe =  1'b0;
 assign  ad1_oe =  1'b0;
 assign  ad0_clk = ~clk_out1;
 assign  ad1_clk = ~clk_out1;
 
 clk_wiz_0 u_clk_wiz_0
    (
     // Clock out ports
     .clk_out1(clk_out1),    // output clk_out1
     // Status and control signals
     .reset(1'b0), // input reset
     .locked(locked),        // output locked
    // Clock in ports
     .clk_in1(sys_clk));     // input clk_in1
     
 ila_0 u_ila_0 (
 	.clk(clk_out1),     // input wire clk
 	.probe0(ad1_otr),   // input wire [0:0]  probe0  
 	.probe1(ad0_data),  // input wire [9:0]  probe1
 	.probe2(ad0_otr),   // input wire [0:0]  probe0  
 	.probe3(ad1_data)   // input wire [9:0]  probe1
 );
 
 endmodule

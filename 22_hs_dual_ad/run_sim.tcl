# Vivado仿真TCL脚本
# 用法: vivado -mode batch -source run_sim.tcl

# 打开项目
open_project /home/escaper/FPGA_prj/adc_pl/22_hs_dual_ad/hs_dual_ad.xpr

# 设置顶层仿真模块
set_property top tb_hs_dual_ad [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# 更新编译顺序
update_compile_order -fileset sim_1

# 启动仿真
launch_simulation

# 运行完整仿真
run all

# 关闭仿真
close_sim

# 退出
exit

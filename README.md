# DE1-SoC-HPSFPGA

Im2col implemented in FPGA (VHDL) using Altera Quartus II. This code is implementing the im2col algorithm as provided in the commit #03a84bf464dd47bcec9ac943f0229a758c627f05 from the caffe (https://github.com/BVLC/caffe/blob/master/src/caffe/util/im2col.cpp).
The ip is named as caffe_accelerator which is located in the ip folder. This project creates the Qsys environment which integrates the mentioned ip to the hps subsystem in the DE1-SoC.

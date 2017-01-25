# LASERNET

by allanko [at] mit.edu and keam [at] mit.edu

Final project for MIT [6.111 Introductory Digital Systems Laboratory](http://web.mit.edu/6.111/www/f2016/), fall 2016.

LASERNET is a free-space optical (FSO) communication system implemented with FPGAs and off-the-shelf lasers. It robustly transmits data from one FPGA to another over a laser link by using a simplified version of Transmission Control Protocol (TCP).

This repository represents a full [Vivado](https://www.xilinx.com/products/design-tools/vivado/vivado-webpack.html) project file. This implementation runs on the [Nexys4 DDR](http://store.digilentinc.com/nexys-4-ddr-artix-7-fpga-trainer-board-recommended-for-ece-curriculum/) development board. If you just want the bitstream file for programming the FPGA, see [here](lasernet/lasernet.runs/impl_1/labkit.bit).

See a video demo of LASERNET in action [here](https://www.youtube.com/watch?v=AM9uxJAMKng&).

Our full project report for the class is in the `documentation` folder, [here](documentation/lasernet-final-report.pdf).

## Block diagram
![alt tag](documentation/block-diagram.png)

## State transition diagram
![alt tag](documentation/state-transition-diagram.png)

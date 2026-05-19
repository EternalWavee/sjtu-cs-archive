# 📚 SJTU-CS2306

![School](https://img.shields.io/badge/School-SJTU-blue)
![Course](https://img.shields.io/badge/Course-CS2306-orange)
![Semester](https://img.shields.io/badge/2026-Spring-brightgreen)
![Tool](https://img.shields.io/badge/Tool-Vivado-blue)
![Topic](https://img.shields.io/badge/Topic-Computer%20Architecture-yellow)

上海交通大学 **CS2306 计算机体系结构实验（2026 春季学期）** 课程资料。

基于 Xilinx Vivado 的 FPGA 实验，使用 Verilog 硬件描述语言。

## 实验内容

### Lab1 — 流水灯 (`CS2306Lab1/`)

> `flowing_light.v` — 核心模块

利用时钟分频器驱动 8 位 LED 循环左移，实现流水灯效果。时钟输入经 IBUFGDS 差分缓冲后驱动计数器，计满后 LED 移位寄存器左移一位，循环往复。

```
输入：clock_p/n (差分时钟), reset
输出：led[7:0]
```

### Lab2 — 4位加法器 (`CS2306Lab2/`)

> `Top.v` — 顶层模块，`adder_4bits.v` — 4位全加器

4位二进制加法器实验，计算 `a + b`，结果通过数码管/LED 显示。顶层模块包含时钟分频、 adder 实例和 display 驱动。

```
输入：clk_p/n (差分时钟), a[3:0], b[3:0], reset
输出：led_clk/en/do, seg_clk/en/do
```

---

`.gitignore` 已配置，排除所有 Vivado 构建产物（`.cache/`、`.runs/`、`.sim/`、`.hw/` 等），仅保留源码、约束文件和实验报告 PDF。
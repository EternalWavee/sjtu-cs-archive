# 📚 SJTU-CS2311

![School](https://img.shields.io/badge/School-SJTU-blue)
![Course](https://img.shields.io/badge/Course-CS2311-orange)
![Semester](https://img.shields.io/badge/2026-Spring-brightgreen)
![Language](https://img.shields.io/badge/Language-LaTeX-blue)
![Topic](https://img.shields.io/badge/Topic-Modern%20Operating%20Systems-yellow)

上海交通大学 **CS2311 现代操作系统（强化）（2026 春季学期）** 课程资料。

## 内容

### 📝 技术报告：KV Cache Memory Management in LLM Inference

> `CS2311Report/` — LaTeX 源码 + 编译产物

从操作系统内存管理视角分析大语言模型推理中的 KV Cache 管理问题。报告涵盖：

- **背景**：Transformer 注意力机制与 KV Cache 的作用、Prefill/Decode 两阶段特性
- **核心挑战**：内存碎片、动态序列长度、队头阻塞与批处理低效、长上下文内存压力
- **优化策略**：PagedAttention（类虚拟内存分页）、Prefix Sharing（类 Copy-on-Write）、Continuous Batching、KV Cache 量化压缩、CPU/NVMe 卸载
- **案例分析**：vLLM 与 SGLang 的系统设计对比
- **原创分析**：OS 类比深度探讨、Block Size 选择的碎片化模型、Prefix Caching 的适用场景、开放挑战（分布式、超长上下文、多模态、隐私隔离）

主要参考文献：Kwon et al. (vLLM, SOSP 2023)、Zheng et al. (SGLang, 2024)、Silberschatz (Operating System Concepts)

### 📖 操作系统笔记

> `操作系统笔记.pdf` — 课程学习笔记

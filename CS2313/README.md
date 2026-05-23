# 📚 SJTU-CS2313

![School](https://img.shields.io/badge/School-SJTU-blue)
![Course](https://img.shields.io/badge/Course-CS2313-orange)
![Semester](https://img.shields.io/badge/2026-Spring-brightgreen)
![Language](https://img.shields.io/badge/Language-C11-blue?style=flat-square&logo=c)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=flat-square&logo=linux)
![Build](https://img.shields.io/badge/Build-Make-green?style=flat-square&logo=gnu)

上海交通大学 **CS2313 操作系统课程设计（2026 春季学期）**。

## C Agent

> **项目地址：** https://github.com/EternalWavee/c-agent

一个轻量级的、基于终端的编程智能体，纯 C 实现。

### 核心特性

- **ReAct 推理循环** — 多轮工具调用，直到任务完成
- **4 个内置工具** — `bash`、`read_file`、`write_file`、`edit_file`
- **并发执行** — 只读工具通过 pthread 并发调度
- **上下文管理** — 自动卸载（大输出存盘）+ 摘要（LLM 压缩历史）
- **会话持久化** — 跨运行保存和恢复对话
- **沙箱安全** — 所有文件路径限制在工作目录内
- **危险命令过滤** — 执行前拦截高危 shell 命令

### 项目结构

```
agent/          — 核心对话循环（ReAct）+ LLM HTTP 客户端
context/        — 上下文预算引擎、卸载策略、摘要策略
tools/          — 工具注册表、并发/串行调度器、沙箱、bash/read/write/edit
ui/             — 终端渲染和事件分发
libs/cJSON/     — JSON 解析库
```

### 技术亮点

| 模块 | 说明 |
|------|------|
| 上下文管理 | 卸载（无损存盘）+ 摘要（有损压缩）双策略，token 预算自动触发 |
| 工具调度 | 只读工具 pthread 并发，写工具串行，ReAct 循环协调 |
| 沙箱隔离 | realpath 解析 + chdir 限制，所有操作限制在工作目录内 |
| 会话持久化 | JSON 格式保存对话历史，支持跨会话恢复 |

详见完整项目 README：https://github.com/EternalWavee/c-agent
[English](README.en.md) | 中文

# everything-search

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.voidtools.com/)

基于 [Everything](https://www.voidtools.com/) 搜索引擎的 Windows 本地文件快速搜索工具。

这是一个 **Claude Code Skill** —— 指导 Claude 通过 `es.exe`（Everything 命令行接口）搜索文件，并将结果直接呈现在对话中。支持自动预检验证、多关键词模糊匹配、结果排序与导出。

## 目录

- [everything-search](#everything-search)
  - [目录](#目录)
  - [环境要求](#环境要求)
  - [安装](#安装)
    - [自动化安装](#自动化安装)
    - [手动安装 es.exe](#手动安装-esexe)
  - [快速使用](#快速使用)
  - [搜索示例](#搜索示例)
  - [故障排查](#故障排查)
  - [文件说明](#文件说明)
  - [参考链接](#参考链接)
  - [许可](#许可)

## 环境要求

| 依赖 | 说明 |
|------|------|
| **Windows 操作系统** | Everything 仅支持 Windows |
| **Everything** | 从 [voidtools.com](https://www.voidtools.com/downloads/) 安装 |
| **es.exe** | Everything 命令行工具，需**单独下载**。Skill 可在缺失时自动下载 |
| **Claude Code** | 运行于 Windows 环境，具备 PowerShell 访问权限 |

## 安装

### 自动化安装

Skill 在首次使用时会自动检测环境并下载 `es.exe`，无需手动操作。

### 手动安装 es.exe

如需手动安装而非依赖自动下载：

```powershell
# 下载到 Everything 目录
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:ProgramFiles\Everything\es.exe"

# 或下载到自定义路径
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:USERPROFILE\Tools\es.exe"

# 验证安装
es -version
```

或使用项目自带的安装脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-es.ps1

# 如需添加到 PATH
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-es.ps1 -AddToPath
```

## 快速使用

安装 Everything 后，直接向 Claude 提问即可：

> "找到我的预算表"
> "搜索 Downloads 里所有 PDF 文件"
> "找上周的大视频文件"

Skill 会自动触发，Claude 将：
1. 验证运行环境（Everything + es.exe）
2. 执行合适的 `es.exe` 命令
3. 返回包含文件路径、大小、日期的结果

## 搜索示例

```powershell
# 按文件名
es "budget.xlsx"
es *report*
es *.pdf

# 按路径
es -path "D:\Downloads" *.exe

# 含元数据
es -size -date-modified *.zip

# 排序
es -sort size -n 20
es -sort date-modified -n 50

# 模糊匹配（Claude 自动尝试多种模式）
# "找我的预算文件" → es *budget*, es *budget*.xlsx 等
```

## 故障排查

| 问题 | 可能原因 | 解决方法 |
|------|---------|---------|
| "es.exe command not found" | es.exe 未安装 | Skill 会自动下载，也可从 voidtools.com 手动下载 |
| "Everything IPC window not found" | Everything 未运行 | Skill 会自动启动 Everything |
| 无搜索结果 | 非 NTFS 分区索引未完成 | 在 Everything GUI 中检查索引状态 |
| 权限被拒绝 | 受保护文件夹 | 以管理员身份运行 PowerShell |

## 文件说明

| 文件 | 用途 |
|------|------|
| `SKILL.md` | Skill 核心指令集（预检验证、搜索命令、错误处理） |
| `scripts/validate.ps1` | 环境验证脚本（检测 Everything、启动服务、下载 es.exe） |
| `scripts/install-es.ps1` | es.exe 独立安装脚本 |
| `references/search-commands.md` | es.exe CLI 完整参考（排序、列、导出、搜索模式） |
| `references/indexing.md` | NTFS 与非 NTFS 文件系统的索引行为说明 |

## 参考链接

- [下载 Everything](https://www.voidtools.com/downloads/)
- [下载 es.exe](https://www.voidtools.com/es.exe)
- [Everything 文档](https://www.voidtools.com/support/everything/)

## 许可

本项目基于 [MIT License](LICENSE) 发布。

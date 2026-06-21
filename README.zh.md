# skill-everything-search

基于 [Everything](https://www.voidtools.com/) 搜索引擎的 Windows 本地文件极速搜索工具。

这是一个 **Claude Code Skill**（技能指令集），指导 Claude 通过 `es.exe`（Everything 的命令行工具）搜索文件，并将结果直接返回在聊天中。

## 前置要求

| 条件 | 说明 |
|------|------|
| **Windows 系统** | Everything 仅支持 Windows |
| **Everything** | 从 [voidtools.com](https://www.voidtools.com/downloads/) 安装 |
| **es.exe** | **独立下载**，不随 Everything 一起安装。本 skill 会在缺失时自动下载 |
| **Claude Code** | 在 Windows 环境下运行，具备 PowerShell 访问权限 |

## 快速上手

安装好 Everything 后，直接告诉 Claude 要找什么：

> "帮我找预算表格"
> "搜索 Downloads 下所有 PDF 文件"
> "找上周的大视频文件"

技能会自动触发。Claude 会：
1. 验证运行环境（Everything + es.exe）
2. 执行对应的 `es.exe` 搜索命令
3. 返回文件路径、大小、日期等结果

## 搜索示例

```powershell
# 按文件名
es "budget.xlsx"
es *report*
es *.pdf

# 按路径
es -path "D:\Downloads" *.exe

# 显示元数据
es -size -date-modified *.zip

# 排序结果
es -sort size -n 20
es -sort date-modified -n 50

# 模糊搜索（Claude 自动尝试多种模式）
# "找预算文件" → es *budget*, es *budget*.xlsx, 等
```

## 手动安装 es.exe

如果不想依赖自动下载，也可以手动安装：

```powershell
# 下载到 Everything 目录
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:ProgramFiles\Everything\es.exe"

# 或下载到 PATH 目录
Invoke-WebRequest -Uri "https://www.voidtools.com/es.exe" -OutFile "$env:USERPROFILE\Tools\es.exe"

# 验证安装
es -version
```

## 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| "es.exe command not found" | es.exe 未安装 | 技能会自动下载，或手动从 voidtools.com 下载 |
| "Everything IPC window not found" | Everything 未运行 | 技能会自动启动 |
| 搜索无结果 | 索引未完成（非 NTFS 卷） | 在 Everything GUI 中查看索引状态 |
| 权限拒绝 | 系统保护文件夹 | 以管理员身份运行 PowerShell |

## 文件结构

| 文件 | 用途 |
|------|------|
| `SKILL.md` | 技能主指令集（前置验证、搜索命令、错误处理） |
| `references/es-download.md` | es.exe 详细安装指南 |
| `references/search-syntax.md` | Everything 完整搜索语法参考 |

## 相关链接

- [下载 Everything](https://www.voidtools.com/downloads/)
- [下载 es.exe](https://www.voidtools.com/es.exe)
- [Everything 官方文档](https://www.voidtools.com/support/everything/)

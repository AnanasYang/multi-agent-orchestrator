# Multi-Agent Orchestrator

一个用于 OpenClaw 的 Skill，自动将复杂任务分解为并行子任务，协调多个子代理执行。

## 简介

**multi-agent-orchestrator** 帮助你将大型复杂任务智能分解为多个独立的子任务，启动并行 Workers 同时执行，并自动协调依赖关系、监控进度、整合交付物。

适用于：
- 🏗️ 大型系统架构设计
- 📚 多章节文档编写
- 🔧 多模块软件开发
- 📊 数据分析流程优化
- 🎨 批量UI组件设计

## 快速开始

```bash
# 安装 Skill
openclaw skill install multi-agent-orchestrator

# 或使用 git 克隆
git clone https://github.com/AnanasYang/multi-agent-orchestrator.git \
  ~/.openclaw/skills/multi-agent-orchestrator
```

## 使用方法

### 快速启动

```
/mao 开发一个电商网站，包含用户系统、商品系统、订单系统、支付系统
```

### 分步控制

```
/mao analyze "开发电商网站"       # 分析可分解性
/mao decompose --modules 4        # 分解为4个模块
/mao launch                       # 启动 Workers
/mao status                       # 查看状态
/mao finalize                     # 整合交付物
```

## 特性

- 🤖 **智能分解**：自动分析任务可分解性，推荐最优模块划分
- ⚡ **并行执行**：多个 Worker 同时工作，大幅缩短总时间
- 🔗 **依赖协调**：自动识别模块间依赖，合理安排执行顺序
- 📊 **实时监控**：可视化进度看板，及时识别阻塞
- 🎯 **自动整合**：完成后自动合并各模块交付物

## 工作原理

```
┌─────────────────────────────────────────────────────────────┐
│                     Manager (Orchestrator)                  │
├─────────────────────────────────────────────────────────────┤
│  1. 任务分析 → 2. 分解设计 → 3. 启动Workers → 4. 监控整合   │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Worker 1    │   │   Worker 2    │   │   Worker N    │
│   (Module 1)  │   │   (Module 2)  │   │   (Module N)  │
└───────────────┘   └───────────────┘   └───────────────┘
```

## 示例

### 软件开发

```
User: /mao 开发一个博客系统，包含文章管理、用户系统、评论系统、标签系统

AI: 【分析结果】适合4模块并行开发
    【建议分解】
    ├─ Module 1: 用户系统 (认证/注册/个人中心)
    ├─ Module 2: 文章系统 (发布/编辑/分类)
    ├─ Module 3: 评论系统 (发布/审核/通知)
    └─ Module 4: 标签系统 (创建/关联/搜索)
    
    【执行策略】
    Phase 1: 用户系统 + 标签系统 (并行)
    Phase 2: 文章系统 (等待用户)
    Phase 3: 评论系统 (等待文章)
    
    确认启动？ [启动]
```

更多示例见 [examples/](examples/) 目录。

## 目录结构

```
multi-agent-orchestrator/
├── SKILL.md                    # Skill 定义
├── README.md                   # 本文件
├── scripts/                    # 执行脚本
│   ├── analyze-task.sh         # 任务可分解性分析
│   ├── decompose.sh            # 任务分解器
│   ├── create-workers.sh       # 创建并启动 Workers
│   ├── monitor.sh              # 监控状态文件
│   └── finalize.sh             # 整合交付物
├── templates/                  # 模板文件
│   ├── state-file.json         # 状态文件模板
│   └── worker-prompt.md        # Worker 提示词模板
├── config/                     # 配置文件
│   └── default.yaml            # 默认规则配置
└── examples/                   # 使用示例
    ├── software-development.md
    ├── document-writing.md
    └── data-analysis.md
```

## 配置

编辑 `~/.openclaw/skills/multi-agent-orchestrator/config/default.yaml`：

```yaml
decomposition:
  strategy: hybrid           # parallel | sequential | hybrid
  max_workers: 10
  min_module_size: 30min
  
monitoring:
  check_interval: 10min
  alert_on_block: true
```

## 最佳实践

1. **任务规模**：每个 Worker 应有 30 分钟-2 小时的工作量
2. **Worker 数量**：建议控制在 5-10 个
3. **依赖分析**：启动前明确模块间依赖关系
4. **状态更新**：定期更新进度，遇到阻塞立即标记

## 文档

- [SKILL.md](SKILL.md) - 详细的 Skill 使用文档
- [examples/](examples/) - 使用示例

## 贡献

欢迎提交 Issue 和 PR！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可

[MIT](LICENSE)

## 致谢

- 灵感来源于 AutoGen 的多代理模式和 MetaGPT 的 SOP 思想
- 从 Memory System 2.0 项目实践中提炼优化

---

Made with ❤️ by [AnanasYang](https://github.com/AnanasYang)

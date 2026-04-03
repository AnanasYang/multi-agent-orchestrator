# multi-agent-orchestrator

## Description

自动将复杂任务分解为并行子任务，协调多个子代理执行。适用于大型项目开发、多模块系统设计、批量文档编写等场景。

核心能力：
- 智能任务分解：自动分析任务可分解性，推荐最优模块划分
- 并行执行：启动多个 Worker 同时处理独立模块
- 依赖协调：自动识别模块间依赖，合理安排执行顺序
- 状态监控：实时监控各 Worker 进度，及时识别阻塞
- 自动整合：完成后自动整合各模块交付物

## Usage

### 快速启动

```
/mao <任务描述>
```

### 分步控制

```
/mao analyze "<任务>"              # 分析可分解性
/mao decompose --modules 4         # 分解为4个模块
/mao launch                        # 启动 Workers
/mao status                        # 查看实时状态
/mao pause <worker-id>             # 暂停指定 Worker
/mao resume <worker-id>            # 恢复指定 Worker
/mao finalize                      # 整合交付物
```

### 配置选项

```
/mao config max-workers 10         # 最大 Worker 数
/mao config check-interval 10min   # 状态检查间隔
/mao config auto-finalize true     # 自动整合
```

## Installation

```bash
# 方式1: 通过 OpenClaw 安装
openclaw skill install multi-agent-orchestrator

# 方式2: 手动安装
git clone https://github.com/AnanasYang/multi-agent-orchestrator.git \
  ~/.openclaw/skills/multi-agent-orchestrator
```

## Examples

### Example 1: 软件开发

```
User: /mao 开发一个博客系统，包含文章管理、用户系统、评论系统、标签系统

AI: 【分析结果】适合4模块并行开发
    【建议分解】
    ├─ Module 1: 用户系统 (认证/注册/个人中心)
    ├─ Module 2: 文章系统 (发布/编辑/分类)
    ├─ Module 3: 评论系统 (发布/审核/通知)
    └─ Module 4: 标签系统 (创建/关联/搜索)
    
    【依赖关系】
    用户 → 文章 → 评论
    标签 → 文章
    
    【执行策略】
    Phase 1: 用户系统 + 标签系统 (并行)
    Phase 2: 文章系统 (等待用户)
    Phase 3: 评论系统 (等待文章)
    
    确认启动？ [启动] [调整] [取消]

User: 启动

AI: ✅ 已启动 4 个 Worker
    
    📁 项目目录: projects/blog-system-2026-04-03/
    📊 状态看板: projects/blog-system-2026-04-03/status.md
    
    【实时状态】
    Module 1 (用户系统): 🟡 运行中 - 45%
    Module 2 (文章系统): ⏳ 等待依赖
    Module 3 (评论系统): ⏳ 等待依赖
    Module 4 (标签系统): 🟡 运行中 - 60%
```

### Example 2: 文档编写

```
User: /mao 写一份年度报告，包含市场分析、产品回顾、财务总结、未来规划

AI: 【分析结果】适合4章节并行编写
    【建议分解】
    ├─ Writer 1: 市场分析章节
    ├─ Writer 2: 产品回顾章节
    ├─ Writer 3: 财务总结章节
    └─ Writer 4: 未来规划章节
    
    【整合策略】统一文风后合并为完整报告
    
    确认启动？ [启动]

User: 启动

AI: 🚀 4 Writers 已启动
    📄 预计输出: projects/annual-report-2026/
```

### Example 3: 数据分析优化

```
User: /mao 优化我们的数据分析流程

AI: 【分析结果】适合4方向并行优化
    【建议分解】
    ├─ Optimizer 1: 查询优化 (SQL/索引)
    ├─ Optimizer 2: 缓存策略 (Redis/Memcached)
    ├─ Optimizer 3: 并行计算 (多线程/分布式)
    └─ Optimizer 4: 存储优化 (分区/压缩)
    
    【执行策略】4个方向完全独立，全并行执行
    
    确认启动？ [启动] [调整]

User: 启动

AI: ✅ 4 Optimizers 已启动
```

## How It Works

### 架构图

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
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
                    ┌─────────────────┐
                    │   状态文件同步   │
                    │   (JSON/Markdown)│
                    └─────────────────┘
```

### 执行流程

1. **Phase 1: 任务分析**
   - 评估任务可分解性（1-10分）
   - 识别核心模块和边界
   - 分析模块间依赖关系

2. **Phase 2: 分解设计**
   - 确定 Worker 数量和职责
   - 设计模块接口和交付物格式
   - 制定执行策略（并行/串行/混合）

3. **Phase 3: 启动执行**
   - 创建项目目录结构
   - 生成 Worker 提示词和状态文件模板
   - 并行启动所有 Worker

4. **Phase 4: 监控协调**
   - 定期检查状态文件
   - 识别进度偏差和阻塞
   - 协调依赖关系

5. **Phase 5: 整合交付**
   - 验证各模块交付物完整性
   - 按设计整合为最终成果
   - 生成项目总结报告

## Configuration

### 默认配置

```yaml
# config/default.yaml
decomposition:
  strategy: hybrid           # parallel | sequential | hybrid
  max_workers: 10
  min_module_size: 30min     # 每个模块最少30分钟工作量
  
dependency:
  auto_detect: true
  strict_mode: false         # false=允许弱依赖并行
  
monitoring:
  check_interval: 10min
  alert_on_block: true
  auto_escalate: 15min       # 阻塞15分钟后上报

output:
  format: markdown
  consolidate: true          # 自动整合
  preserve_individual: true  # 保留各Worker输出
```

### 自定义配置

```bash
# 创建自定义配置
cp config/default.yaml ~/.openclaw/skills/multi-agent-orchestrator/config/my-config.yaml

# 编辑配置
vim ~/.openclaw/skills/multi-agent-orchestrator/config/my-config.yaml

# 使用自定义配置
/mao config use my-config
```

## Best Practices

### 何时使用此模式

| ✅ 适合场景 | ❌ 不适合场景 |
|-----------|-------------|
| 任务可分解为5-10个独立模块 | 强依赖顺序的串行任务 |
| 各模块边界清晰、接口明确 | 需要频繁实时协作的任务 |
| 需要并行加速开发 | 单一简单任务（直接执行即可） |
| 团队成员需要独立工作空间 | 需要高频同步决策的任务 |

### Worker 数量建议

- **简单任务** (2-3 模块): 3-5 Workers
- **中等任务** (4-7 模块): 5-8 Workers
- **复杂任务** (8+ 模块): 8-12 Workers，分 Phase 执行

### 常见陷阱

1. **❌ 任务分解过细**：将任务分解为 20+ 个微型任务
   - ✅ **解决**：每个 Worker 应有 30 分钟-2 小时的工作量

2. **❌ 忽视依赖分析**：并行启动有强依赖的任务
   - ✅ **解决**：启动前绘制依赖图，强依赖任务串行

3. **❌ 状态更新不及时**：Worker 执行 1 小时后才更新状态
   - ✅ **解决**：设定更新频率（每 15 分钟或关键节点）

4. **❌ 阻塞不报告**：Worker 遇到阻塞默默等待
   - ✅ **解决**：明确约定：遇到阻塞立即标记

## Directory Structure

```
multi-agent-orchestrator/
├── SKILL.md                    # 技能定义（本文件）
├── scripts/
│   ├── analyze-task.sh         # 任务可分解性分析
│   ├── decompose.sh            # 任务分解器
│   ├── create-workers.sh       # 创建并启动 Workers
│   ├── monitor.sh              # 监控状态文件
│   ├── resolve-dependencies.sh # 依赖解析器
│   └── finalize.sh             # 整合交付物
├── templates/
│   ├── state-file.json         # 状态文件模板
│   ├── worker-prompt.md        # Worker 提示词模板
│   └── project-structure.md    # 项目结构模板
├── config/
│   └── default.yaml            # 默认规则配置
└── examples/
    ├── software-development.md # 软件开发示例
    ├── document-writing.md     # 文档编写示例
    └── data-analysis.md        # 数据分析示例
```

## API Reference

### Manager Commands

| 命令 | 描述 | 示例 |
|------|------|------|
| `/mao` | 激活 Skill | `/mao` |
| `/mao analyze` | 分析任务 | `/mao analyze "开发电商网站"` |
| `/mao decompose` | 分解任务 | `/mao decompose --modules 4` |
| `/mao launch` | 启动 Workers | `/mao launch` |
| `/mao status` | 查看状态 | `/mao status` |
| `/mao pause` | 暂停 Worker | `/mao pause worker-1` |
| `/mao resume` | 恢复 Worker | `/mao resume worker-1` |
| `/mao finalize` | 整合交付物 | `/mao finalize` |
| `/mao config` | 配置选项 | `/mao config max-workers 10` |

### State File Format

```json
{
  "phase": 1,
  "name": "模块名称",
  "status": "pending|running|waiting|completed|failed",
  "subagent_id": "uuid",
  "start_time": "2026-04-03T09:00:00+08:00",
  "last_update": "2026-04-03T09:30:00+08:00",
  "elapsed_minutes": 30,
  "progress_percent": 60,
  "blockers": [
    {
      "type": "dependency|resource|technical",
      "description": "阻塞描述",
      "blocking_on": "worker-name"
    }
  ],
  "deliverables": ["交付物1", "交付物2"],
  "completed_deliverables": ["已完成1"],
  "estimated_completion": "2026-04-03T10:00:00+08:00",
  "notes": "其他备注"
}
```

## Troubleshooting

### Worker 长时间无响应

```
/mao status
# 查看是否有 worker 标记为 blocked

/mao check worker-1
# 强制检查特定 worker 状态
```

### 依赖死锁

```
/mao analyze-dependencies
# 重新分析依赖关系

/mao resolve
# 尝试自动解决冲突
```

### 交付物格式不一致

```
/mao validate
# 验证各模块交付物格式

/mao normalize
# 标准化格式后整合
```

## Contributing

欢迎提交 Issue 和 PR！

### 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## License

MIT License - 详见 [LICENSE](LICENSE) 文件

## Acknowledgments

- 灵感来源于 AutoGen 的多代理模式和 MetaGPT 的 SOP 思想
- 从 Memory System 2.0 项目实践中提炼优化

---

**Made with ❤️ by [AnanasYang](https://github.com/AnanasYang)**

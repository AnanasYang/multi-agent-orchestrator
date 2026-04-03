# multi-agent-orchestrator

## Description

自动将复杂任务分解为并行子任务，协调多个子代理执行。适用于大型项目开发、多模块系统设计、批量文档编写等场景。

核心能力：
- **智能任务分解**：自动分析任务可分解性，推荐最优模块划分
- **并行执行**：启动多个 Worker 同时处理独立模块
- **依赖协调**：自动识别模块间依赖，合理安排执行顺序
- **状态监控**：实时监控各 Worker 进度，及时识别阻塞
- **自动整合**：完成后自动整合各模块交付物
- **增量任务**：基于当前上下文或历史记忆继续未完成的任务

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
/mao launch --incremental          # 增量任务模式（基于当前上下文）
/mao launch --resume               # 恢复历史任务
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

### Example 3: 增量任务模式

```
User: 我们之前讨论过要优化数据库查询性能，现在我想继续那个工作

AI: 检测到历史会话上下文，建议使用增量任务模式。

User: /mao launch --incremental

AI: 📝 增量任务模式已启动
    
    【上下文分析】
    基于当前会话提取到以下关键决策点：
    - 需要优化慢查询日志中的 TOP 10 查询
    - 已确定使用索引优化为主，缓存策略为辅
    - 目标是将平均查询时间降低 50%
    
    【建议增量任务】
    ├─ Incremental-1: 上下文整理 (分析讨论记录，提取行动项)
    ├─ Incremental-2: 索引优化方案 (针对 TOP 10 查询设计索引)
    ├─ Incremental-3: 缓存策略设计 (Redis 缓存层架构)
    └─ Incremental-4: 实施计划制定 (分阶段实施路线图)
    
    确认启动增量 Workers？ [启动] [调整]

User: 启动

AI: ✅ 已启动 4 个增量 Workers
    📁 项目目录: projects/db-optimization-inc-2026-04-03/
    🧠 上下文来源: 当前会话分析
```

### Example 4: 恢复历史任务

```
User: 查看我之前暂停的博客系统开发任务

AI: 发现历史项目：blog-system-2026-04-02
    状态：2个 Worker 已完成，2个 Worker 暂停中

User: /mao launch --resume blog-system-2026-04-02

AI: 🔄 恢复任务模式已启动
    
    【历史状态恢复】
    ├─ Worker-01 (用户系统): ✅ 已完成
    ├─ Worker-02 (标签系统): ✅ 已完成
    ├─ Worker-03 (文章系统): ⏸️ 已暂停 (75% 完成)
    └─ Worker-04 (评论系统): ⏸️ 已暂停 (30% 完成)
    
    【恢复策略】
    - Worker-03: 继续完成剩余 25% (文章草稿功能)
    - Worker-04: 继续完成剩余 70% (评论通知功能)
    
    确认恢复执行？ [恢复]

User: 恢复

AI: ✅ 已恢复 2 个 Workers
    📁 项目目录: projects/blog-system-2026-04-02/
    🧠 记忆来源: ai-memory-system/L1-episodic/
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
   - 并行启动所有 Workers

4. **Phase 4: 监控协调**
   - 定期检查状态文件
   - 识别进度偏差和阻塞
   - 协调依赖关系

5. **Phase 5: 整合交付**
   - 验证各模块交付物完整性
   - 按设计整合为最终成果
   - 生成项目总结报告

### 增量任务模式

增量任务模式 (`--incremental`) 允许基于当前会话上下文创建 Workers：

```
当前会话上下文
       │
       ▼
┌─────────────────┐
│ 上下文分析器     │  ← 提取关键决策点、行动项、未完成工作
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 增量任务生成器   │  ← 基于上下文生成针对性任务
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 启动增量 Workers │  ← 每个 Worker 携带上下文信息
└─────────────────┘
```

### 恢复任务模式

恢复任务模式 (`--resume`) 允许从历史记忆或状态文件恢复未完成的任务：

```
历史状态文件 / ai-memory-system
              │
              ▼
┌─────────────────┐
│  任务状态扫描    │  ← 查找暂停/失败的任务
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  上下文恢复     │  ← 读取相关记忆和已完成工作
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  恢复 Workers   │  ← 继续执行未完成的任务
└─────────────────┘
```

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

incremental:
  context_depth: 3           # 分析最近3轮对话
  memory_source:             # 记忆来源优先级
    - session_context
    - ai_memory_system/L1
    - ai_memory_system/L2
  
resume:
  max_age_days: 7            # 最多恢复7天内的任务
  include_completed: false   # 不包含已完成的 Workers
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
| **增量模式**：有历史上下文需要继续 | 完全独立的全新任务 |
| **恢复模式**：之前有未完成的任务 | 任务已明确结束 |

### Worker 数量建议

- **简单任务** (2-3 模块): 3-5 Workers
- **中等任务** (4-7 模块): 5-8 Workers
- **复杂任务** (8+ 模块): 8-12 Workers，分 Phase 执行
- **增量任务**: 通常 2-4 Workers，专注于特定上下文
- **恢复任务**: 只恢复未完成的 Workers

### 模式选择指南

| 场景 | 推荐模式 | 命令 |
|------|----------|------|
| 全新任务 | 标准模式 | `/mao 任务描述` |
| 基于当前会话继续 | 增量模式 | `/mao launch --incremental` |
| 恢复之前的项目 | 恢复模式 | `/mao launch --resume <project-id>` |
| 明确指定模块数 | 分解模式 | `/mao decompose --modules 4` |

### 常见陷阱

1. **❌ 任务分解过细**：将任务分解为 20+ 个微型任务
   - ✅ **解决**：每个 Worker 应有 30 分钟-2 小时的工作量

2. **❌ 忽视依赖分析**：并行启动有强依赖的任务
   - ✅ **解决**：启动前绘制依赖图，强依赖任务串行

3. **❌ 状态更新不及时**：Worker 执行 1 小时后才更新状态
   - ✅ **解决**：设定更新频率（每 15 分钟或关键节点）

4. **❌ 阻塞不报告**：Worker 遇到阻塞默默等待
   - ✅ **解决**：明确约定：遇到阻塞立即标记

5. **❌ 增量模式滥用**：每次都用增量模式，导致上下文混乱
   - ✅ **解决**：全新任务用标准模式，真有上下文才用增量

6. **❌ 恢复过时任务**：恢复一周前的任务，上下文已丢失
   - ✅ **解决**：及时完成任务，恢复时检查记忆完整性

## Directory Structure

```
multi-agent-orchestrator/
├── SKILL.md                    # 技能定义（本文件）
├── README.md                   # 项目说明
├── LICENSE                     # 许可证
├── scripts/
│   ├── analyze-task.sh         # 任务可分解性分析
│   ├── decompose.sh            # 任务分解器
│   ├── create-workers.sh       # 创建并启动 Workers
│   ├── launch-workers.js       # Worker 启动器（支持增量/恢复模式）
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
    ├── data-analysis.md        # 数据分析示例
    └── incremental-task.md     # 增量任务示例
```

## API Reference

### Manager Commands

| 命令 | 描述 | 示例 |
|------|------|------|
| `/mao` | 激活 Skill | `/mao` |
| `/mao analyze` | 分析任务 | `/mao analyze "开发电商网站"` |
| `/mao decompose` | 分解任务 | `/mao decompose --modules 4` |
| `/mao launch` | 启动 Workers | `/mao launch` |
| `/mao launch --incremental` | 增量任务模式 | `/mao launch --incremental` |
| `/mao launch --resume` | 恢复历史任务 | `/mao launch --resume project-id` |
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
  "status": "pending|running|waiting|completed|failed|paused",
  "mode": "new|incremental|resume",
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
  "context_source": "session|memory|manual",
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

### 增量模式上下文不足

```
/mao launch --incremental --context-depth 5
# 增加上下文分析深度

/mao analyze-context
# 手动分析当前上下文
```

### 恢复任务找不到历史记录

```
/mao list-projects
# 列出可恢复的项目

/mao launch --resume --max-age 14
# 扩大搜索时间范围
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

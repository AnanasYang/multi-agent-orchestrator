# 增量任务示例

本示例展示如何使用增量任务模式基于当前会话上下文继续工作。

## 场景

你和 AI 已经讨论了一段时间的数据库优化方案，现在想将这些讨论转化为具体的实施任务。

## 会话历史（示例）

```
User: 我们的应用查询性能有问题，怎么优化？

AI: 建议从以下几个方面入手：
1. 分析慢查询日志，找出 TOP 10 慢查询
2. 为高频查询添加合适的索引
3. 引入 Redis 缓存层
4. 优化数据模型设计

User: 慢查询日志在哪里看？

AI: 可以通过以下命令查看...
[详细解释慢查询日志]

User: 我们决定对 TOP 10 慢查询进行索引优化，同时设计 Redis 缓存架构。

AI: 好的，这是一个很好的优化方向。建议：
1. 先索引优化（影响面小，见效快）
2. 后缓存层设计（架构改动大）
```

## 启动增量任务

```
User: /mao launch --incremental

AI: 📝 增量任务模式已启动
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    【上下文分析】
    基于当前会话提取到以下关键决策点：
    ┌─────────────────────────────────────────────────┐
    │ 决策点1: 优化目标                                 │
    │   → 解决查询性能问题                              │
    │   → 聚焦 TOP 10 慢查询                           │
    ├─────────────────────────────────────────────────┤
    │ 决策点2: 优化策略                                 │
    │   → 索引优化为主                                  │
    │   → Redis 缓存为辅                                │
    ├─────────────────────────────────────────────────┤
    │ 决策点3: 实施顺序                                 │
    │   → 先索引（见效快）                              │
    │   → 后缓存（架构改动大）                          │
    └─────────────────────────────────────────────────┘
    
    【生成的增量任务】
    ├─ Incremental-01: 上下文整理与方案文档化
    │   └─ 职责: 将讨论内容整理为正式优化方案文档
    │   └─ 输出: optimization-plan.md
    │
    ├─ Incremental-02: TOP 10 慢查询索引设计
    │   └─ 职责: 针对每个慢查询设计索引方案
    │   └─ 输出: index-design.md, SQL migration 脚本
    │
    ├─ Incremental-03: Redis 缓存架构设计
    │   └─ 职责: 设计缓存层架构，包括缓存策略、失效机制
    │   └─ 输出: cache-architecture.md
    │
    └─ Incremental-04: 分阶段实施路线图
        └─ 职责: 制定详细的实施计划，包括回滚方案
        └─ 输出: implementation-roadmap.md
    
    【依赖关系】
    Incremental-01 → Incremental-02
    Incremental-01 → Incremental-03
    Incremental-02 → Incremental-04
    Incremental-03 → Incremental-04
    
    确认启动？ [启动] [调整] [取消]

User: 启动

AI: ✅ 已启动 4 个增量 Workers
    
    📁 项目目录: projects/db-optimization-inc-2026-04-03/
    📊 状态看板: projects/db-optimization-inc-2026-04-03/status.md
    🧠 上下文来源: 当前会话 (4 轮对话分析)
    
    【实时状态】
    Incremental-01 (上下文整理): 🟡 运行中 - 0%
    Incremental-02 (索引设计):   ⏳ 等待上下文整理
    Incremental-03 (缓存架构):   ⏳ 等待上下文整理
    Incremental-04 (实施路线图): ⏳ 等待索引设计 + 缓存架构
```

## Worker 任务详情

### Incremental-01: 上下文整理与方案文档化

**Worker Prompt**:
```
## 任务：上下文整理与方案文档化

### 背景上下文
基于用户与 AI 的数据库优化讨论会话，需要整理出正式的优化方案文档。

### 讨论中确定的关键点
1. 问题：应用查询性能问题
2. 方法：分析慢查询日志，聚焦 TOP 10 慢查询
3. 策略：索引优化为主，Redis 缓存为辅
4. 顺序：先索引后缓存

### 交付物
1. optimization-plan.md - 完整的优化方案文档，包含：
   - 问题定义与现状分析
   - 优化目标（量化指标）
   - 优化策略总览
   - 风险评估
   - 资源需求

### 状态文件
projects/db-optimization-inc-2026-04-03/state/incremental-01.json

### 上下文引用
当前会话的完整讨论记录已附加在 context 字段中。
```

### Incremental-02: TOP 10 慢查询索引设计

**Worker Prompt**:
```
## 任务：TOP 10 慢查询索引设计

### 背景上下文
基于 Incremental-01 整理的优化方案，针对 TOP 10 慢查询设计索引。

### 输入依赖
- optimization-plan.md（由 Incremental-01 生成）

### 交付物
1. index-design.md - 索引设计方案，包含：
   - 每个慢查询的分析
   - 建议索引及理由
   - 索引创建 SQL
   - 性能预期提升
2. migration-scripts/ - SQL migration 脚本
   - 创建索引脚本
   - 回滚脚本

### 状态文件
projects/db-optimization-inc-2026-04-03/state/incremental-02.json
```

### Incremental-03: Redis 缓存架构设计

**Worker Prompt**:
```
## 任务：Redis 缓存架构设计

### 背景上下文
基于 Incremental-01 整理的优化方案，设计 Redis 缓存层架构。

### 输入依赖
- optimization-plan.md（由 Incremental-01 生成）

### 交付物
1. cache-architecture.md - 缓存架构设计，包含：
   - 缓存层整体架构图
   - 缓存策略（读写策略、过期策略）
   - 数据一致性方案
   - 缓存穿透/击穿/雪崩防护
   - Redis 集群配置建议

### 状态文件
projects/db-optimization-inc-2026-04-03/state/incremental-03.json
```

### Incremental-04: 分阶段实施路线图

**Worker Prompt**:
```
## 任务：分阶段实施路线图

### 背景上下文
整合索引优化和缓存架构设计，制定完整的实施路线图。

### 输入依赖
- optimization-plan.md（Incremental-01）
- index-design.md（Incremental-02）
- cache-architecture.md（Incremental-03）

### 交付物
1. implementation-roadmap.md - 实施路线图，包含：
   - 阶段划分（里程碑）
   - 每个阶段的详细任务
   - 时间表
   - 回滚方案
   - 监控检查点

### 状态文件
projects/db-optimization-inc-2026-04-03/state/incremental-04.json
```

## 项目结构

```
projects/db-optimization-inc-2026-04-03/
├── state/
│   ├── incremental-01.json    # 上下文整理 Worker 状态
│   ├── incremental-02.json    # 索引设计 Worker 状态
│   ├── incremental-03.json    # 缓存架构 Worker 状态
│   └── incremental-04.json    # 路线图 Worker 状态
├── deliverables/
│   ├── optimization-plan.md   # 优化方案文档
│   ├── index-design.md        # 索引设计方案
│   ├── migration-scripts/     # SQL 脚本
│   │   ├── create-indexes.sql
│   │   └── rollback-indexes.sql
│   ├── cache-architecture.md  # 缓存架构设计
│   └── implementation-roadmap.md  # 实施路线图
├── final/
│   └── INTEGRATED.md          # 整合报告
├── context/
│   └── session-summary.json   # 提取的上下文摘要
└── status.md                  # 实时状态看板
```

## 关键特性

### 1. 上下文感知
每个 Worker 都携带会话上下文的摘要：
- 关键决策点
- 已确定的方案方向
- 待解决的问题

### 2. 智能任务生成
基于上下文自动生成针对性任务：
- 将讨论转化为行动
- 保持与原始意图一致
- 填补讨论中的空白

### 3. 依赖管理
增量任务之间也存在依赖：
- 基础整理任务先行
- 并行执行独立设计任务
- 最后整合为路线图

## 分步命令版本

```bash
# 1. 分析当前会话上下文
/mao analyze-context

# 2. 查看建议的增量任务
/mao suggest-incremental

# 3. 自定义增量任务
/mao launch --incremental \
  --tasks "文档化,索引设计,缓存设计" \
  --context-depth 5

# 4. 指定上下文来源
/mao launch --incremental \
  --context-source "session,memory"

# 5. 查看状态
/mao status

# 6. 完成整合
/mao finalize
```

## 最佳实践

### 何时使用增量模式

| ✅ 适合使用 | ❌ 不适合使用 |
|-----------|-------------|
| 已有几轮相关讨论 | 完全全新的任务 |
| 讨论中形成了明确决策 | 还没有明确方向 |
| 需要将讨论转化为行动 | 只需要简单执行 |
| 多轮讨论涉及多个方面 | 单一简单问题 |

### 上下文深度建议

```bash
# 简短讨论（1-2轮）
/mao launch --incremental --context-depth 2

# 中等讨论（3-5轮）
/mao launch --incremental --context-depth 3  # 默认

# 长讨论（5+轮）
/mao launch --incremental --context-depth 5
```

### 常见陷阱

1. **❌ 上下文丢失**：增量任务没有正确继承关键决策
   - ✅ **解决**：检查 context/session-summary.json 是否完整

2. **❌ 任务偏离**：生成的任务与原始讨论意图不符
   - ✅ **解决**：使用 `/mao suggest-incremental` 预览任务

3. **❌ 过度分解**：将简单讨论分解为过多任务
   - ✅ **解决**：根据讨论复杂度调整任务数量

## 与其他模式对比

| 模式 | 启动命令 | 适用场景 | 上下文来源 |
|------|----------|----------|-----------|
| 标准模式 | `/mao 任务` | 全新任务 | 无 |
| 增量模式 | `/mao launch --incremental` | 基于当前会话继续 | 当前会话 |
| 恢复模式 | `/mao launch --resume` | 恢复历史项目 | 历史状态文件 |
| 分解模式 | `/mao decompose` | 明确知道要分几个模块 | 手动指定 |

## 延伸阅读

- [软件开发示例](./software-development.md) - 全新项目的标准模式
- [文档编写示例](./document-writing.md) - 并行文档编写
- [数据分析示例](./data-analysis.md) - 数据分析任务

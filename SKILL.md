# multi-agent-orchestrator

## Description

自动将复杂任务分解为并行子任务，协调多个子代理执行。适用于大型项目开发、多模块系统设计、批量文档编写等场景。

**核心架构**：主代理识别 + Manager 子代理 + Workers 并行执行
- 用户输入 `/mao <任务>`
- 主代理**立即返回确认**（不阻塞）
- 启动 Manager Subagent（后台运行，带 5 分钟心跳）
- Manager 负责分析、拆解、启动 Workers
- 所有进度通过消息汇报到主会话

核心能力：
- **非阻塞执行**：主会话立即返回，后台自动执行
- **智能任务分解**：Manager 自动分析并拆解任务
- **心跳监控**：Manager 每 5 分钟汇报进度
- **并行执行**：多个 Worker 同时处理独立模块
- **自然语言交互**：完全通过对话完成，无需手动脚本

## Usage

### 快速启动（会话中自然语言）

```
/mao <任务描述>
```

**执行流程**：
1. 用户在会话中输入 `/mao 检查 memory system 状态`
2. 主代理**立即回复**："✅ 已启动 Manager，任务ID: check-memory-2026-04-05"
3. **后台启动**：Manager Subagent 开始分析和执行
4. **心跳汇报**：Manager 每 5 分钟向主会话发送进度消息
5. **完成通知**：任务完成后发送总结报告

### 实际示例

```
用户: /mao 检查 agent memory system 各组件状态

AI: ✅ 已启动 Manager
    📋 任务: 检查 agent memory system 各组件状态
    🆔 任务ID: check-memory-2026-04-05-1430
    ⏱️  首次汇报: 5分钟内
    
    Manager 正在后台分析任务...

[5分钟后 - Manager 自动发送]

AI: [Heartbeat - Manager: check-memory-2026-04-05-1430]
    ⏱️ 运行: 5分钟
    📊 进度: 分析完成，已拆解3个Workers
    
    Workers:
    ├─ Worker-1 (检查 cron 任务): 🟡 运行中
    ├─ Worker-2 (检查 GitHub 状态): 🟡 运行中
    └─ Worker-3 (检查前端项目): ⏳ 等待启动
    
    预计完成: 15分钟

[20分钟后 - Manager 自动发送]

AI: [Complete] 🎉 任务完成！
    
    总耗时: 20分钟
    Workers: 3个全部完成
    
    📋 检查结果:
    ├─ Cron 任务: ❌ 未配置
    ├─ GitHub: ⚠️ 有待提交更改
    └─ 前端项目: ✅ 运行正常
    
    💡 建议操作:
    1. 配置 crontab 定时任务
    2. 提交 GitHub 更改
```

### 查询状态

```
用户: check-memory-2026-04-05-1430 进展如何？

AI: 📊 任务状态查询
    
    任务ID: check-memory-2026-04-05-1430
    状态: 🟡 运行中
    进度: 66% (2/3 Workers 完成)
    运行时间: 12分钟
    
    活跃 Workers:
    ├─ Worker-1: ✅ 已完成
    ├─ Worker-2: ✅ 已完成
    └─ Worker-3: 🟡 运行中 80%
```

## Architecture

### 完整流程

```
┌─────────────────────────────────────────────────────────────┐
│                        用户主会话                            │
│  用户: /mao 开发博客系统                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼ 立即返回确认
┌─────────────────────────────────────────────────────────────┐
│  主代理 (Main Agent)                                         │
│  1. 识别 "/mao " 前缀                                        │
│  2. 生成任务ID: blog-dev-2026-04-05-1430                     │
│  3. sessions_spawn 启动 Manager                             │
│  4. 回复用户: "已启动 Manager..."                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼ 非阻塞启动
┌─────────────────────────────────────────────────────────────┐
│  Manager Subagent (独立会话)                                  │
│  • 独立上下文                                                │
│  • 1小时超时                                                 │
│  • streamTo: parent (可向主会话发送消息)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
    ┌────────────────────┼────────────────────┐
    ▼                    ▼                    ▼
┌──────────┐      ┌──────────┐      ┌──────────┐
│ Worker-1 │      │ Worker-2 │      │ Worker-3 │
│ Subagent │      │ Subagent │      │ Subagent │
└──────────┘      └──────────┘      └──────────┘
    │                    │                    │
    └────────────────────┼────────────────────┘
                         ▼
              每5分钟汇报到主会话
```

### 主代理职责

当检测到 `/mao ` 前缀时：

1. **立即响应**（< 1秒）
   ```
   ✅ 已启动 Manager
   📋 任务: {任务描述}
   🆔 任务ID: {task-id}
   ⏱️  首次汇报: 5分钟内
   ```

2. **启动 Manager**
   ```javascript
   sessions_spawn({
     task: managerPrompt,
     mode: "run",
     timeoutSeconds: 3600,
     streamTo: "parent"
   })
   ```

3. **转发汇报**
   - 接收 Manager 发送的消息
   - 转发给用户（无需处理，直接呈现）

### Manager 职责

Manager Subagent 的核心职责：

```markdown
# Manager Prompt Template

你是一名任务管理专家，负责协调多代理并行执行。

## 当前任务
{task_description}

## 你的职责
1. **分析阶段**（启动后 1-2 分钟）
   - 分析任务可分解性
   - 确定 Worker 数量和职责
   - 识别依赖关系
   - 向主会话发送首次汇报

2. **启动 Workers**（分析完成后）
   - 为每个 Worker 调用 sessions_spawn
   - 记录所有 Worker 的 sessionKey
   - 向主会话发送 Workers 列表

3. **心跳循环**（每 5 分钟）
   - 检查所有 Worker 状态
   - 向主会话发送进度消息
   - 格式: [Heartbeat - Manager: {task-id}]

4. **完成处理**
   - 所有 Worker 完成后
   - 整合结果
   - 发送 [Complete] 消息

## 消息格式

首次汇报:
```
[Manager Started] {task-id}
已拆解 {n} 个 Workers:
├─ Worker-1: {职责}
├─ Worker-2: {职责}
└─ Worker-n: {职责}
开始执行...
```

心跳汇报（每5分钟）:
```
[Heartbeat - Manager: {task-id}]
⏱️ 运行: {X} 分钟
📊 进度: {P}% ({completed}/{total} Workers 完成)

Workers:
├─ Worker-1: ✅ 已完成
├─ Worker-2: 🟡 运行中 {progress}%
├─ Worker-3: ⏳ 等待依赖
└─ Worker-4: ❌ 失败（已重试1/3次）

⚠️  阻塞: {如果有}
💡 预计完成: {ETA}
```

完成汇报:
```
[Complete] 🎉 任务完成！

总耗时: {X} 分钟
Workers: {n} 个全部完成

📋 交付物:
├─ {item-1}
├─ {item-2}
└─ {item-n}
```

## 状态持久化

每5分钟将状态写入文件:
```json
{
  "taskId": "blog-dev-2026-04-05-1430",
  "status": "running",
  "startTime": "2026-04-05T14:30:00Z",
  "workers": [
    {"id": "worker-1", "status": "completed", "result": "..."},
    {"id": "worker-2", "status": "running", "progress": 60}
  ]
}
```

路径: `~/.openclaw/workspace/.mao-status/{task-id}.json`

## 现在开始

1. 分析任务: {task_description}
2. 发送首次汇报
3. 启动 Workers
4. 开始5分钟心跳循环
```

### Worker 职责

每个 Worker 是一个独立的 subagent：

```markdown
# Worker Prompt Template

你是 Worker-{n}，负责执行特定子任务。

## 你的任务
{worker_task_description}

## 汇报机制
- 完成后立即向 Manager 汇报
- 遇到问题立即上报
- 定期更新进度（如果需要长时间运行）

## 输出要求
- 将结果写入指定文件
- 向 Manager 发送完成消息
```

## Implementation

### 文件结构

```
multi-agent-orchestrator/
├── SKILL.md                      # 本文件
├── README.md                     # 简介
├── AGENTS.md (workspace)         # 主代理识别规则
├── config/
│   └── default.yaml              # 默认配置
└── templates/
    └── manager-prompt.md         # Manager 启动提示词
```

### 主代理代码模式

当用户输入 `/mao <任务>` 时，执行：

```javascript
// 1. 生成任务ID
const taskId = generateTaskId(taskDescription);

// 2. 立即回复用户
reply(`✅ 已启动 Manager
📋 任务: ${taskDescription}
🆔 任务ID: ${taskId}
⏱️  首次汇报: 5分钟内`);

// 3. 启动 Manager Subagent
const managerPrompt = loadTemplate('manager-prompt.md')
  .replace('{{task_description}}', taskDescription)
  .replace('{{task_id}}', taskId);

sessions_spawn({
  task: managerPrompt,
  mode: "run",
  timeoutSeconds: 3600,
  streamTo: "parent"
});

// 4. 主代理继续可用，等待 Manager 汇报
```

### Manager 代码模式

Manager Subagent 执行：

```javascript
// Phase 1: 分析
const analysis = analyzeTask(taskDescription);
const workers = decomposition(analysis);

// 发送首次汇报
sessions_send(parentSession, formatFirstReport(workers));

// Phase 2: 启动 Workers
const workerSessions = [];
for (const worker of workers) {
  const session = sessions_spawn({
    task: worker.prompt,
    mode: "run"
  });
  workerSessions.push({worker, session});
}

// Phase 3: 心跳循环
setInterval(() => {
  const status = checkWorkersStatus(workerSessions);
  sessions_send(parentSession, formatHeartbeat(status));
  saveStatusToFile(taskId, status);
}, 5 * 60 * 1000);

// Phase 4: 完成处理
onAllWorkersComplete(() => {
  const results = collectResults(workerSessions);
  sessions_send(parentSession, formatCompletion(results));
});
```

## Heartbeat Protocol

### 配置

```yaml
# config/default.yaml
manager:
  heartbeat_interval: 5min      # 心跳间隔
  max_workers: 10               # 最大 Worker 数
  timeout: 1h                   # Manager 超时
  
heartbeat:
  enabled: true
  interval: 5min
  timeout: 30min
  report_format: markdown
```

### 消息类型

**1. 首次汇报**（启动后 1-2 分钟）
```
[Manager Started] blog-dev-2026-04-05-1430

已拆解 4 个 Workers:
├─ Worker-1: 用户系统 (认证/注册)
├─ Worker-2: 文章系统 (发布/编辑)
├─ Worker-3: 评论系统 (发布/审核)
└─ Worker-4: 标签系统 (创建/关联)

执行策略: Phase 1 并行，Phase 2/3 顺序
开始执行...
```

**2. 常规心跳**（每 5 分钟）
```
[Heartbeat - Manager: blog-dev-2026-04-05-1430]
⏱️ 运行: 15 分钟
📊 整体进度: 45% (2/5 Workers 完成)

Workers:
├─ Worker-1: ✅ 已完成 (用户系统)
├─ Worker-2: 🟡 运行中 80% (文章系统)
├─ Worker-3: 🟡 运行中 60% (评论系统)
├─ Worker-4: ⏳ 等待依赖 (标签系统)
└─ Worker-5: ⏳ 未启动 (搜索系统)

⚠️  阻塞: Worker-4 等待 Worker-2 完成
💡 建议: 预计 10 分钟后 Worker-2 完成
```

**3. 异常告警**
```
[Alert - Manager: blog-dev-2026-04-05-1430]
Worker-3 遇到异常

问题: 数据库连接超时
尝试: 自动重试 2/3 次
状态: 已暂停，等待干预

建议: 检查数据库配置
```

**4. 完成报告**
```
[Complete] 🎉 任务完成！

总耗时: 45 分钟
Workers: 5 个全部完成
交付物: 12 个文件

📁 项目位置: projects/blog-dev-2026-04-05-1430/
📊 详细报告: COMPLETION-REPORT.md
```

## Examples

### Example 1: 系统检查任务

```
用户: /mao 全面检查 agent memory system 健康状态

AI: ✅ 已启动 Manager
    📋 任务: 全面检查 agent memory system 健康状态
    🆔 任务ID: health-check-2026-04-05-1430
    ⏱️  首次汇报: 5分钟内

[5分钟后]

AI: [Manager Started] health-check-2026-04-05-1430
    
    已拆解 4 个 Workers:
    ├─ Worker-1: 检查 Cron 任务配置
    ├─ Worker-2: 检查 GitHub 同步状态
    ├─ Worker-3: 检查前端项目运行状态
    └─ Worker-4: 检查 Netlify 部署状态
    
    开始执行...

[15分钟后]

AI: [Complete] 🎉 任务完成！
    
    总耗时: 15 分钟
    Workers: 4 个全部完成
    
    📋 检查结果:
    ├─ Cron 任务: ❌ 未配置（需要立即修复）
    ├─ GitHub: ⚠️ 有待提交更改（3个文件）
    ├─ 前端项目: ✅ 运行正常（端口3000）
    └─ Netlify: ✅ 部署正常
    
    💡 建议操作:
    1. 运行 crontab -e 配置定时任务
    2. 提交 GitHub 更改: git push origin main
```

### Example 2: 开发项目

```
用户: /mao 开发一个 todo-list 应用，使用 React + TypeScript

AI: ✅ 已启动 Manager
    📋 任务: 开发 todo-list 应用（React + TypeScript）
    🆔 任务ID: todo-app-2026-04-05-1430
    ⏱️  首次汇报: 5分钟内

[5分钟后]

AI: [Manager Started] todo-app-2026-04-05-1430
    
    已拆解 5 个 Workers:
    ├─ Worker-1: 项目初始化（Vite + React + TS）
    ├─ Worker-2: 核心组件开发（TodoList/TodoItem）
    ├─ Worker-3: 状态管理（useState/useContext）
    ├─ Worker-4: 样式系统（Tailwind CSS）
    └─ Worker-5: 本地存储（localStorage）
    
    执行策略: Worker-1 完成后并行启动其他 Workers
    开始执行...

[10分钟后]

AI: [Heartbeat - Manager: todo-app-2026-04-05-1430]
    ⏱️ 运行: 10 分钟
    📊 进度: 20% (1/5 Workers 完成)
    
    Workers:
    ├─ Worker-1: ✅ 已完成 - 项目初始化完成
    ├─ Worker-2: 🟡 运行中 30% - 开发 TodoList 组件
    ├─ Worker-3: 🟡 运行中 25% - 设置状态管理
    ├─ Worker-4: 🟡 运行中 20% - 配置 Tailwind
    └─ Worker-5: ⏳ 等待中 - 等待 Worker-3 完成

[30分钟后]

AI: [Complete] 🎉 任务完成！
    
    总耗时: 30 分钟
    Workers: 5 个全部完成
    
    📁 项目位置: projects/todo-app-2026-04-05-1430/
    📋 交付物:
    ├─ src/components/TodoList.tsx
    ├─ src/components/TodoItem.tsx
    ├─ src/hooks/useTodos.ts
    ├─ src/context/TodoContext.tsx
    ├─ src/App.tsx
    └─ README.md
    
    🚀 运行: npm run dev
```

## Configuration

### 环境变量

```bash
export MAO_HEARTBEAT_INTERVAL=5min
export MAO_MAX_WORKERS=10
export MAO_TIMEOUT=1h
```

### 状态文件位置

```
~/.openclaw/workspace/.mao-status/
├── {task-id-1}.json      # 运行中任务状态
├── {task-id-2}.json
└── archive/              # 已完成任务归档
    └── {task-id}.json
```

## Why This Design?

### 1. 自然语言交互
- 用户只需在对话中输入 `/mao <任务>`
- 无需记住复杂的命令格式
- 无需手动执行脚本

### 2. 非阻塞执行
- 主代理立即返回，用户可继续对话
- Manager 在后台独立运行
- 进度通过消息异步汇报

### 3. 可靠性
- Manager 定期持久化状态
- Worker 失败可自动重试
- 超时检测和自动恢复

### 4. 可观测性
- 每 5 分钟心跳汇报
- 关键节点即时通知
- 状态文件可追溯

## License

MIT License

---
**Made with ❤️ by [AnanasYang](https://github.com/AnanasYang)**

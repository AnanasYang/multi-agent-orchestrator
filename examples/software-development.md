# 软件开发示例

本示例展示如何使用 Multi-Agent Orchestrator 开发一个博客系统。

## 场景

开发一个博客系统，包含4个核心模块：
- 用户系统 (认证/注册/个人中心)
- 文章系统 (发布/编辑/分类)
- 评论系统 (发布/审核/通知)
- 标签系统 (创建/关联/搜索)

## 执行过程

### 1. 快速启动

```
User: /mao 开发一个博客系统，包含用户系统、文章系统、评论系统、标签系统
```

### 2. Manager 分析

```
AI: 📊 任务分析完成
    
    【可分解性评分】9.2/10 ✅ 强烈推荐多代理模式
    
    【建议分解】
    ├─ Module 1: 用户系统
    │   └─ 职责: 用户注册、登录、JWT认证、个人中心
    ├─ Module 2: 文章系统
    │   └─ 职责: 文章CRUD、富文本编辑、草稿箱、分类
    ├─ Module 3: 评论系统
    │   └─ 职责: 评论发布、嵌套回复、审核机制、通知
    └─ Module 4: 标签系统
        └─ 职责: 标签CRUD、文章关联、标签云、搜索
    
    【依赖关系】
    用户系统 → 文章系统 (发布文章需要登录)
    用户系统 → 评论系统 (评论需要身份)
    标签系统 → 文章系统 (文章可以打标签)
    
    【执行策略】
    Phase 1: 并行启动 用户系统 + 标签系统
    Phase 2: 并行启动 文章系统 + 评论系统 (等待Phase 1完成)
    
    确认启动？ [启动] [调整] [取消]
```

### 3. Workers 启动

```
User: 启动

AI: 🚀 正在启动 4 个 Worker...
    
    ✅ Worker-01 (用户系统) 已启动
    ✅ Worker-02 (标签系统) 已启动
       ↳ 等待 Phase 1 完成...
    ✅ Worker-03 (文章系统) 已启动
    ✅ Worker-04 (评论系统) 已启动
    
    📁 项目目录: projects/blog-system-2026-04-03/
    📊 状态看板: projects/blog-system-2026-04-03/status.md
    
    【实时状态】
    Worker-01 (用户系统): 🟡 运行中 - 设计API接口
    Worker-02 (标签系统): 🟡 运行中 - 设计数据模型
    Worker-03 (文章系统): ⏳ 等待依赖 (用户系统API)
    Worker-04 (评论系统): ⏳ 等待依赖 (用户系统API)
```

### 4. 监控进度

```
User: /mao status

AI: 📊 实时监控: blog-system-2026-04-03
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    ✅ Worker-01 (用户系统): 100% | API设计完成，正在写注册接口
    ✅ Worker-02 (标签系统): 100% | 数据模型完成，正在写CRUD
    ⏳ Worker-03 (文章系统): 0%   | 等待用户系统JWT接口
    ⏳ Worker-04 (评论系统): 0%   | 等待用户系统JWT接口
    
    检测到 Worker-01 已完成关键交付物！
    正在解除 Worker-03, Worker-04 的阻塞...
    
    ✅ Worker-03 (文章系统): 🟡 运行中 - 0% → 25%
    ✅ Worker-04 (评论系统): 🟡 运行中 - 0% → 20%
```

### 5. 完成整合

```
User: /mao finalize

AI: 🎯 整合交付物: blog-system-2026-04-03
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    📦 收集交付物...
      ✓ user-api.md
      ✓ user-service.js
      ✓ tag-api.md
      ✓ tag-service.js
      ✓ article-api.md
      ✓ article-service.js
      ✓ comment-api.md
      ✓ comment-service.js
      ✓ database-schema.sql
    
    找到 9 个交付物
    
    ✅ 整合完成！
    
    📄 输出文件:
      - projects/blog-system-2026-04-03/final/INTEGRATED.md
      - projects/blog-system-2026-04-03/final/api-documentation.md
      - projects/blog-system-2026-04-03/final/service-implementation.md
    
    【项目总结】
    总耗时: 1.5 小时
    并行效率: 4x (vs 串行 4.5 小时)
    模块数: 4
    交付物: 9 个文件
```

## 项目结构

```
projects/blog-system-2026-04-03/
├── state/
│   ├── worker-01.json       # 用户系统状态
│   ├── worker-02.json       # 标签系统状态
│   ├── worker-03.json       # 文章系统状态
│   └── worker-04.json       # 评论系统状态
├── deliverables/
│   ├── user-api.md
│   ├── user-service.js
│   ├── tag-api.md
│   ├── tag-service.js
│   ├── article-api.md
│   ├── article-service.js
│   ├── comment-api.md
│   └── comment-service.js
├── final/
│   ├── INTEGRATED.md        # 整合报告
│   └── api-documentation.md # 完整API文档
└── status.md                # 实时状态看板
```

## 分步命令版本

如果你想手动控制每个步骤：

```bash
# 1. 分析任务
/mao analyze "开发一个博客系统，包含用户系统、文章系统、评论系统、标签系统"

# 2. 自定义分解
/mao decompose \
  --modules 4 \
  --names "用户系统,文章系统,评论系统,标签系统" \
  --dependencies "1->2,1->3,4->2"

# 3. 启动 Workers
/mao launch

# 4. 查看状态
/mao status

# 5. 查看特定 Worker 详情
/mao check worker-01

# 6. 完成整合
/mao finalize
```

## 最佳实践

1. **模块边界清晰**：每个 Worker 负责独立的业务领域
2. **接口先行**：先定义模块间接口，再各自实现
3. **依赖管理**：合理设置依赖关系，最大化并行度
4. **定期检查**：使用 `/mao status` 监控进度，及时发现问题

## 常见问题

### Q: 如果某个 Worker 失败了怎么办？

```
/mao check worker-02
# 查看失败原因

/mao restart worker-02
# 重启 Worker

/mao status
# 查看重启后的状态
```

### Q: 可以动态添加新 Worker 吗？

```
/mao add-worker \
  --name "搜索系统" \
  --depends-on "article,tag" \
  --task "实现全文搜索功能"
```

### Q: 如何调整已启动 Worker 的任务范围？

```
/mao modify worker-03 \
  --add-task "添加文章导出功能" \
  --priority high
```

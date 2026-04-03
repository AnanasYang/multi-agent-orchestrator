# 文档编写示例

本示例展示如何使用 Multi-Agent Orchestrator 并行编写一份年度报告。

## 场景

撰写公司年度报告，包含4个章节：
- 市场分析
- 产品回顾
- 财务总结
- 未来规划

## 执行过程

### 1. 快速启动

```
User: /mao 写一份年度报告，包含市场分析、产品回顾、财务总结、未来规划

AI: 📊 任务分析完成
    
    【可分解性评分】9.5/10 ✅ 强烈推荐多代理模式
    
    【建议分解】
    ├─ Writer 1: 市场分析章节
    ├─ Writer 2: 产品回顾章节
    ├─ Writer 3: 财务总结章节
    └─ Writer 4: 未来规划章节
    
    【特点】
    4个章节完全独立，无依赖关系
    可全并行执行，最大化效率
    
    【整合策略】
    完成后统一文风、添加过渡段落、生成目录
    
    确认启动？ [启动]

User: 启动
```

### 2. Workers 并行编写

```
AI: 🚀 启动 4 个 Writer...
    
    ✅ Writer-01 (市场分析): 🟡 正在分析行业数据
    ✅ Writer-02 (产品回顾): 🟡 正在整理产品里程碑
    ✅ Writer-03 (财务总结): 🟡 正在处理财务报表
    ✅ Writer-04 (未来规划): 🟡 正在制定战略目标
    
    📁 项目目录: projects/annual-report-2026/
```

### 3. 独立进展

```
User: /mao status

AI: 📊 实时监控: annual-report-2026
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    ✅ Writer-01 (市场分析): 80% | ████████████░░░░░░░░ | 数据分析完成，正在撰写洞察
    ✅ Writer-02 (产品回顾): 60% | █████████░░░░░░░░░░░ | 整理产品发布记录
    ✅ Writer-03 (财务总结): 90% | ██████████████░░░░░░ | 图表制作中
    ✅ Writer-04 (未来规划): 40% | ██████░░░░░░░░░░░░░░ | 正在研究行业趋势
    
    总体进度: 67%
    预计完成: 20分钟后
```

### 4. 逐个完成

```
[5分钟后]

AI: ✅ Writer-03 (财务总结) 已完成！
    交付物: financial-summary.md, charts/

[10分钟后]

AI: ✅ Writer-01 (市场分析) 已完成！
    交付物: market-analysis.md, competitor-comparison.xlsx

[15分钟后]

AI: ✅ Writer-04 (未来规划) 已完成！
    交付物: future-roadmap.md, strategic-goals.md

[20分钟后]

AI: ✅ Writer-02 (产品回顾) 已完成！
    交付物: product-review.md, feature-timeline.png
```

### 5. 风格统一与整合

```
User: /mao finalize

AI: 🎯 整合交付物: annual-report-2026
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    📦 收集交付物...
      ✓ market-analysis.md
      ✓ competitor-comparison.xlsx
      ✓ product-review.md
      ✓ feature-timeline.png
      ✓ financial-summary.md
      ✓ charts/
      ✓ future-roadmap.md
      ✓ strategic-goals.md
    
    🔧 正在统一文风...
      - 统一术语使用
      - 统一数据格式
      - 添加过渡段落
    
    📑 生成目录和封面...
    
    ✅ 整合完成！
    
    📄 最终报告:
      - projects/annual-report-2026/final/annual-report-2026.pdf
      - projects/annual-report-2026/final/annual-report-2026.docx
    
    【项目统计】
    总耗时: 35分钟 (vs 串行 2小时+)
    并行效率: 3.4x
    交付物: 8 个文件
    总字数: ~15,000 字
```

## 优势对比

### 传统串行方式
- 写完市场分析才能写产品回顾
- 总耗时: 2-3 小时
- 容易疲劳，质量下降

### 多代理并行方式
- 4 个章节同时编写
- 总耗时: 35 分钟
- 专注度高，质量一致

## 分步命令

```bash
# 1. 分析
/mao analyze "写一份年度报告"

# 2. 指定章节约束
/mao decompose \
  --modules 4 \
  --names "市场分析,产品回顾,财务总结,未来规划" \
  --word-count "3000,4000,3000,2500" \
  --style "formal,business"

# 3. 启动
/mao launch

# 4. 检查文风一致性
/mao check-style

# 5. 完成
/mao finalize --format pdf,docx
```

## 进阶技巧

### 指定写作风格

```
/mao config writing-style academic
/mao config tone professional
/mao config target-audience "board-members"
```

### 添加参考资料

```
/mao add-reference \
  --worker writer-01 \
  --file /path/to/industry-report.pdf \
  --priority high
```

### 协同编辑

```
# 当 Writer-03 发现需要 Writer-01 补充数据时
/mao request \
  --from writer-03 \
  --to writer-01 \
  --message "需要补充Q4市场份额数据"

# Writer-01 收到通知后更新
/mao update worker-01 \
  --add-content "Q4市场份额: 35% (+5% YoY)"
```

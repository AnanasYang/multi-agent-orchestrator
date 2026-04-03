#!/bin/bash
# analyze-task.sh - 分析任务可分解性

TASK="$1"

if [ -z "$TASK" ]; then
    echo "用法: analyze-task.sh '<任务描述>'"
    exit 1
fi

echo "🔍 正在分析任务可分解性..."
echo "任务: $TASK"
echo ""

# 计算任务长度
LENGTH=${#TASK}

# 检测关键词
MODULE_KEYWORDS=$(echo "$TASK" | grep -oiE "(系统|模块|组件|部分|章节|阶段|步骤)" | wc -l)
PARALLEL_KEYWORDS=$(echo "$TASK" | grep -oiE "(并行|同时|一起|分别|各自|独立)" | wc -l)
AND_COUNT=$(echo "$TASK" | grep -oE "[,，、]|和|以及|包含|包括" | wc -l)

# 计算可分解性评分 (0-10)
SCORE=0

# 长度因子 (长任务通常可分解)
if [ $LENGTH -gt 100 ]; then
    SCORE=$((SCORE + 2))
fi
if [ $LENGTH -gt 200 ]; then
    SCORE=$((SCORE + 1))
fi

# 关键词因子
SCORE=$((SCORE + MODULE_KEYWORDS))
SCORE=$((SCORE + PARALLEL_KEYWORDS * 2))

# 连接词因子
if [ $AND_COUNT -gt 2 ]; then
    SCORE=$((SCORE + 1))
fi

# 限制最大分数
if [ $SCORE -gt 10 ]; then
    SCORE=10
fi

echo "📊 分析结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "任务长度: $LENGTH 字符"
echo "模块关键词: $MODULE_KEYWORDS 个"
echo "并行关键词: $PARALLEL_KEYWORDS 个"
echo "连接词: $AND_COUNT 个"
echo ""
echo "可分解性评分: $SCORE/10"
echo ""

if [ $SCORE -ge 8 ]; then
    echo "✅ 强烈推荐使用多代理模式"
    echo "建议 Worker 数: 5-10"
elif [ $SCORE -ge 5 ]; then
    echo "🟡 适合使用多代理模式"
    echo "建议 Worker 数: 3-5"
else
    echo "🟠 建议直接执行"
    echo "原因: 任务较简单，分解开销可能大于收益"
fi

echo ""
echo "下一步:"
echo "  运行 'decompose.sh \"$TASK\"' 进行任务分解"

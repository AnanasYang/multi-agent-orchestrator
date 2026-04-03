#!/bin/bash
# finalize.sh - 整合交付物

PROJECT_ID="$1"
PROJECT_DIR="projects/$PROJECT_ID"

if [ -z "$PROJECT_ID" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo "用法: finalize.sh <project-id>"
    exit 1
fi

echo "🎯 整合交付物: $PROJECT_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建最终输出目录
mkdir -p "$PROJECT_DIR/final"

# 收集所有交付物
echo "📦 收集交付物..."
DELIVERABLE_COUNT=0

for DELIVERY in "$PROJECT_DIR"/deliverables/*; do
    if [ -f "$DELIVERY" ]; then
        echo "  ✓ $(basename "$DELIVERY")"
        DELIVERABLE_COUNT=$((DELIVERABLE_COUNT + 1))
    fi
done

echo ""
echo "找到 $DELIVERABLE_COUNT 个交付物"
echo ""

# 生成整合报告
cat > "$PROJECT_DIR/final/INTEGRATED.md" << EOF
# 项目交付物整合报告

**项目ID**: $PROJECT_ID  
**整合时间**: $(date -Iseconds)  

## 交付物清单

EOF

# 列出所有交付物
for DELIVERY in "$PROJECT_DIR"/deliverables/*; do
    if [ -f "$DELIVERY" ]; then
        echo "- $(basename "$DELIVERY")" >> "$PROJECT_DIR/final/INTEGRATED.md"
    fi
done

cat >> "$PROJECT_DIR/final/INTEGRATED.md" << EOF

## 模块详情

EOF

# 添加各模块状态
for STATE_FILE in "$PROJECT_DIR"/state/worker-*.json; do
    if [ -f "$STATE_FILE" ]; then
        WORKER_ID=$(basename "$STATE_FILE" .json)
        echo "### $WORKER_ID" >> "$PROJECT_DIR/final/INTEGRATED.md"
        echo "" >> "$PROJECT_DIR/final/INTEGRATED.md"
        echo "\`\`\`json" >> "$PROJECT_DIR/final/INTEGRATED.md"
        cat "$STATE_FILE" >> "$PROJECT_DIR/final/INTEGRATED.md"
        echo "\`\`\`" >> "$PROJECT_DIR/final/INTEGRATED.md"
        echo "" >> "$PROJECT_DIR/final/INTEGRATED.md"
    fi
done

echo "✅ 整合完成！"
echo ""
echo "📄 输出文件:"
echo "  - $PROJECT_DIR/final/INTEGRATED.md"
echo ""
echo "项目总结:"
echo "  项目目录: $PROJECT_DIR"
echo "  交付物数: $DELIVERABLE_COUNT"

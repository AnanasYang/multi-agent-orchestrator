#!/bin/bash
# monitor.sh - 监控状态文件

PROJECT_ID="$1"
PROJECT_DIR="projects/$PROJECT_ID"

if [ -z "$PROJECT_ID" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo "用法: monitor.sh <project-id>"
    exit 1
fi

echo "📊 实时监控: $PROJECT_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 统计信息
TOTAL=0
RUNNING=0
COMPLETED=0
WAITING=0
FAILED=0

# 显示每个 Worker 状态
for STATE_FILE in "$PROJECT_DIR"/state/worker-*.json; do
    if [ -f "$STATE_FILE" ]; then
        WORKER_ID=$(basename "$STATE_FILE" .json)
        
        # 解析 JSON (简单方式)
        STATUS=$(grep '"status"' "$STATE_FILE" | sed 's/.*: "\([^"]*\)".*/\1/')
        PROGRESS=$(grep '"progress_percent"' "$STATE_FILE" | sed 's/.*: \([0-9]*\).*/\1/')
        
        TOTAL=$((TOTAL + 1))
        
        # 状态颜色
        case "$STATUS" in
            "completed")
                COLOR=$GREEN
                COMPLETED=$((COMPLETED + 1))
                ICON="✅"
                ;;
            "running")
                COLOR=$YELLOW
                RUNNING=$((RUNNING + 1))
                ICON="🟡"
                ;;
            "waiting")
                COLOR=$BLUE
                WAITING=$((WAITING + 1))
                ICON="⏳"
                ;;
            "failed")
                COLOR=$RED
                FAILED=$((FAILED + 1))
                ICON="❌"
                ;;
            *)
                COLOR=$NC
                ICON="⚪"
                ;;
        esac
        
        # 进度条
        BAR_LEN=20
        FILLED=$((PROGRESS * BAR_LEN / 100))
        EMPTY=$((BAR_LEN - FILLED))
        BAR="$(printf '%*s' $FILLED | tr ' ' '█')$(printf '%*s' $EMPTY | tr ' ' '░')"
        
        printf "${COLOR}%s %-12s ${NC}| %3d%% | %s | %s\n" "$ICON" "$WORKER_ID" "$PROGRESS" "$BAR" "$STATUS"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "汇总: 总计 $TOTAL | 运行中 $RUNNING | 完成 $COMPLETED | 等待 $WAITING | 失败 $FAILED"

# 计算总体进度
if [ $TOTAL -gt 0 ]; then
    TOTAL_PROGRESS=$(( (COMPLETED * 100 + RUNNING * 50) / TOTAL ))
    echo "总体进度: $TOTAL_PROGRESS%"
fi

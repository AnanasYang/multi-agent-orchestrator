#!/bin/bash
# create-workers.sh - 创建并启动 Workers

PROJECT_ID="$1"
PROJECT_DIR="projects/$PROJECT_ID"

if [ -z "$PROJECT_ID" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo "用法: create-workers.sh <project-id>"
    echo "错误: 项目 $PROJECT_ID 不存在"
    exit 1
fi

echo "🚀 启动 Workers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "项目: $PROJECT_ID"
echo ""

# 读取所有 Worker 配置
for STATE_FILE in "$PROJECT_DIR"/state/worker-*.json; do
    if [ -f "$STATE_FILE" ]; then
        WORKER_ID=$(basename "$STATE_FILE" .json)
        
        echo "启动 $WORKER_ID..."
        
        # 更新状态文件
        cat > "$STATE_FILE" << EOF
{
  "phase": 1,
  "name": "$WORKER_ID",
  "status": "running",
  "subagent_id": "$(uuidgen 2>/dev/null || echo "subagent-$RANDOM")",
  "start_time": "$(date -Iseconds)",
  "last_update": "$(date -Iseconds)",
  "elapsed_minutes": 0,
  "progress_percent": 0,
  "blockers": [],
  "deliverables": ["交付物1", "交付物2"],
  "completed_deliverables": [],
  "estimated_completion": null,
  "notes": "Worker started"
}
EOF
        
        echo "  ✅ $WORKER_ID 已启动"
    fi
done

echo ""
echo "所有 Workers 已启动！"
echo ""
echo "监控命令:"
echo "  monitor.sh $PROJECT_ID     # 查看实时状态"
echo "  status.sh $PROJECT_ID      # 查看汇总状态"

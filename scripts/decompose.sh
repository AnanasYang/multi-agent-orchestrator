#!/bin/bash
# decompose.sh - 任务分解器

TASK="$1"
MODULE_COUNT="${2:-4}"

echo "🧩 任务分解"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 生成项目ID
PROJECT_ID="project-$(date +%Y%m%d-%H%M%S)"
PROJECT_DIR="projects/$PROJECT_ID"
mkdir -p "$PROJECT_DIR"/{state,deliverables,logs}

echo "📁 项目目录: $PROJECT_DIR"
echo ""

# 创建主状态文件
cat > "$PROJECT_DIR/status.md" << EOF
# 项目状态: $PROJECT_ID

**任务**: $TASK

## 进度概览

| Worker | 模块 | 状态 | 进度 | 阻塞 |
|--------|------|------|------|------|
EOF

# 生成 Workers
for i in $(seq 1 $MODULE_COUNT); do
    WORKER_ID="worker-$(printf "%02d" $i)"
    
    cat >> "$PROJECT_DIR/status.md" << EOF
| $WORKER_ID | 模块 $i | ⏳ 待启动 | 0% | - |
EOF

    # 创建 Worker 状态文件
    cat > "$PROJECT_DIR/state/$WORKER_ID.json" << 'EOF'
{
  "phase": 1,
  "name": "模块名称",
  "status": "pending",
  "subagent_id": null,
  "start_time": null,
  "last_update": null,
  "elapsed_minutes": 0,
  "progress_percent": 0,
  "blockers": [],
  "deliverables": [],
  "completed_deliverables": [],
  "estimated_completion": null,
  "notes": ""
}
EOF

done

echo ""
echo "✅ 已创建 $MODULE_COUNT 个 Worker 配置"
echo ""
echo "项目结构:"
tree -L 2 "$PROJECT_DIR" 2>/dev/null || find "$PROJECT_DIR" -maxdepth 2 -type f

echo ""
echo "下一步:"
echo "  运行 'create-workers.sh $PROJECT_ID' 启动所有 Workers"

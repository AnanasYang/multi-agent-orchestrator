# Worker 任务说明

## 基本信息
- **Worker ID**: {{WORKER_ID}}
- **模块名称**: {{MODULE_NAME}}
- **所属项目**: {{PROJECT_ID}}

## 任务目标
{{TASK_DESCRIPTION}}

## 输入
- 上游依赖: {{DEPENDENCIES}}
- 输入文件: {{INPUT_FILES}}

## 输出
- 交付物: {{DELIVERABLES}}
- 输出位置: {{OUTPUT_PATH}}

## 接口规范
- 输入格式: {{INPUT_FORMAT}}
- 输出格式: {{OUTPUT_FORMAT}}

## 状态更新要求
执行过程中请定期更新状态文件:
1. 启动时: status = "running", progress_percent = 0
2. 进行中: 每15分钟或关键节点更新 progress_percent
3. 遇到阻塞: 立即添加 blocker 到 blockers 数组
4. 完成时: status = "completed", progress_percent = 100

## 状态文件位置
{{STATE_FILE_PATH}}

## 禁止行为
- ❌ 不要处理超出范围的任务
- ❌ 不要静默失败或跳过阻塞
- ❌ 不要修改其他 Worker 的状态文件

## 完成标准
- [ ] 所有交付物已生成
- [ ] 交付物符合格式规范
- [ ] 状态文件已更新为 completed
- [ ] 已完成交付物列表已填写

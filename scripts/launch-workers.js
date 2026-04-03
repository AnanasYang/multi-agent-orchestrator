#!/usr/bin/env node
/**
 * launch-workers.js - 启动 Worker 子代理
 * 
 * 功能：
 * 1. 生成标准配置供 Manager 读取
 * 2. 支持增量任务（基于当前上下文）
 * 3. 支持从历史记忆恢复任务
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 读取项目配置
const PROJECT_ID = process.argv[2];
const MODE = process.argv[3] || 'new'; // 'new' | 'incremental' | 'resume'

if (!PROJECT_ID) {
    console.error('用法: node launch-workers.js <project-id> [mode]');
    console.error('mode: new (默认) | incremental | resume');
    process.exit(1);
}

const PROJECT_DIR = path.join('projects', PROJECT_ID);
const STATE_DIR = path.join(PROJECT_DIR, 'state');
const CONFIG_PATH = path.join(PROJECT_DIR, 'launch-config.json');

if (!fs.existsSync(PROJECT_DIR)) {
    console.error(`错误: 项目 ${PROJECT_ID} 不存在`);
    process.exit(1);
}

console.log('🚀 准备启动 Workers');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log(`项目: ${PROJECT_ID}`);
console.log(`模式: ${MODE}`);
console.log('');

// 根据模式加载不同的 Worker 配置
let workers = [];

switch (MODE) {
    case 'new':
        workers = loadNewWorkers();
        break;
    case 'incremental':
        workers = loadIncrementalWorkers();
        break;
    case 'resume':
        workers = loadResumedWorkers();
        break;
    default:
        console.error(`未知模式: ${MODE}`);
        process.exit(1);
}

console.log(`找到 ${workers.length} 个 Workers 待启动`);
console.log('');

// 显示 Worker 列表
workers.forEach((worker, index) => {
    console.log(`${index + 1}. ${worker.id}`);
    console.log(`   模块: ${worker.name}`);
    console.log(`   任务: ${worker.taskPreview}`);
    if (worker.contextSource) {
        console.log(`   上下文: ${worker.contextSource}`);
    }
    console.log('');
});

// 生成 OpenClaw 配置
const launchConfig = {
    version: '2.0',
    projectId: PROJECT_ID,
    mode: MODE,
    createdAt: new Date().toISOString(),
    workers: workers.map(w => ({
        id: w.id,
        label: `${w.id}-${PROJECT_ID}`,
        runtime: 'subagent',
        task: w.fullTask,
        context: w.context || {}
    })),
    // 添加建议的启动命令
    suggestedCommands: workers.map(w => 
        `sessions_spawn --label "${w.id}-${PROJECT_ID}" --runtime subagent --task "${w.taskPreview}"`
    )
};

// 保存配置
fs.writeFileSync(CONFIG_PATH, JSON.stringify(launchConfig, null, 2));

// 生成执行脚本
const execScript = generateExecutionScript(launchConfig);
fs.writeFileSync(
    path.join(PROJECT_DIR, 'execute.sh'),
    execScript
);
fs.chmodSync(path.join(PROJECT_DIR, 'execute.sh'), '755');

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('');
console.log('✅ 启动配置已生成');
console.log('');
console.log('配置文件:');
console.log(`  ${CONFIG_PATH}`);
console.log('');

if (MODE === 'incremental') {
    console.log('📝 增量任务模式');
    console.log('   基于当前会话上下文生成 Workers');
    console.log('');
}

if (MODE === 'resume') {
    console.log('🔄 恢复任务模式');
    console.log('   从历史记忆恢复未完成的 Workers');
    console.log('');
}

console.log('启动方式:');
console.log('  1. 自动: Manager 读取配置并执行 sessions_spawn');
console.log('  2. 手动: 运行 ./execute.sh');
console.log('');
console.log('或者在当前会话中使用:');
console.log(`  /mao execute ${PROJECT_ID}`);

// 辅助函数
function loadNewWorkers() {
    const workers = [];
    const stateFiles = fs.readdirSync(STATE_DIR)
        .filter(f => f.startsWith('worker-') && f.endsWith('.json'))
        .sort();
    
    stateFiles.forEach(stateFile => {
        const workerId = path.basename(stateFile, '.json');
        const statePath = path.join(STATE_DIR, stateFile);
        const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
        
        if (state.status === 'pending') {
            workers.push({
                id: workerId,
                name: state.name,
                taskPreview: state.notes || '完成分配的模块开发任务',
                fullTask: generateWorkerTask(workerId, state, PROJECT_ID),
                context: {}
            });
        }
    });
    
    return workers;
}

function loadIncrementalWorkers() {
    const workers = [];
    
    // 读取当前会话上下文（从环境变量或文件）
    const sessionContext = loadSessionContext();
    
    // 基于上下文创建增量 Workers
    const incrementalTasks = detectIncrementalTasks(sessionContext);
    
    incrementalTasks.forEach((task, index) => {
        const workerId = `worker-inc-${String(index + 1).padStart(2, '0')}`;
        workers.push({
            id: workerId,
            name: task.name,
            taskPreview: task.preview,
            fullTask: generateIncrementalTask(workerId, task, sessionContext),
            context: sessionContext,
            contextSource: 'current-session'
        });
    });
    
    return workers;
}

function loadResumedWorkers() {
    const workers = [];
    
    // 读取历史记忆
    const memoryContext = loadMemoryContext();
    
    // 找到未完成的任务
    const stateFiles = fs.readdirSync(STATE_DIR)
        .filter(f => f.startsWith('worker-') && f.endsWith('.json'))
        .sort();
    
    stateFiles.forEach(stateFile => {
        const workerId = path.basename(stateFile, '.json');
        const statePath = path.join(STATE_DIR, stateFile);
        const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
        
        // 恢复暂停或失败的 Workers
        if (state.status === 'paused' || state.status === 'failed') {
            workers.push({
                id: workerId,
                name: state.name,
                taskPreview: `恢复: ${state.notes || state.name}`,
                fullTask: generateResumedTask(workerId, state, memoryContext),
                context: memoryContext,
                contextSource: 'memory-history'
            });
        }
    });
    
    return workers;
}

function loadSessionContext() {
    // 尝试从环境变量或文件读取当前会话上下文
    try {
        // 读取最近的会话文件
        const sessionPath = process.env.OPENCLAW_CURRENT_SESSION;
        if (sessionPath && fs.existsSync(sessionPath)) {
            return JSON.parse(fs.readFileSync(sessionPath, 'utf8'));
        }
    } catch (e) {
        // 忽略错误，返回空上下文
    }
    
    return {
        type: 'session',
        timestamp: new Date().toISOString(),
        notes: '基于当前会话上下文'
    };
}

function detectIncrementalTasks(context) {
    // 基于上下文检测增量任务
    // 这里可以实现智能任务检测逻辑
    
    return [
        {
            name: '上下文分析',
            preview: '分析当前会话，提取关键决策点'
        },
        {
            name: '增量实现',
            preview: '基于上下文实现增量功能'
        }
    ];
}

function loadMemoryContext() {
    // 读取 ai-memory-system 中的相关记忆
    const memoryPath = '/home/bruce/.openclaw/workspace/ai-memory-system/Memory/L1-episodic';
    
    try {
        const files = fs.readdirSync(memoryPath)
            .filter(f => f.endsWith('.md'))
            .sort()
            .slice(-5); // 最近5个记忆
        
        return {
            type: 'memory',
            recentMemories: files,
            notes: '基于历史记忆上下文'
        };
    } catch (e) {
        return {
            type: 'memory',
            recentMemories: [],
            notes: '无法读取历史记忆'
        };
    }
}

function generateWorkerTask(workerId, state, projectId) {
    return `## Worker: ${workerId}

**所属项目**: ${projectId}
**模块名称**: ${state.name}

### 任务目标
${state.notes || '完成分配的模块开发任务'}

### 交付物
${(state.deliverables || []).map(d => `- ${d}`).join('\n')}

### 状态文件
${path.join('projects', projectId, 'state', `${workerId}.json`)}

### 执行要求
1. 启动时更新状态为 "running"
2. 每完成一个交付物，更新 "completed_deliverables"
3. 定期更新 "progress_percent"
4. 遇到阻塞立即更新 "blockers"
5. 完成后更新状态为 "completed"

### 报告要求
完成后在 /home/bruce/.openclaw/workspace/memory-system-2.0/REPORTS/${workerId}.md 提交报告
`;
}

function generateIncrementalTask(workerId, task, context) {
    return `## Worker: ${workerId} (增量任务)

**任务类型**: 增量实现
**上下文来源**: ${context.notes || '当前会话'}

### 任务目标
${task.preview}

### 上下文信息
${JSON.stringify(context, null, 2)}

### 执行要求
1. 分析提供的上下文
2. 识别需要增量实现的功能点
3. 生成相应的代码或文档
4. 更新项目状态文件

### 报告位置
/home/bruce/.openclaw/workspace/memory-system-2.0/REPORTS/${workerId}.md
`;
}

function generateResumedTask(workerId, state, context) {
    return `## Worker: ${workerId} (恢复任务)

**原状态**: ${state.status}
**历史进度**: ${state.progress_percent}%

### 任务目标
恢复并继续: ${state.name}

### 历史上下文
${JSON.stringify(context, null, 2)}

### 恢复检查清单
- [ ] 检查已完成的工作
- [ ] 验证未完成的交付物
- [ ] 识别阻塞原因
- [ ] 继续实现剩余功能

### 报告位置
/home/bruce/.openclaw/workspace/memory-system-2.0/REPORTS/${workerId}-resumed.md
`;
}

function generateExecutionScript(config) {
    const workerCommands = config.workers.map(w => `
echo "启动 ${w.id}..."
# 命令: openclaw sessions spawn --label "${w.label}" --runtime subagent --task "..."
# 实际执行需要 Manager 权限
echo "  配置: ${w.label}"
`).join('\n');

    return `#!/bin/bash
# execute.sh - 执行 Worker 启动
# 项目: ${config.projectId}
# 模式: ${config.mode}

echo "🚀 启动 Workers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "项目: ${config.projectId}"
echo "Workers: ${config.workers.length}"
echo ""

${workerCommands}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 配置已准备"
echo ""
echo "注意: 实际启动需要 Manager 执行以下命令:"
echo ""
${config.suggestedCommands.map(cmd => `echo "  ${cmd}"`).join('\n')}
echo ""
echo "或在 Manager 会话中使用: /mao execute ${config.projectId}"
`;
}

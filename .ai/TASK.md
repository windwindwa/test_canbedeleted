# 任务：节点1 / 目标1 — 建立基线（NODE: 1）

> 四节点泡测 · .ai/ 结构 · 重新开跑 2026-07-28

## 目标
建立基线产物 `.ai/outputs/node1.txt`，含 `baseline=42`，供后续节点逐级使用。

## 步骤（参考命令，可按实际微调）
1. 确保产物目录 —— 参考：`mkdir -p .ai/outputs`
2. 打印主机名与时间 —— 参考：`hostname`、`date`
3. 计算基线值 7*6 —— 参考：`echo $((7 * 6))`（期望 42）
4. 写入基线文件并显示 —— 参考：
   `printf "host=%s\ntime=%s\nbaseline=%s\n" "$(hostname)" "$(date)" "$((7 * 6))" > .ai/outputs/node1.txt`
   然后 `cat .ai/outputs/node1.txt`

## 成功标准
- `.ai/outputs/node1.txt` 含一行 `baseline=42`
- 各步退出码为 0

## 结果记录要求
- 在 `.ai/RESULT.md` 结论区**第一行**写：`NODE: 1`
- 在详情里写出 `.ai/outputs/node1.txt` 的完整内容

## 禁止
- 不要删除已有文件
- 不要修改 `.ai/` 下的 supervised-runner.yaml、TASK.md、PLAN.md、watch-and-run.sh
- 不要 force push

# 任务：节点1 / 目标1 — 建立基线（NODE: 1）

## 目标
在容器里建立一个基线产物文件 `node1.txt`，供节点2使用。

## 步骤（参考命令，可按实际微调）
1. 打印主机名与时间，确认环境 —— 参考：`hostname`、`date`
2. 计算基线值 7*6 —— 参考：`echo $((7 * 6))`（期望 42）
3. 写入基线文件 —— 参考：
   `printf "host=%s\ntime=%s\nbaseline=%s\n" "$(hostname)" "$(date)" "$((7 * 6))" > node1.txt`
   然后 `cat node1.txt`

## 成功标准
- `node1.txt` 被创建，且包含一行 `baseline=42`
- 各步退出码为 0

## 结果记录要求
- 在 RESULT.md 结论区**第一行**写：`NODE: 1`
- 在详情里明确写出 `node1.txt` 的完整内容

## 禁止
- 不要删除任何已有文件
- 不要修改 supervised-runner.yaml、TASK.md、PLAN.md、watch-and-run.sh 本身
- 不要 force push

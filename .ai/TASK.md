# 任务：节点2 / 目标2 — 基线 +100（NODE: 2）

## 前提
容器本地存在 `.ai/outputs/node1.txt`（含 `baseline=42`）。

## 目标
读取 node1 的 baseline，+100，产出 `.ai/outputs/node2.txt`（含 `result=142`）。

## 步骤（参考命令，可按实际微调）
1. 确保产物目录 —— 参考：`mkdir -p .ai/outputs`
2. 读取基线值 —— 参考：`grep '^baseline=' .ai/outputs/node1.txt | cut -d= -f2`（期望 42）
3. 计算 +100 —— 参考：`echo $(( $(grep '^baseline=' .ai/outputs/node1.txt | cut -d= -f2) + 100 ))`（期望 142）
4. 写入并显示 —— 参考：
   `printf "result=%s\n" "$(( $(grep '^baseline=' .ai/outputs/node1.txt | cut -d= -f2) + 100 ))" > .ai/outputs/node2.txt`
   然后 `cat .ai/outputs/node2.txt`

## 成功标准
- `.ai/outputs/node2.txt` 含一行 `result=142`
- 各步退出码为 0

## 结果记录要求
- 在 `.ai/RESULT.md` 结论区**第一行**写：`NODE: 2`
- 在详情里写出 `.ai/outputs/node2.txt` 的完整内容

## 禁止
- 不要删除 `.ai/outputs/node1.txt`
- 不要修改 `.ai/` 下的 supervised-runner.yaml、TASK.md、PLAN.md、watch-and-run.sh
- 不要 force push

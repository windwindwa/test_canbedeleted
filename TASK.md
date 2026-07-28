# 任务：节点2 / 目标2 — 基于节点1产物（NODE: 2）

## 前提
节点1已完成，容器本地存在 `node1.txt`（含 `baseline=42`）。

## 目标
读取 `node1.txt` 的 baseline 值，加 100，产出 `node2.txt`（含 `result=142`）。

## 步骤（参考命令，可按实际微调）
1. 读取基线值 —— 参考：`grep '^baseline=' node1.txt | cut -d= -f2`（期望 42）
2. 计算 baseline+100 —— 参考：`echo $(( $(grep '^baseline=' node1.txt | cut -d= -f2) + 100 ))`（期望 142）
3. 写入结果文件并显示 —— 参考：
   `printf "result=%s\n" "$(( $(grep '^baseline=' node1.txt | cut -d= -f2) + 100 ))" > node2.txt`
   然后 `cat node2.txt`

## 成功标准
- `node2.txt` 含一行 `result=142`
- 各步退出码为 0

## 结果记录要求
- 在 RESULT.md 结论区**第一行**写：`NODE: 2`
- 在详情里写出 `node2.txt` 的完整内容

## 禁止
- 不要删除 `node1.txt`
- 不要修改 supervised-runner.yaml、TASK.md、PLAN.md、watch-and-run.sh 本身
- 不要 force push

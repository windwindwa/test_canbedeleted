# 任务:流水线连通性验证(第 1 次实验)

## 目标
验证 Goose 能:拉取本仓库 → 逐步执行下面这些简单命令 → 记录每步结果 → 把 RESULT.md 推回。
这一轮全部是安全、只读或只新增的命令,不改动任何已有文件。

## 步骤(参考命令,可按实际微调)
1. 打印环境信息,确认在容器里 —— 参考:`uname -a`、`whoami`、`pwd`、`date`
2. 确认在正确的仓库和分支 —— 参考:`git rev-parse --abbrev-ref HEAD`、`git log -1 --oneline`
3. 创建一个证明文件 —— 参考:`echo "goose was here at $(date)" > proof.txt`,然后 `cat proof.txt`
4. 做一个简单计算,验证能拿到命令输出 —— 参考:`echo $((2 + 40))`(期望输出 42)

## 成功标准
- 每一步的命令、关键输出、退出码都被记录进 RESULT.md
- proof.txt 被创建且内容包含时间戳
- 第 4 步输出为 42
- RESULT.md 顶部有一段【结论】

## 禁止
- 不要删除任何已有文件
- 不要修改 supervised-runner.yaml 和 TASK.md 本身
- 不要 force push

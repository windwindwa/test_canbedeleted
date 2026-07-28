# 实验计划：四节点接力（模拟机械臂 节点1→2→3→4 / 目标逐级依赖）

**目的**：用最简单的 shell 任务，验证「大脑事件驱动地判定当前节点是否完成 → 完成则推进下一节点，未完成则修复重派」这套编排机制，并把链路拉长到 4 节点做"泡测"。预演 [[端到端落地路线图 — 六节点 + 工作循环]] 的多节点逐级依赖推进。

**依赖链（每节点读上一节点的产物）**：`node1=42` → `node2=142` → `node3=284` → `node4=200`。

## 角色与回路

```mermaid
graph LR
    B[大脑 Claude / Mac<br/>Monitor 事件驱动 + 判定 + 派发/修复] -- push TASK.md --> H[GitHub]
    H -- watcher 检测更新 --> G[Goose / Ubuntu<br/>跑 recipe]
    G -- push RESULT.md --> H
    H -- Monitor 事件叫醒 --> B
```

- **大脑（我）**：写/改 TASK.md 并 push；Monitor 在远端 RESULT.md 变化时叫醒我；判定当前节点、派发下一节点或修复重派。等待期零 LLM 成本。
- **执行端（Goose@Ubuntu）**：`watch-and-run.sh` 检测远端 TASK.md 更新 → 跑 `supervised-runner.yaml` → 回写 RESULT.md。

## 状态机（我据仓库现状每轮重新推导，不靠记忆）

对齐用 **TASK.md 顶部 `NODE: k`** 与 **RESULT.md 结论区 `NODE: k`**。末节点为 **4**。

| TASK 的 NODE | RESULT 的 NODE | RESULT 状态 | 我的动作 |
|---|---|---|---|
| k | ≠ k（旧/无） | — | 本节点结果还没回来 → **等** |
| k | k | 成功 | 本节点**完成** → 派发节点 k+1（改 TASK.md、commit、push） |
| k | k | 失败/不达标 | **未完成** → 诊断 RESULT.md，修正 TASK.md 重派，留在本节点 |
| 4 | 4 | 成功 | 四节点全完成 → **停止 Monitor** |

## 各节点

### 节点 1 / 目标 1：建立基线
- 派发（`NODE: 1`）：创建 `node1.txt`，含 `baseline=42`（由 `7*6`）。
- 成功标准：RESULT `NODE: 1`；`node1.txt` 含 `baseline=42`；退出码 0。
- [ ] 完成

### 节点 2 / 目标 2：基线 +100
- 前提：`node1.txt` 存在。
- 派发（`NODE: 2`）：读 `node1.txt` 的 42，+100，产出 `node2.txt` 含 `result=142`。
- 成功标准：RESULT `NODE: 2`；`node2.txt` 含 `result=142`；退出码 0。
- [ ] 完成

### 节点 3 / 目标 3：上一步 ×2
- 前提：`node2.txt` 存在。
- 派发（`NODE: 3`）：读 `node2.txt` 的 142，×2，产出 `node3.txt` 含 `result=284`。
- 成功标准：RESULT `NODE: 3`；`node3.txt` 含 `result=284`；退出码 0。
- [ ] 完成

### 节点 4 / 目标 4：上一步 −84（收尾）
- 前提：`node3.txt` 存在。
- 派发（`NODE: 4`）：读 `node3.txt` 的 284，−84，产出 `node4.txt` 含 `result=200`。
- 成功标准：RESULT `NODE: 4`；`node4.txt` 含 `result=200`；退出码 0。
- [ ] 完成

> [!note] 依赖为什么成立
> 各 `nodeK.txt` 由 Goose 在同一 Ubuntu 执行端本地产出（未跟踪、不回传但留在本地），下一节点在同一容器直接读得到。我这边靠 RESULT.md 记录的内容验证。

## Loop 协议（Monitor 事件驱动）

1. Monitor 后台每 60s `git fetch`，仅当远端 `RESULT.md` 对象 id 变化才 echo 一行、叫醒我（等待期零 LLM）。
2. 被叫醒 → `git fetch`，读 RESULT 的 `NODE` + 状态，按状态机表判定。
3. 据判定：派发下一节点 / 修复重派 / 停止 Monitor。
4. 每次简报给用户。

## 开跑前置

1. **Ubuntu**：`watch-and-run.sh TASK.md` 在 tmux 里常驻；`goose config set-mode approve`；结果出来前在 tmux 里给 goose 审批放行。
2. **Mac（我）**：能 push；挂一个 Monitor 盯远端 RESULT.md。

## 相关
- [[Goose 监督式命令中继]] — 工具与 recipe
- [[端到端落地路线图 — 六节点 + 工作循环]] — 预演的真实项目结构

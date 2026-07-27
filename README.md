# goose-relay-experiment

一个验证性实验仓库,用来跑通"大脑 ↔ 执行端"的接力流程:

```
Claude(大脑)写 TASK.md ──push──> GitHub ──pull──> Goose(容器里执行)
                                                      │
Claude 读 RESULT.md <──push── GitHub <──push── 写 RESULT.md、逐步执行
```

## 文件

- `supervised-runner.yaml` — Goose recipe,定义固定流程(拉取→读任务→执行→记录→浅层处理错误→写 RESULT.md→推回)。
- `TASK.md` — 大脑下发的任务/交付文件。执行端读它、照它干。
- `RESULT.md` — 执行端产出的结果(顶部结论 + 详情)。由 Goose 生成并推回。

## 执行端怎么跑(在带 Goose 的容器里)

```bash
git clone <本仓库地址> && cd goose-relay-experiment
# 监督期:保持逐条审批模式
goose config set-mode approve
# 跑固定流程
goose run --recipe ./supervised-runner.yaml
```

跑完后,`RESULT.md` 会被提交并推回本仓库。

#!/usr/bin/env bash
# watch-and-run.sh — 定时用 git 轮询远端指定目标,只要「远端版本 ≠ 上次已执行的版本」就前台运行 goose recipe。
#
# 有状态:用 .ai/.state/ 下的状态文件记住上次执行的目标版本。
#   → 启动时若远端有未执行的新任务(首次、或任务已在),立即执行,无需 --run-on-start;已执行过的不重复跑。
#
# 检测:git fetch 后取目标在 origin/<branch> 上的对象 id(文件=blob / 目录=tree)。
# 可见性:前台、同步调用 goose,继承 TTY——像手敲一样可见、approve 模式可审批。请跑在 tmux 里。一次只跑一个。
#
# 用法：./.ai/watch-and-run.sh [选项] <检测目标>
# 选项：
#   --interval SEC   轮询间隔秒数(默认 60)
#   --recipe PATH    要跑的 recipe(默认 .ai/supervised-runner.yaml)
#   --branch NAME    分支(默认当前分支)
#   --once           只跑一轮(测试用)
#   --dry-run        只打印,不真正调 goose(测试用)
#   -h, --help       显示帮助
#
# 例：tmux new -s relay; ./.ai/watch-and-run.sh .ai/TASK.md

set -uo pipefail

INTERVAL=60
RECIPE=".ai/supervised-runner.yaml"
BRANCH=""
ONCE=0
DRY_RUN=0
TARGET=""

usage() { sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'; }
log() { echo "[$(date '+%F %T')] $*"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --interval) INTERVAL="${2:?}"; shift 2;;
    --recipe)   RECIPE="${2:?}";   shift 2;;
    --branch)   BRANCH="${2:?}";   shift 2;;
    --once)     ONCE=1;    shift;;
    --dry-run)  DRY_RUN=1; shift;;
    --run-on-start) log "提示：--run-on-start 已废弃(有状态版本会自动跑未执行的任务),忽略。"; shift;;
    -h|--help)  usage; exit 0;;
    -*) echo "未知选项：$1" >&2; usage; exit 2;;
    *)  TARGET="$1"; shift;;
  esac
done

[[ -n "$TARGET" ]] || { echo "错误：必须提供检测目标(文件或目录)。" >&2; usage; exit 2; }
command -v git >/dev/null 2>&1 || { echo "错误：未安装 git。" >&2; exit 1; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "错误：不在 git 仓库内；请在 clone 出来的仓库里运行。" >&2; exit 1; }
[[ -n "$BRANCH" ]] || BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# 可移植地求仓库相对路径(不依赖 GNU realpath --relative-to)
if _adir="$(cd "$(dirname -- "$TARGET")" 2>/dev/null && pwd)"; then
  _abs="$_adir/$(basename -- "$TARGET")"; RELPATH="${_abs#"$REPO_ROOT"/}"
else
  RELPATH="$TARGET"
fi
# 状态文件放 .ai/.state/,按目标区分
STATE_DIR="$REPO_ROOT/.ai/.state"; mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/last-run.$(printf '%s' "$RELPATH" | tr '/ ' '__')"

# 远端该目标当前版本(对象 id);fetch 或对象不存在则返回非 0
remote_version() {
  git fetch -q origin "$BRANCH" 2>/dev/null || return 1
  git rev-parse "origin/$BRANCH:$RELPATH" 2>/dev/null || return 1
}

run_goose() {
  log "远端有新任务 → 运行 goose recipe：$RECIPE"
  if [[ "$DRY_RUN" == 1 ]]; then
    log "[dry-run] 本应执行：goose run --recipe \"$RECIPE\""
  else
    goose run --recipe "$RECIPE"   # 前台、继承 TTY：可见、可交互审批
    log "goose 运行结束(退出码 $?)"
  fi
}

log "开始监视远端(有状态)：target=$RELPATH  branch=$BRANCH  interval=${INTERVAL}s  recipe=$RECIPE"
LAST="$(cat "$STATE_FILE" 2>/dev/null || true)"
log "上次已执行版本：${LAST:-<无，首次>}"

while true; do
  CUR="$(remote_version || true)"
  if [[ -z "$CUR" ]]; then
    log "警告：获取远端目标版本失败(fetch 失败或目标不存在),跳过本轮。"
  elif [[ "$CUR" != "$LAST" ]]; then
    log "远端有新任务：${LAST:-<无>} → $CUR"
    run_goose
    LAST="$CUR"; printf '%s\n' "$LAST" > "$STATE_FILE"
  fi
  [[ "$ONCE" == 1 ]] && break
  sleep "$INTERVAL"
done

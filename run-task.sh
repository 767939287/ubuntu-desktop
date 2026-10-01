#!/bin/bash
# ============================================================
# 定时任务包装脚本
# 根据 HEADLESS 开关决定是否使用显示，并把参数透传给目标脚本
# ------------------------------------------------------------
#   HEADLESS=1  无头：不设置 DISPLAY，传入 --headless
#   HEADLESS=0  有头：设置 DISPLAY=:1，不传 --headless
#
# 用法:
#   run-task.sh /home/kasm-user/app.py
#   run-task.sh /home/kasm-user/app.py --some-arg
# ============================================================

set -e

# 读取 start-cron.sh 固化的运行时环境（若存在）
[ -f /etc/default/app-cron-env ] && . /etc/default/app-cron-env

export TZ="${TZ:-Asia/Shanghai}"
export HEADLESS="${HEADLESS:-0}"

if [ "$HEADLESS" = "1" ] || [ "$HEADLESS" = "true" ]; then
    # 无头：不设置 DISPLAY，附加 --headless
    unset DISPLAY
    EXTRA_ARGS="--headless"
    echo "[run-task] $(date '+%F %T') HEADLESS=1 (无头模式)"
else
    # 有头：连接 Kasm 虚拟屏
    export DISPLAY="${DISPLAY:-:1}"
    EXTRA_ARGS=""
    echo "[run-task] $(date '+%F %T') HEADLESS=0 (有头模式, DISPLAY=${DISPLAY})"
fi

# 目标脚本（第一个参数）
TARGET="$1"
shift || true

if [ -z "$TARGET" ]; then
    echo "[run-task] 错误: 未指定目标脚本" >&2
    exit 1
fi

# 执行：EXTRA_ARGS 需要在目标脚本后传入
# shellcheck disable=SC2086
exec /usr/bin/python3 "$TARGET" $EXTRA_ARGS "$@"

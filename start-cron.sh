#!/bin/bash
# ============================================================
# 容器启动时启用 cron 定时任务（与实体机行为一致）
# 由 Kasm Workspaces (s6-overlay) 在启动阶段调用
# ============================================================

set -e

# 时区
export TZ="${TZ:-Asia/Shanghai}"

# 确保日志文件存在
touch /var/log/cron.log

# 安装用户 crontab（等同于实体机上 `crontab -e`）
# 模板在构建时已放到 /usr/local/etc/app-crontab
if [ -f /usr/local/etc/app-crontab ]; then
    mkdir -p /var/spool/cron/crontabs
    cp /usr/local/etc/app-crontab /var/spool/cron/crontabs/kasm-user
    chown kasm-user:crontab /var/spool/cron/crontabs/kasm-user
    chmod 600 /var/spool/cron/crontabs/kasm-user
fi
# 启动 cron 守护进程（后台）
cron

# 前台跟随日志，避免该进程退出（便于 docker logs 查看任务输出）
exec tail -F /var/log/cron.log


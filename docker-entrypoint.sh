#!/bin/sh
# 自举：/docs 没有 index.html 时，从镜像内置模板拷入一套可离线运行的范例站点，
# 避免新用户遇到 "No docs found" 直接退出，同时给出可照着改的格式样例。
# 只补缺失文件，绝不覆盖用户已有内容；已有 index.html 则完全不碰。
# 设 DOCSIFY_AUTO_INIT=false 可关闭自举，恢复严格模式。
set -e

TEMPLATE_DIR="/opt/docsify-template"
: "${DOCSIFY_AUTO_INIT:=true}"

if [ "$DOCSIFY_AUTO_INIT" = "true" ] && [ ! -f /docs/index.html ]; then
  if [ -w /docs ]; then
    echo "[docsify-server] /docs 无 index.html —— 生成离线范例站点..."
    for item in index.html README.md .nojekyll assets; do
      [ -e "/docs/$item" ] || cp -r "$TEMPLATE_DIR/$item" "/docs/$item"
    done
    echo "[docsify-server] 范例站点已就绪，编辑 /docs/README.md 开始撰写。"
  else
    echo "[docsify-server] 警告：/docs 无 index.html 且不可写，docsify 可能无法启动。" >&2
  fi
fi

# exec 让 docsify 作为 PID 1 接收 SIGTERM，实现优雅停止
exec docsify serve .

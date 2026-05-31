#!/bin/bash
# 环境依赖检查脚本

set -e

echo "=== 视频转录环境检查 ==="
echo ""

MISSING=0

# 检查 ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
    VERSION=$(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)
    echo "✓ ffmpeg 已安装 (v${VERSION})"
else
    echo "✗ ffmpeg 未安装"
    echo "  安装命令:"
    echo "    Ubuntu/Debian: sudo apt install ffmpeg"
    echo "    macOS: brew install ffmpeg"
    echo "    Windows: choco install ffmpeg"
    MISSING=1
fi

# 检查 yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
    VERSION=$(yt-dlp --version)
    echo "✓ yt-dlp 已安装 (v${VERSION})"
else
    echo "✗ yt-dlp 未安装"
    echo "  安装命令: pip install yt-dlp"
    MISSING=1
fi

# 检查 python3
if command -v python3 >/dev/null 2>&1; then
    VERSION=$(python3 --version | cut -d' ' -f2)
    echo "✓ python3 已安装 (v${VERSION})"
else
    echo "✗ python3 未安装"
    MISSING=1
fi

# 检查 requests 模块
if python3 -c "import requests" 2>/dev/null; then
    echo "✓ requests 模块已安装"
else
    echo "✗ requests 模块未安装"
    echo "  安装命令: pip install requests"
    MISSING=1
fi

# 检查 API Key
echo ""
if [ -n "$GROQ_API_KEY" ]; then
    echo "✓ GROQ_API_KEY 已设置"
elif [ -n "$OPENAI_API_KEY" ]; then
    echo "✓ OPENAI_API_KEY 已设置"
else
    echo "✗ 未检测到转录 API Key"
    echo "  设置方法:"
    echo "    export GROQ_API_KEY='gsk_your_key_here'"
    echo ""
    echo "  获取免费 API Key:"
    echo "    https://console.groq.com/"
    MISSING=1
fi

echo ""

if [ $MISSING -eq 0 ]; then
    echo "✓ 环境检查通过！可以开始转录"
    exit 0
else
    echo "⚠ 有依赖缺失，请先安装后再使用"
    exit 1
fi

#!/bin/bash
# 下载视频音频 (YouTube / Bilibili)

set -e

URL="$1"
OUTPUT_DIR="${2:-videos}"
FORMAT="${3:-wav}"

if [ -z "$URL" ]; then
    echo "用法: $0 <视频URL> [输出目录] [音频格式]"
    echo ""
    echo "示例:"
    echo "  $0 https://www.youtube.com/watch?v=abc123"
    echo "  $0 https://www.bilibili.com/video/BV1234 my_videos"
    echo "  $0 https://www.youtube.com/watch?v=abc123 . mp3"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "=== 下载视频音频 ==="
echo "URL: $URL"
echo "输出: $OUTPUT_DIR/"
echo ""

# 检测平台
if echo "$URL" | grep -q "youtube.com\|youtu.be"; then
    echo "平台: YouTube"
elif echo "$URL" | grep -q "bilibili.com"; then
    echo "平台: Bilibili"
else
    echo "平台: 其他"
fi

echo ""

# 下载
yt-dlp \
    -x \
    --audio-format "$FORMAT" \
    --audio-quality 0 \
    -o "$OUTPUT_DIR/%(title)s.%(ext)s" \
    --no-overwrites \
    --print filename \
    "$URL" 2>/dev/null | tail -1

echo ""
echo "=== 下载完成 ==="
echo ""
ls -lh "$OUTPUT_DIR"/*."$FORMAT" 2>/dev/null | tail -1

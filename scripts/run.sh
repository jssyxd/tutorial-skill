#!/bin/bash
# 一键视频转录流程

set -e

# 参数
VIDEO_URL="${1}"
OUTPUT_DIR="${2:-output}"
CHUNK_SECONDS="${3:-600}"
LANGUAGE="${4:-auto}"

if [ -z "$VIDEO_URL" ]; then
    echo "用法: $0 <视频URL> [输出目录] [分段秒数] [语言]"
    echo ""
    echo "示例:"
    echo "  $0 https://www.youtube.com/watch?v=abc123"
    echo "  $0 https://www.bilibili.com/video/BV1234 output 300 zh"
    echo ""
    echo "语言代码: en(英语) zh(中文) ja(日语) auto(自动检测)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="/tmp/video-transcribe-$$"

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "╔══════════════════════════════════════════════════╗"
echo "║           视频教程转录 - 一键流程                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "视频: $VIDEO_URL"
echo "输出: $OUTPUT_DIR/"
echo "分段: ${CHUNK_SECONDS}秒"
echo "语言: $LANGUAGE"
echo ""

# Step 1: 检查环境
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/6: 环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/check_env.sh" || {
    echo "请先安装缺失的依赖"
    exit 1
}
echo ""

# Step 2: 下载
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/6: 下载视频音频"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/download.sh" "$VIDEO_URL" "$TEMP_DIR" "wav"
echo ""

# Step 3: 找到下载的文件
AUDIO_FILE=$(ls "$TEMP_DIR"/*.wav 2>/dev/null | head -1)
if [ -z "$AUDIO_FILE" ]; then
    echo "错误: 下载后未找到音频文件"
    exit 1
fi
echo "音频文件: $(basename "$AUDIO_FILE")"
echo ""

# Step 4: 分切
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/6: 分切长音频"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python3 "$SCRIPT_DIR/split.py" "$AUDIO_FILE" "$TEMP_DIR" "$CHUNK_SECONDS"
echo ""

# Step 5: 转录
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/6: 语音转文字"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/transcribe.sh" "$TEMP_DIR" "$OUTPUT_DIR" "$LANGUAGE"
echo ""

# Step 6: 合并
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/6: 合并转录结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
VIDEO_NAME=$(basename "${AUDIO_FILE%.wav}")
python3 "$SCRIPT_DIR/merge.py" "$OUTPUT_DIR" "$OUTPUT_DIR/${VIDEO_NAME}-full.txt"
echo ""

# 清理临时文件
rm -rf "$TEMP_DIR"

# 完成
echo "╔══════════════════════════════════════════════════╗"
echo "║               ✓ 转录完成！                      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "输出文件:"
ls -lh "$OUTPUT_DIR"/*.txt 2>/dev/null
echo ""
echo "提示: 可以用 cat 查看完整转录内容"
echo "  cat $OUTPUT_DIR/${VIDEO_NAME}-full.txt"

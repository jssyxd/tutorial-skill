#!/bin/bash
# 批量转录音频片段

set -e

INPUT_DIR="${1:-/tmp}"
OUTPUT_DIR="${2:-output}"
LANGUAGE="${3:-auto}"
API_KEY="${GROQ_API_KEY}"

if [ -z "$API_KEY" ]; then
    echo "错误: GROQ_API_KEY 未设置"
    echo "设置方法: export GROQ_API_KEY='your_key_here'"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "=== Groq Whisper 转录 ==="
echo "输入: $INPUT_DIR/"
echo "输出: $OUTPUT_DIR/"
echo "语言: $LANGUAGE"
echo ""

# 查找音频片段
CHUNKS=($(ls "$INPUT_DIR"/short_*.wav 2>/dev/null | sort))
TOTAL=${#CHUNKS[@]}

if [ $TOTAL -eq 0 ]; then
    echo "未找到音频片段 (short_*.wav)"
    exit 1
fi

echo "找到 $TOTAL 个片段待转录"
echo ""

SUCCESS=0
FAILED=0

for i in "${!CHUNKS[@]}"; do
    INPUT="${CHUNKS[$i]}"
    BASENAME=$(basename "${INPUT%.wav}")
    OUTPUT="$OUTPUT_DIR/${BASENAME}.txt"
    
    echo -n "[$(($i+1))/$TOTAL] $BASENAME... "
    
    # 构建语言参数
    LANG_PARAM=""
    if [ "$LANGUAGE" != "auto" ]; then
        LANG_PARAM="-F language=$LANGUAGE"
    fi
    
    # 调用 API
    RESULT=$(curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
        -H "Authorization: Bearer $API_KEY" \
        -F "file=@$INPUT" \
        -F "model=whisper-large-v3" \
        $LANG_PARAM \
        -F "response_format=text" \
        --max-time 120)
    
    # 检查结果
    if echo "$RESULT" | grep -q '"error"'; then
        ERROR=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)['error']['message'])" 2>/dev/null || echo "未知错误")
        echo "✗ 失败: $ERROR"
        FAILED=$((FAILED + 1))
    elif [ -z "$RESULT" ]; then
        echo "✗ 失败: 空响应"
        FAILED=$((FAILED + 1))
    else
        echo "$RESULT" > "$OUTPUT"
        CHARS=$(wc -c < "$OUTPUT")
        echo "✓ 完成 (${CHARS} 字符)"
        SUCCESS=$((SUCCESS + 1))
    fi
    
    # 避免请求过快
    sleep 0.5
done

echo ""
echo "=== 转录完成 ==="
echo "成功: $SUCCESS"
echo "失败: $FAILED"

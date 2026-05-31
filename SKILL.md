---
name: tutorial-skill
description: "End-to-end video tutorial transcription pipeline. Downloads YouTube/Bilibili videos, splits long videos, transcribes speech to text via Groq Whisper API, and merges transcripts. Use when user wants to transcribe tutorials, lectures, tech talks, or any video content into text."
---

# Tutorial Skill - 视频教程转录

> 把视频教程变成可搜索、可复制的文字笔记

## 适用场景

- 转录 YouTube/Bilibili 技术教程
- 将会议录音、讲座视频转为文字
- 批量处理多个视频的语音内容
- 生成视频字幕或文字稿

---

## 快速开始

### 1. 环境检查

```bash
# 检查依赖是否齐全
bash scripts/check_env.sh
```

如果缺少工具，会自动提示安装命令。

### 2. 配置 API Key

```bash
# Groq 提供免费额度（每月 14,400 分钟）
# 注册地址: https://console.groq.com/
export GROQ_API_KEY="gsk_your_key_here"
```

### 3. 一键转录

```bash
# 完整流程：下载 → 分切 → 转录 → 合并
bash scripts/run.sh "https://www.youtube.com/watch?v=VIDEO_ID"
```

---

## 完整工作流

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  下载视频    │ → │  提取音频   │ → │  分切长音频  │ → │  API 转录   │
│  (yt-dlp)   │    │  (ffmpeg)   │    │  (>10min)   │    │  (Groq)     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                ↓
                                                          ┌─────────────┐
                                                          │  合并输出   │
                                                          │  (完整稿)   │
                                                          └─────────────┘
```

---

## 详细步骤

### Step 1: 检查环境

```bash
bash scripts/check_env.sh
```

输出示例：
```
=== 环境检查 ===
✓ ffmpeg 已安装
✓ yt-dlp 已安装
✓ python3 已安装
✓ GROQ_API_KEY 已设置
```

缺少工具时的安装命令：

| 工具 | Ubuntu/Debian | macOS |
|------|---------------|-------|
| ffmpeg | `sudo apt install ffmpeg` | `brew install ffmpeg` |
| yt-dlp | `pip install yt-dlp` | `pip install yt-dlp` |

### Step 2: 下载视频

```bash
# YouTube
bash scripts/download.sh "https://www.youtube.com/watch?v=abc123"

# Bilibili
bash scripts/download.sh "https://www.bilibili.com/video/BV1234"

# 自定义输出目录
bash scripts/download.sh "URL" "my_videos"
```

### Step 3: 分切长音频

如果视频超过 10 分钟，需要分切成小段（API 限制 25MB）：

```bash
# 自动分切（默认 10 分钟一段）
python3 scripts/split.py input.wav

# 自定义分切时长（5 分钟）
python3 scripts/split.py input.wav /tmp 300
```

### Step 4: 转录音频

```bash
# 转录所有分片
bash scripts/transcribe.sh /tmp output/
```

### Step 5: 合并结果

```bash
python3 scripts/merge.py output/ final-transcript.txt
```

---

## 批量处理

```bash
# 处理多个视频
VIDEO_URLS=(
    "https://www.youtube.com/watch?v=video1"
    "https://www.youtube.com/watch?v=video2"
    "https://www.bilibili.com/video/BV1234"
)

for url in "${VIDEO_URLS[@]}"; do
    echo "处理: $url"
    bash scripts/run.sh "$url"
done
```

---

## 语言支持

| 语言 | 代码 | 说明 |
|------|------|------|
| 英语 | `en` | 默认 |
| 中文 | `zh` | 普通话 |
| 日语 | `ja` | |
| 韩语 | `ko` | |
| 自动检测 | (不指定) | 推荐 |

```bash
# 指定中文
bash scripts/transcribe.sh /tmp output/ zh

# 自动检测
bash scripts/transcribe.sh /tmp output/ auto
```

---

## API 对比

| API | 免费额度 | 速度 | 推荐度 |
|-----|----------|------|--------|
| **Groq Whisper** | 14,400 分钟/月 | ~10x 实时 | ⭐⭐⭐⭐⭐ |
| OpenAI Whisper | 无 | ~5x 实时 | ⭐⭐⭐ |
| 本地 Whisper | 无限 | ~0.5x 实时 | ⭐⭐ |

**推荐：Groq Whisper** - 免费额度大、速度快、无需 GPU

---

## 常见问题

### 文件太大无法转录
```bash
# 检查文件大小
ls -lh input.wav

# 超过 25MB 需要分切
python3 scripts/split.py input.wav
```

### 转录质量差
- 确保音频清晰，减少背景噪音
- 指定正确的语言代码
- 使用更高采样率的音频源

### API 报错
```bash
# 检查 API Key
echo $GROQ_API_KEY

# 测试连接
curl -s -H "Authorization: Bearer $GROQ_API_KEY" \
    "https://api.groq.com/openai/v1/models" | head
```

---

## 脚本说明

| 脚本 | 功能 | 用法 |
|------|------|------|
| `check_env.sh` | 检查环境依赖 | `bash scripts/check_env.sh` |
| `download.sh` | 下载视频音频 | `bash scripts/download.sh URL` |
| `split.py` | 分切长音频 | `python3 scripts/split.py input.wav` |
| `transcribe.sh` | 批量转录 | `bash scripts/transcribe.sh input_dir output_dir` |
| `merge.py` | 合并转录结果 | `python3 scripts/merge.py dir output.txt` |
| `run.sh` | 一键完整流程 | `bash scripts/run.sh URL` |

---

## License

MIT

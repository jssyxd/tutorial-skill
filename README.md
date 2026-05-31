# Tutorial Skill

> 把视频教程变成可搜索、可复制的文字笔记

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)

## 功能

- 🎬 **下载视频** - 支持 YouTube、Bilibili
- ✂️ **智能分切** - 长视频自动分段处理
- 🗣️ **语音识别** - 99+ 语种支持
- 📝 **转录输出** - 生成完整文字稿

## 快速开始

### 1. 安装依赖

```bash
# Ubuntu/Debian
sudo apt install ffmpeg
pip install yt-dlp requests

# macOS
brew install ffmpeg
pip install yt-dlp requests
```

### 2. 配置 API Key

```bash
# 注册免费 Groq API: https://console.groq.com/
export GROQ_API_KEY="gsk_your_key_here"
```

### 3. 一键转录

```bash
# 转录 YouTube 视频
bash scripts/run.sh "https://www.youtube.com/watch?v=VIDEO_ID"

# 转录 Bilibili 视频
bash scripts/run.sh "https://www.bilibili.com/video/BV1234"

# 指定语言
bash scripts/run.sh "URL" output 600 zh
```

## 输出示例

```
output/
├── Video-Title-full.txt     # 完整转录文本
├── short_Video-Title_000.txt # 分段转录
├── short_Video-Title_001.txt
└── ...
```

## 适用场景

- 技术教程学习笔记
- 会议记录整理
- 视频字幕生成
- 知识库构建

## License

MIT

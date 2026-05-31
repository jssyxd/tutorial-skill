#!/usr/bin/env python3
"""分切长音频为多个小片段"""

import subprocess
import os
import sys
import math

def get_duration(input_file):
    """获取音频时长(秒)"""
    result = subprocess.run([
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        input_file
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f"无法获取时长: {result.stderr}")
    
    return float(result.stdout.strip())

def format_time(seconds):
    """格式化时间"""
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    if h > 0:
        return f"{h}时{m}分{s}秒"
    elif m > 0:
        return f"{m}分{s}秒"
    else:
        return f"{s}秒"

def split_audio(input_file, output_dir="/tmp", chunk_duration=600):
    """
    分切音频文件
    
    Args:
        input_file: 输入音频路径
        output_dir: 输出目录
        chunk_duration: 每段时长(秒), 默认600=10分钟
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # 获取时长
    duration = get_duration(input_file)
    num_chunks = math.ceil(duration / chunk_duration)
    
    print(f"输入文件: {input_file}")
    print(f"总时长: {format_time(duration)}")
    print(f"分段时长: {format_time(chunk_duration)}")
    print(f"分段数量: {num_chunks}")
    print()
    
    if num_chunks == 1:
        print("视频时长未超过分段限制，无需分切")
        return [input_file]
    
    basename = os.path.splitext(os.path.basename(input_file))[0]
    created_files = []
    
    for i in range(num_chunks):
        start = i * chunk_duration
        output_file = os.path.join(output_dir, f"short_{basename}_{i:03d}.wav")
        
        print(f"[{i+1}/{num_chunks}] {format_time(start)} - {format_time(min(start + chunk_duration, duration))}")
        
        subprocess.run([
            "ffmpeg", "-y",
            "-i", input_file,
            "-ss", str(start),
            "-t", str(chunk_duration),
            "-c", "copy",
            output_file
        ], capture_output=True)
        
        created_files.append(output_file)
    
    print()
    print(f"✓ 分切完成，共 {len(created_files)} 段")
    print(f"  输出目录: {output_dir}")
    
    return created_files

def main():
    if len(sys.argv) < 2:
        print("用法: python3 split.py <输入文件> [输出目录] [分段秒数]")
        print()
        print("示例:")
        print("  python3 split.py video.wav")
        print("  python3 split.py video.wav /tmp 300  # 5分钟一段")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "/tmp"
    chunk_duration = int(sys.argv[3]) if len(sys.argv) > 3 else 600
    
    if not os.path.exists(input_file):
        print(f"错误: 文件不存在 - {input_file}")
        sys.exit(1)
    
    split_audio(input_file, output_dir, chunk_duration)

if __name__ == "__main__":
    main()

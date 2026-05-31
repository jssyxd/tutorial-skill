#!/usr/bin/env python3
"""合并转录片段为完整文本"""

import glob
import os
import sys
import re

def merge_transcripts(input_dir, output_file, pattern="short_*.txt"):
    """
    合并转录片段
    
    Args:
        input_dir: 包含转录片段的目录
        output_file: 输出文件路径
        pattern: 文件匹配模式
    """
    # 查找所有转录文件
    files = sorted(glob.glob(os.path.join(input_dir, pattern)))
    
    if not files:
        print(f"未找到匹配的文件: {pattern}")
        print(f"查找目录: {input_dir}")
        return None
    
    print(f"找到 {len(files)} 个转录片段")
    
    # 读取并合并
    merged = []
    total_chars = 0
    
    for f in files:
        with open(f, "r", encoding="utf-8") as file:
            content = file.read().strip()
            if content:
                merged.append(content)
                total_chars += len(content)
    
    # 用空格连接
    final_text = " ".join(merged)
    
    # 清理多余空格
    final_text = re.sub(r' +', ' ', final_text)
    final_text = re.sub(r'\n +', '\n', final_text)
    
    # 写入输出文件
    os.makedirs(os.path.dirname(output_file) or ".", exist_ok=True)
    with open(output_file, "w", encoding="utf-8") as out:
        out.write(final_text)
    
    # 统计信息
    word_count = len(final_text.split())
    
    print()
    print(f"✓ 合并完成")
    print(f"  输出文件: {output_file}")
    print(f"  字符数: {len(final_text):,}")
    print(f"  词数: ~{word_count:,}")
    
    return final_text

def main():
    if len(sys.argv) < 3:
        print("用法: python3 merge.py <输入目录> <输出文件> [文件模式]")
        print()
        print("示例:")
        print("  python3 merge.py output/ final.txt")
        print("  python3 merge.py output/ transcript.txt 'duckdb_*.txt'")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_file = sys.argv[2]
    pattern = sys.argv[3] if len(sys.argv) > 3 else "short_*.txt"
    
    merge_transcripts(input_dir, output_file, pattern)

if __name__ == "__main__":
    main()

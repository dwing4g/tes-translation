#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 我有一个文本文件,其中包含很多组原文和修正文字的对照条目,组和组之间用一个空行间隔,UTF-8编码, 格式描述如下:
# ```
# > 该组文字的唯一key
# 一行原文
# 一行修改文字
#
# > 该组文字的唯一key
# """用三个半角双引号表示多行文字的开头
# 结尾也用三个半角双引号结束"""
# """这里是对应的
# 多行修改文字"""
#
# ```
# 请你写个python3脚本,读取这个文件,加载这些对照条目,按原文和修改文字的差异由大到小排序输出到另一个文件,格式与原文件相同. 这个差异可以先简单用"各字符统计数量"的绝对差值之和而定.

import argparse
from collections import Counter
from dataclasses import dataclass


@dataclass
class Entry:
    key: str
    original: str
    fixed: str
    score: int


def char_diff_score(a: str, b: str) -> int:
    """
    计算两个字符串的字符统计数量差异：
    对每个字符，取出现次数差的绝对值，然后求和。
    """
    ca = Counter(a)
    cb = Counter(b)

    chars = set(ca) | set(cb)
    return sum(abs(ca[ch] - cb[ch]) for ch in chars)


def skip_blank_lines(lines, i):
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    return i


def parse_text_block(lines, i):
    """
    从 lines[i] 开始解析一段文字。

    支持两种格式：

    1. 单行：
       一行原文

    2. 多行：
       \"\"\"第一行
       第二行
       结尾\"\"\"

    返回：
      (text, next_index)
    """
    if i >= len(lines):
        raise ValueError("Unexpected end of file while reading text block")

    line = lines[i]

    if line.startswith('"""'):
        parts = []

        # 去掉开头的 """
        first = line[3:]

        # 三引号在同一行结束
        if first.endswith('"""') and len(first) >= 3:
            return first[:-3], i + 1

        parts.append(first)
        i += 1

        while i < len(lines):
            line = lines[i]

            if line.endswith('"""'):
                parts.append(line[:-3])
                return "\n".join(parts), i + 1

            parts.append(line)
            i += 1

        raise ValueError("Unclosed triple-quoted text block")

    else:
        return line, i + 1


def parse_entries(path):
    with open(path, "r", encoding="utf-8") as f:
        # 去掉每行末尾换行符，但保留其它字符
        lines = [line.rstrip("\n") for line in f]

    entries = []
    i = 0

    while True:
        i = skip_blank_lines(lines, i)

        if i >= len(lines):
            break

        key_line = lines[i]

        if not key_line.startswith(">"):
            raise ValueError(f"Expected key line starting with '>' at line {i + 1}")

        key = key_line[1:].strip()
        i += 1

        original, i = parse_text_block(lines, i)
        fixed, i = parse_text_block(lines, i)

        score = char_diff_score(original, fixed)

        entries.append(Entry(
            key=key,
            original=original,
            fixed=fixed,
            score=score,
        ))

    return entries


def needs_multiline(text):
    return "\n" in text


def format_text_block(text):
    """
    输出时：
    - 单行文本仍按单行输出
    - 多行文本用三引号包裹
    """
    if needs_multiline(text):
        return f'"""{text}"""'
    return text


def write_entries(entries, path):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        for index, entry in enumerate(entries):
            if index > 0:
                f.write("\n")

            f.write(f"> {entry.key}\n")
            f.write(format_text_block(entry.original))
            f.write("\n")
            f.write(format_text_block(entry.fixed))
            f.write("\n")


def main():
    parser = argparse.ArgumentParser(
        description="Sort text correction entries by character-count difference."
    )
    parser.add_argument("input", help="Input UTF-8 text file")
    parser.add_argument("output", help="Output UTF-8 text file")

    args = parser.parse_args()

    entries = parse_entries(args.input)

    entries.sort(
        key=lambda e: e.score,
        reverse=True
    )

    write_entries(entries, args.output)


if __name__ == "__main__":
    main()

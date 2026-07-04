#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 再写一个处理脚本, 过滤掉"唯一key"中指定前缀的条目, 其它按原顺序输出到新文件.

import argparse
from dataclasses import dataclass


@dataclass
class Entry:
    key: str
    original: str
    fixed: str


def skip_blank_lines(lines, i):
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    return i


def parse_text_block(lines, i):
    """
    解析一段文本。

    支持：
    1. 单行文本
    2. 三引号包裹的多行文本
    """
    if i >= len(lines):
        raise ValueError("Unexpected end of file while reading text block")

    line = lines[i]

    if line.startswith('"""'):
        parts = []

        first = line[3:]

        # 开始和结束三引号在同一行
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

    return line, i + 1


def parse_entries(path):
    with open(path, "r", encoding="utf-8") as f:
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

        entries.append(Entry(
            key=key,
            original=original,
            fixed=fixed,
        ))

    return entries


def format_text_block(text):
    """
    输出时：
    - 单行文本按单行输出
    - 多行文本用三引号包裹
    """
    if "\n" in text:
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
        description="Filter correction entries by key prefix."
    )
    parser.add_argument("input", help="Input UTF-8 text file")
    parser.add_argument("output", help="Output UTF-8 text file")
    parser.add_argument(
        "--prefix",
        required=True,
        help="Entries whose key starts with this prefix will be removed"
    )

    args = parser.parse_args()

    entries = parse_entries(args.input)

    filtered_entries = [
        entry
        for entry in entries
        if not entry.key.startswith(args.prefix)
    ]

    write_entries(filtered_entries, args.output)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import sys
import os
import json
import re
import datetime
import argparse

REVIEW_DIR_DEFAULT = os.path.expanduser("~/.review-notes")

def get_review_dir(args):
    if args.dir:
        return os.path.expanduser(args.dir)
    return REVIEW_DIR_DEFAULT

def ensure_dir(args):
    d = get_review_dir(args)
    if not os.path.exists(d):
        os.makedirs(d)
    return d

def list_files(args):
    d = ensure_dir(args)
    files = [f for f in os.listdir(d) if f.endswith(".md")]
    files.sort()
    print(json.dumps(files))

def create_file(args):
    d = ensure_dir(args)
    name = re.sub(r'\s+', '-', args.name.strip())
    if not name.endswith(".md"):
        name += ".md"
    full_path = os.path.join(d, name)

    if not os.path.exists(full_path):
        with open(full_path, 'w') as f:
            f.write(f"# Review Notes: {name[:-3]}\n\n")
            f.write(f"Created: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

    print(json.dumps({"path": full_path}))

def add_snippet(args):
    d = ensure_dir(args)
    full_path = args.review_file
    if not os.path.isabs(full_path):
        full_path = os.path.join(d, full_path)

    content = sys.stdin.read()
    if not content.endswith("\n"):
        content += "\n"

    with open(full_path, 'a') as f:
        f.write(f"## {args.rel_path} (lines {args.start_line}-{args.end_line})\n")
        f.write(f"Comment: {args.comment if args.comment else '(none)'}\n\n")
        f.write(f"```{args.lang}\n")
        f.write(content)
        f.write("```\n\n")

    print(json.dumps({"status": "success", "file": full_path}))

def parse_file(args):
    d = ensure_dir(args)
    full_path = args.review_file
    if not os.path.isabs(full_path):
        full_path = os.path.join(d, full_path)

    if not os.path.exists(full_path):
        print(json.dumps([]))
        return

    items = []
    current_item = None

    with open(full_path, 'r') as f:
        lines = f.readlines()

    # Simple state machine parser    
    # Looks for: ## path (lines start-end)
    # Then: Comment: ...
    
    for line in lines:
        line = line.strip()
        m_header = re.match(r'^##\s+(.+?)\s+\(lines\s+(\d+)-(\d+)\)$', line)
        if m_header:
            if current_item:
                items.append(current_item)
            current_item = {
                "file": m_header.group(1),
                "start_line": int(m_header.group(2)),
                "end_line": int(m_header.group(3)),
                "comment": ""
            }
            continue
            
        if current_item and line.startswith("Comment:"):
            current_item["comment"] = line[8:].strip()
            # Once we have the comment, we consider the item complete enough for UI purposes
            # (ignoring the code block for now in the summary list)
            items.append(current_item)
            current_item = None
            
    print(json.dumps(items))

def main():
    parser = argparse.ArgumentParser(description="Manage review notes for AI agent workflow")
    parser.add_argument("--dir", help="Directory for review notes (default: ~/.review-notes)")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("list")
    
    create_parser = subparsers.add_parser("create")
    create_parser.add_argument("name")

    add_parser = subparsers.add_parser("add")
    add_parser.add_argument("review_file")
    add_parser.add_argument("rel_path")
    add_parser.add_argument("start_line")
    add_parser.add_argument("end_line")
    add_parser.add_argument("comment")
    add_parser.add_argument("lang")

    parse_parser = subparsers.add_parser("parse")
    parse_parser.add_argument("review_file")

    args = parser.parse_args()

    if args.command == "list":
        list_files(args)
    elif args.command == "create":
        create_file(args)
    elif args.command == "add":
        add_snippet(args)
    elif args.command == "parse":
        parse_file(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()

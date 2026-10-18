# convert_offline_links.py
# Script to convert online Kali documentation links (https://www.kali.org/tools/...)
# to local relative .html paths for offline browsing, ensuring all tools are
# seamlessly connected to all-tools/index.html.

import os
import re

TOOLS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "www.kali.org", "tools")

base_tag_regex = re.compile(r'<base\s+[^>]*>', re.IGNORECASE)
css_repair_regex = re.compile(r'href=["\']?\.\.?/index\.html["\']?\.min\.css', re.IGNORECASE)
tag_repair_regex = re.compile(r'href=["\']?\.\.?/>([^"\'/]+)/index\.html["\']?', re.IGNORECASE)

link_regex = re.compile(r'href=["\']?https://www\.kali\.org/tools/(?:([^"\'\s/><#]+)/?)?(#[^"\'\s>]*)?["\']?', re.IGNORECASE)

def process_file(file_path):
    rel_path = os.path.relpath(file_path, TOOLS_DIR)
    parts = rel_path.split(os.sep)
    is_root = len(parts) == 1
    current_folder = "" if is_root else parts[0]

    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    original_content = content
    content = base_tag_regex.sub("", content)
    content = css_repair_regex.sub('href="https://www.kali.org/tools.min.css', content)
    content = tag_repair_regex.sub(r'href="https://www.kali.org/tools/">\1', content)

    def replace_link(match):
        target_tool = match.group(1) or ""
        anchor = match.group(2) or ""

        if is_root:
            if not target_tool:
                return f'href="{anchor}"' if anchor else 'href="./index.html"'
            return f'href="./{target_tool}/index.html{anchor}"'
        else:
            if not target_tool:
                return f'href="../index.html{anchor}"' if anchor else 'href="../index.html"'
            elif target_tool == current_folder:
                return f'href="{anchor}"' if anchor else 'href="./index.html"'
            else:
                return f'href="../{target_tool}/index.html{anchor}"'

    content = link_regex.sub(replace_link, content)

    # In individual tool pages, ensure 'Go back' and 'Tools Documentation' connect to all-tools
    if not is_root and current_folder not in ("all-tools", "top-100"):
        content = content.replace('<a href="../index.html" title="↤ Go back"></a>', '<a href="../all-tools/index.html" title="↤ Go back"></a>')
        content = content.replace('<a href="../index.html">Tools Documentation</a>', '<a href="../all-tools/index.html">Tools Documentation</a>')

    if content != original_content:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        return True
    return False

def main():
    print(f"Target tools directory: {TOOLS_DIR}")
    html_files = []
    for root, _, files in os.walk(TOOLS_DIR):
        for f in files:
            if f.endswith(".html"):
                html_files.append(os.path.join(root, f))

    total = len(html_files)
    print(f"Found {total} HTML files to process.")

    modified = 0
    for idx, path in enumerate(html_files, 1):
        if process_file(path):
            modified += 1
        if idx % 100 == 0 or idx == total:
            print(f"Processed {idx} / {total} files ({modified} updated)...")

    print(f"Done! Successfully updated {modified} of {total} files.")

if __name__ == "__main__":
    main()

import os
import pypandoc
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--all', action='store_true', help='compile all')
args = parser.parse_args()

source_dir = "_latex"
output_dir = "_problems"
pattern = re.compile(r"^(\d+)-(\d+)-(\w+)\.tex$")
rounds = ["?", "First Round", "Second Round", "Final Round", "Selection"]

for filename in os.listdir(source_dir):
    if filename == ".DS_Store":
        continue
    match = pattern.match(filename)
    if not match:
        print(f"⚠️ Skipping file with unexpected format: {filename}")
        continue

    x, y, z = match.groups()
    tex_path = os.path.join(source_dir, filename)
    html_filename = filename.replace(".tex", ".html")
    html_path = os.path.join(output_dir, html_filename)

    # Check timestamps
    if not args.all:
        tex_mtime = os.path.getmtime(tex_path)
        if os.path.exists(html_path):
            html_mtime = os.path.getmtime(html_path)
            if html_mtime >= tex_mtime:
                continue

    try:
        html_content = pypandoc.convert_file(
            tex_path,
            'html',
            format='latex',
            extra_args=['--mathjax']
        )

        
        front_matter = f"---\nyear: {x}\nround: {y}\nnumber: {z}\n---\n"
        final_output = front_matter + html_content

        with open(html_path, "w", encoding="utf-8") as f:
            f.write(final_output)
        
        print(f"🔁 Converted {filename} → {html_filename}")
    except Exception as e:
        print(f"❌ Error converting {filename}: {e}")

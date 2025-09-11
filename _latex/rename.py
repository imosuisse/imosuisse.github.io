import os
import re

# Directory containing your .tex files
directory = "."

# Pattern: match xxxx-y-z.tex where z is a single digit
pattern = re.compile(r'^(\d+-\d+)-(\d)\.tex$')

for filename in os.listdir(directory):
    match = pattern.match(filename)
    if match:
        new_name = f"{match.group(1)}-0{match.group(2)}.tex"
        print(f"Renaming '{filename}' → '{new_name}'")
        os.rename(os.path.join(directory, filename), os.path.join(directory, new_name))
    else:
        print(f"Skipping '{filename}'")


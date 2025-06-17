#!/usr/bin/env python3

from pathlib import Path
import sys

# parse all iamges ang generate lines like this:
# ![1.jpg](assets/images-2024/1.jpg)
for idx, filename in enumerate(sys.argv[1:]):
    path = Path(filename)
    # Skip directories
    if path.is_dir():
        continue
    # Generate the markdown image line
    print(f'![{idx}.jpg]({path})')

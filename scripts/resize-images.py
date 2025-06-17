#!/usr/bin/env python3

import os
import sys
from PIL import Image, ImageOps

# Define the target width
TARGET_WIDTH = 750

# Loop through all files in the current directory
for filename in sys.argv[1:]:
    # Skip directories
    if os.path.isdir(filename):
        continue
    try:
        # Open the image file
        with Image.open(filename) as img:
            # Apply EXIF orientation (if any)
            img = ImageOps.exif_transpose(img)

            width, height = img.size
            # Check if resizing is necessary
            if width != TARGET_WIDTH:
                # Calculate the new height to maintain aspect ratio
                new_height = int((TARGET_WIDTH / width) * height)
                # Resize the image with high-quality resampling
                img_resized = img.resize((TARGET_WIDTH, new_height), Image.LANCZOS)
                # Save the resized image, overwriting the original
                img_resized.save(filename)
                print(f'Resized {filename} to {TARGET_WIDTH}px wide.')
            else:
                print(f'{filename} is already {TARGET_WIDTH}px wide. Skipping.')
    except IOError:
        # The file is not an image or cannot be opened
        print(f'Cannot process {filename}: not an image file.')


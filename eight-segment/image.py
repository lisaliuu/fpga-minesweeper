from PIL import Image
import numpy as np

with open("export.txt", "w") as f:
    # images = ["Eight-segment-1.bmp",]
    images = [
        "Eight-segment-0.bmp",
        "Eight-segment-1.bmp",
        "Eight-segment-2.bmp",
        "Eight-segment-3.bmp",
        "Eight-segment-4.bmp",
        "Eight-segment-5.bmp",
        "Eight-segment-6.bmp",
        "Eight-segment-7.bmp",
        "Eight-segment-8.bmp",
        "Eight-segment-9.bmp",
        "bomb.bmp",]
    for image in images:
        img = Image.open(image)
        print(f"Image: {image}")
        f.write(f"Image: {image}\n")
        for i in np.array(img):
            print(f'\"{"".join(["." if x > 15 else "#" for x in i])}\",')
            str = f'\"{"".join(["0" if x > 15 else "1" for x in i])}\",'
            f.write(str + "\n")
        print()
        f.write("\n")

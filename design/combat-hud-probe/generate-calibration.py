"""Generate the two translucent HUD panels and their calibration font, using only Python's stdlib."""
import json
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parent / "calibration/mods"
WIDTH, HEIGHT = 190, 60
ALPHA = 128


def png_chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))


def rectangle(path, rgb):
    path.parent.mkdir(parents=True, exist_ok=True)
    pixels = (b"\x00" + bytes((*rgb, ALPHA)) * WIDTH) * HEIGHT
    path.write_bytes(b"\x89PNG\r\n\x1a\n"
                     + png_chunk(b"IHDR", struct.pack(">IIBBBBB", WIDTH, HEIGHT, 8, 6, 0, 0, 0))
                     + png_chunk(b"IDAT", zlib.compress(pixels, 9))
                     + png_chunk(b"IEND", b""))


def main():
    textures = ROOT / "assets/elitemobs/textures/gui/combat_hud_probe"
    rectangle(textures / "gray.png", (128, 128, 128))
    rectangle(textures / "red.png", (220, 40, 40))
    providers = [{"type": "space", "advances": {"\ue100": 1, "\ue101": -1}}]
    for y in range(-16, 17):
        for color_index, color in enumerate(("gray", "red")):
            providers.append({
                "type": "bitmap",
                "file": f"elitemobs:gui/combat_hud_probe/{color}.png",
                # Action bar text origin H-72, bitmap bearing 7-ascent: H-60+y.
                "ascent": -5 - y,
                "height": HEIGHT,
                "chars": [chr(0xE000 + (y + 16) * 2 + color_index)],
            })
    font = ROOT / "assets/elitemobs/font/combat_hud_probe.json"
    font.parent.mkdir(parents=True, exist_ok=True)
    font.write_text(json.dumps({"providers": providers}, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()

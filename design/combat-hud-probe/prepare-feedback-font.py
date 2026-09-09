"""Derive the feedback font and matching advances from Minecraft's client assets.

Usage: python prepare-feedback-font.py client.jar unifont.zip unifont.json
Inputs are the matching vanilla client and asset-index objects. No art is modified.
"""
import io
import json
from pathlib import Path
import struct
import sys
import zipfile
from PIL import Image

root = Path(__file__).parent
client, hex_archive, hex_definition = map(Path, sys.argv[1:])
metrics = {32: (8, 2), 0x200c: (0, 2)}
providers = [{"type": "space", "advances": {" ": 4, "\u200c": 0}}]
with zipfile.ZipFile(client) as archive:
    bitmaps = json.loads(archive.read('assets/minecraft/font/include/default.json'))['providers']
    for provider in bitmaps:
        providers.append(provider)
        image = Image.open(io.BytesIO(archive.read('assets/minecraft/textures/' + provider['file'].split(':')[1]))).convert('RGBA')
        rows = provider['chars']
        w, h = image.width // len(rows[0]), image.height // len(rows)
        scale = provider.get('height', 8) / h
        for y, row in enumerate(rows):
            for x, char in enumerate(row):
                if ord(char) == 0 or ord(char) in metrics:
                    continue
                bounds = image.crop((x*w, y*h, (x+1)*w, (y+1)*h)).getchannel('A').getbbox()
                width = bounds[2] if bounds else 0
                metrics[ord(char)] = (2 * (int(width * scale + .5) + 1), 2)

unihex = next(p for p in json.loads(hex_definition.read_text())['providers']
              if p.get('hex_file') == 'minecraft:font/unifont.zip')
providers.append(unihex)
with zipfile.ZipFile(hex_archive) as archive:
    for name in archive.namelist():
        if not name.endswith('.hex'):
            continue
        for line in archive.read(name).decode().splitlines():
            code, bitmap = line.split(':')
            cp = int(code, 16)
            if cp in metrics:
                continue
            bits = len(bitmap) // 4
            digits = len(bitmap) // 16
            mask = 0
            for row in range(16):
                mask |= int(bitmap[row*digits:(row+1)*digits], 16)
            width = mask.bit_length() - ((mask & -mask).bit_length() - 1) if mask else bits + 1
            for override in unihex['size_overrides']:
                if ord(override['from']) <= cp <= ord(override['to']):
                    width = override['right'] - override['left'] + 1
                    break
            metrics[cp] = (width + 2, 1)

font = root / 'mods/assets/elitemobs/font/combat_hud_feedback.json'
font.write_text(json.dumps({'providers': providers}, indent=2) + '\n')
target = root / '../../src/main/resources/combat-hud-feedback-metrics.bin'
with target.open('wb') as out:
    out.write(struct.pack('>II', 1, len(metrics)))
    for cp, (advance, bold) in sorted(metrics.items()):
        out.write(struct.pack('>IBB', cp, advance, bold))
print(f'Generated feedback font and {len(metrics)} glyph advances.')

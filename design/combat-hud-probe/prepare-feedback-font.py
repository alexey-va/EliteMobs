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
from collections import defaultdict

root = Path(__file__).parent
client, hex_archive, hex_definition = map(Path, sys.argv[1:])
metrics = {32: (8, 2), 0x200c: (0, 2)}
providers = [{"type": "space", "advances": {" ": 4, "\u200c": 0}}]
badge_providers = [{"type": "space", "advances": {" ": 4, "\u200c": 0}}]
badge_bitmaps = defaultdict(list)
unicode_directory = root / 'mods/assets/elitemobs/textures/font/combat_hud_unicode'
unicode_directory.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(client) as archive:
    bitmaps = json.loads(archive.read('assets/minecraft/font/include/default.json'))['providers']
    for provider in bitmaps:
        providers.append(provider)
        badge_providers.append({**provider, 'ascent': provider['ascent'] - 15})
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
badge_metrics = dict(metrics)
with zipfile.ZipFile(hex_archive) as archive:
    (unicode_directory / 'LICENSE.txt').write_bytes(archive.read('LICENSE.txt'))
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
            left = bits - mask.bit_length() if mask else 0
            right = bits - ((mask & -mask).bit_length() - 1) - 1 if mask else bits
            for override in unihex['size_overrides']:
                if ord(override['from']) <= cp <= ord(override['to']):
                    left, right = override['left'], override['right']
                    break
            width = right - left + 1
            metrics[cp] = (width + 2, 1)
            # Unihex has no vertical offset. Preserve its original 16-row bitmap,
            # including Japanese/CJK, in a positioned bitmap provider. Group by
            # cropped width rather than allocating 32 columns for every glyph.
            glyph = Image.new('RGBA', (width, 16))
            for y in range(16):
                row_bits = int(bitmap[y*digits:(y+1)*digits], 16)
                for x in range(width):
                    source_x = left + x
                    if 0 <= source_x < bits and row_bits & (1 << (bits - source_x - 1)):
                        glyph.putpixel((x, y), (255, 255, 255, 255))
            # Vanilla size overrides may include blank trailing columns. Retain
            # their advance without adding a visible stroke to the glyph.
            if not glyph.getpixel((width-1, 15))[3]:
                glyph.putpixel((width-1, 15), (255, 255, 255, 1))
            badge_bitmaps[width].append((cp, glyph))
            badge_metrics[cp] = (2 * (int(width / 2 + .5) + 1), 2)

raw_pixels = 0
for width, glyphs in sorted(badge_bitmaps.items()):
    for page, offset in enumerate(range(0, len(glyphs), 256)):
        entries = glyphs[offset:offset+256]
        rows = (len(entries) + 15) // 16
        sheet = Image.new('RGBA', (width * 16, rows * 16))
        chars = [list('\0' * 16) for _ in range(rows)]
        for index, (cp, glyph) in enumerate(entries):
            x, y = index % 16, index // 16
            sheet.paste(glyph, (x * width, y * 16))
            chars[y][x] = chr(cp)
        name = f'w{width}_{page}.png'
        sheet.save(unicode_directory / name, optimize=True)
        raw_pixels += sheet.width * sheet.height
        badge_providers.append({'type': 'bitmap',
            'file': f'elitemobs:font/combat_hud_unicode/{name}',
            'height': 8, 'ascent': -8, 'chars': [''.join(row) for row in chars]})

badge_font = root / 'mods/assets/elitemobs/font/combat_hud_class_name.json'
badge_font.write_text(json.dumps({'providers': badge_providers}, indent=2) + '\n', encoding='utf-8')

font = root / 'mods/assets/elitemobs/font/combat_hud_feedback.json'
font.write_text(json.dumps({'providers': providers}, indent=2) + '\n')
target = root / '../../src/main/resources/combat-hud-feedback-metrics.bin'
with target.open('wb') as out:
    out.write(struct.pack('>II', 1, len(metrics)))
    for cp, (advance, bold) in sorted(metrics.items()):
        out.write(struct.pack('>IBB', cp, advance, bold))
print(f'Generated feedback font and {len(metrics)} glyph advances.')
with (root / '../../src/main/resources/combat-hud-class-name-metrics.bin').open('wb') as out:
    out.write(struct.pack('>II', 1, len(badge_metrics)))
    for cp, (advance, bold) in sorted(badge_metrics.items()):
        out.write(struct.pack('>IBB', cp, advance, bold))
print(f'Generated positioned vanilla font: {len(badge_metrics)} glyphs, {raw_pixels*4/1024/1024:.1f} MiB decoded Unicode sheets.')

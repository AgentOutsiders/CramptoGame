"""Génère les textures pixel art du menu principal (style « cahier »).

Usage : python3 tools/generate_menu_textures.py
Les images sont écrites dans game/assets/ui/menu/.
Chaque texture est dessinée en basse résolution puis agrandie (SCALE)
pour garder un rendu pixel cohérent avec la police PixelOperator8.
"""

import random
from pathlib import Path

from PIL import Image

OUT_DIR = Path(__file__).resolve().parent.parent / "game" / "assets" / "ui" / "menu"
SCALE = 4

PAPER = (246, 242, 230, 255)
PAPER_EDGE = (200, 192, 175, 255)
LINE_BLUE = (203, 220, 240, 255)
MARGIN_RED = (238, 168, 162, 255)
SHADOW = (0, 0, 0, 80)
HIGHLIGHTER = (255, 232, 40, 175)
INK = (28, 36, 77, 255)

# Tailles en pixels basse résolution, ombre comprise
STRIP_W, STRIP_H = 130, 28  # boutons
TITLE_W, TITLE_H = 250, 48  # feuille du titre
SHADOW_OFFSET = 2


def _ragged_edge(rng: random.Random, length: int, max_depth: int) -> list[int]:
    """Bord déchiré : marche aléatoire bornée entre 0 et max_depth."""
    depth = rng.randint(0, max_depth)
    edge = []
    for _ in range(length):
        depth = max(0, min(max_depth, depth + rng.choice((-1, 0, 0, 1))))
        edge.append(depth)
    return edge


def _strip_mask(seed: int, size: tuple[int, int] = (STRIP_W, STRIP_H)) -> set[tuple[int, int]]:
    """Ensemble des pixels occupés par la bande de papier."""
    rng = random.Random(seed)
    w, h = size[0] - SHADOW_OFFSET, size[1] - SHADOW_OFFSET
    top = _ragged_edge(rng, w, 2)
    bottom = _ragged_edge(rng, w, 2)
    left = _ragged_edge(rng, h, 1)
    right = _ragged_edge(rng, h, 1)
    mask = set()
    for y in range(h):
        for x in range(left[y], w - right[y]):
            if top[x] <= y < h - bottom[x]:
                mask.add((x, y))
    return mask


def _is_edge(mask: set, x: int, y: int) -> bool:
    return any((x + dx, y + dy) not in mask for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))


def _save(img: Image.Image, name: str) -> None:
    img = img.resize((img.width * SCALE, img.height * SCALE), Image.NEAREST)
    img.save(OUT_DIR / name)
    print("écrit :", OUT_DIR / name)


def make_paper_strip(seed: int, name: str, size: tuple[int, int] = (STRIP_W, STRIP_H)) -> None:
    mask = _strip_mask(seed, size)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    px = img.load()
    for x, y in mask:
        px[x + SHADOW_OFFSET, y + SHADOW_OFFSET] = SHADOW
    for x, y in mask:
        if _is_edge(mask, x, y):
            color = PAPER_EDGE
        elif x == 12:
            color = MARGIN_RED
        elif y > 0 and y % 7 == 0:
            color = LINE_BLUE
        else:
            color = PAPER
        px[x, y] = color
    _save(img, name)


def make_highlight(seed: int, name: str, size: tuple[int, int] = (STRIP_W, STRIP_H)) -> None:
    """Coup de surligneur seul (transparent ailleurs), posé par-dessus la bande."""
    mask = _strip_mask(seed, size)
    rng = random.Random(seed * 7 + 1)
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    px = img.load()
    start, end = 7, size[0] - SHADOW_OFFSET - 9
    for y in range(round(size[1] * 0.21), round(size[1] * 0.68)):
        row_start = start + rng.randint(-1, 1) + (18 - y) // 6
        row_end = end + rng.randint(-1, 1) - y // 6
        for x in range(row_start, row_end):
            if (x, y) in mask and not _is_edge(mask, x, y):
                px[x, y] = HIGHLIGHTER
    _save(img, name)


def make_grabber(name: str, fill: tuple, shade: tuple, light: tuple) -> None:
    """Curseur des sliders : boule jaune cerclée d'encre, ombrée en bas à droite.
    Pas d'ombre portée : l'image reste centrée sur la barre du slider."""
    size = 11
    c = (size - 1) / 2
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    for y in range(size):
        for x in range(size):
            d = ((x - c) ** 2 + (y - c) ** 2) ** 0.5
            if d > c + 0.4:
                continue
            if d > c - 0.6:
                px[x, y] = INK
            elif ((x - c + 1.5) ** 2 + (y - c + 1.5) ** 2) ** 0.5 > c - 1.2:
                px[x, y] = shade  # croissant d'ombre en bas à droite
            else:
                px[x, y] = fill
    px[3, 3] = light
    px[4, 3] = light
    px[3, 4] = light
    _save(img, name)


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for i, seed in enumerate((3, 11, 42), start=1):
        make_paper_strip(seed, f"paper_strip_{i}.png")
        make_highlight(seed, f"paper_highlight_{i}.png")
    make_paper_strip(5, "paper_title.png", (TITLE_W, TITLE_H))

    # Page des paramètres
    make_paper_strip(7, "settings_title.png", (270, 46))
    make_paper_strip(23, "settings_page.png", (300, 101))
    make_paper_strip(17, "settings_back.png", (170, 28))
    make_highlight(17, "settings_back_highlight.png", (170, 28))
    make_paper_strip(29, "settings_option.png", (130, 22))
    make_highlight(29, "settings_option_highlight.png", (130, 22))
    make_grabber("slider_grabber.png", (255, 222, 50, 255), (225, 178, 30, 255), (255, 244, 160, 255))
    make_grabber("slider_grabber_hover.png", (255, 236, 120, 255), (240, 200, 70, 255), (255, 252, 215, 255))

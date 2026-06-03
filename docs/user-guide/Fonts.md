# Fonts

`wx_bgi_graphics` now ships with two text-rendering paths:

1. **Classic stroke fonts** for the historic BGI ids:
   - `DEFAULT_FONT`
   - `TRIPLEX_FONT`
   - `SMALL_FONT`
   - `SANS_SERIF_FONT`
   - `GOTHIC_FONT`
2. **Embedded outline fonts** compiled into the shared library:
   - `MODERN_ROBOTO_FONT`
   - `MODERN_PLAYFAIR_DISPLAY_FONT`
   - `MODERN_HANDJET_FONT`

## Selecting Fonts

Classic BGI code can use the new embedded families directly through
`settextstyle()`:

```cpp
settextstyle(MODERN_ROBOTO_FONT, HORIZ_DIR, 2);
outtextxy(20, 20, const_cast<char*>("Roboto sample"));
```

If you prefer name lookup instead of hardcoded ids:

```cpp
int roboto = wxbgi_font_id("Roboto");
settextstyle(roboto, HORIZ_DIR, 2);
```

The classic compatibility hook `installuserfont()` now also resolves bundled
font names:

```cpp
int playfair = installuserfont(const_cast<char*>("Playfair Display"));
settextstyle(playfair, HORIZ_DIR, 2);
```

Related helpers in `wx_bgi_ext.h`:

- `wxbgi_font_count()`
- `wxbgi_font_name(fontId)`
- `wxbgi_font_id(name)`

## Text Encoding

Text input is now decoded as UTF-8 when possible, with single-byte fallback for
legacy callers. That means strings such as `Résumé`, `ÁÉÍÓÚ`, `äöü`, `ñ`, `ç`,
`æ`, `ø`, `þ`, and `ß` render correctly in the embedded Google fonts and in the
extended classic stroke-font path.

## Embedded Google Fonts and OFL Notices

Roboto, Playfair Display, and Handjet are embedded into the shared library at
build time from the upstream font binaries stored under:

- `third_party/fonts/roboto/`
- `third_party/fonts/playfairdisplay/`
- `third_party/fonts/handjet/`

Their SIL Open Font License notices are kept in the matching `OFL.txt` files in
those directories. The font binaries are compiled into the library; they are not
installed as separate runtime font files by this project.

## Demo Program

The repository includes a font showcase example that displays the classic and
embedded font families and exits automatically after 10 seconds:

```powershell
# Windows
build\Debug\wxbgi_fonts_demo_cpp.exe

# Linux / macOS
build/wxbgi_fonts_demo_cpp
```

Use `--test` for the short automated path used during development:

```powershell
build\Debug\wxbgi_fonts_demo_cpp.exe --test
```

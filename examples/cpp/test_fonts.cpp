#include "wx_bgi.h"
#include "wx_bgi_ext.h"
#include "bgi_types.h"

#include <array>
#include <chrono>
#include <cstdio>
#include <cstring>
#include <string>
#include <thread>

using namespace bgi;

namespace
{
    constexpr std::array<int, 8> kFonts = {{
        DEFAULT_FONT,
        TRIPLEX_FONT,
        SMALL_FONT,
        SANS_SERIF_FONT,
        GOTHIC_FONT,
        MODERN_ROBOTO_FONT,
        MODERN_PLAYFAIR_DISPLAY_FONT,
        MODERN_HANDJET_FONT,
    }};

    bool regionHasInk(int left, int top, int right, int bottom)
    {
        for (int y = top; y <= bottom; ++y)
        {
            for (int x = left; x <= right; ++x)
            {
                if (getpixel(x, y) != BLACK)
                {
                    return true;
                }
            }
        }
        return false;
    }
}

int main()
{
    if (initwindow(640, 320, "font-test", 0, 0, 0, 1) != 0)
    {
        std::fprintf(stderr, "FAIL: initwindow failed\n");
        return 1;
    }

    const std::string utf8 =
        "R\xC3\xA9sum\xC3\xA9 "
        "\xC3\x81\xC3\x89\xC3\x8D\xC3\x93\xC3\x9A "
        "\xC3\xA4\xC3\xB6\xC3\xBC "
        "\xC3\xB1 \xC3\xA7 \xC3\xA6 \xC3\xB8 \xC3\xBE \xC3\x9F";
    if (wxbgi_font_count() < static_cast<int>(kFonts.size()))
    {
        std::fprintf(stderr, "FAIL: expected embedded font count\n");
        return 1;
    }
    if (wxbgi_font_id("Roboto") != MODERN_ROBOTO_FONT ||
        wxbgi_font_id("Playfair Display") != MODERN_PLAYFAIR_DISPLAY_FONT ||
        wxbgi_font_id("Handjet") != MODERN_HANDJET_FONT)
    {
        std::fprintf(stderr, "FAIL: font name lookup failed\n");
        return 1;
    }
    if (installuserfont(const_cast<char *>("Roboto")) != MODERN_ROBOTO_FONT)
    {
        std::fprintf(stderr, "FAIL: installuserfont lookup failed\n");
        return 1;
    }

    int y = 10;
    for (int fontId : kFonts)
    {
        cleardevice();
        setcolor(WHITE);
        settextstyle(fontId, HORIZ_DIR, fontId == SMALL_FONT ? 1 : 2);
        const int width = textwidth(const_cast<char *>(utf8.data()));
        const int height = textheight(const_cast<char *>(utf8.data()));
        if (width <= 0 || height <= 0)
        {
            std::fprintf(stderr, "FAIL: non-positive text metrics for font %d (%d x %d)\n", fontId, width, height);
            return 1;
        }

        outtextxy(12, y, const_cast<char *>(utf8.data()));
        if (!regionHasInk(0, 0, std::min(639, 12 + width + 8), std::min(319, y + height + 8)))
        {
            std::fprintf(stderr, "FAIL: no glyph pixels drawn for font %d\n", fontId);
            return 1;
        }

        y += 2;

        std::this_thread::sleep_for(std::chrono::milliseconds(2000));
    }

    settextstyle(999, HORIZ_DIR, 1);
    if (graphresult() != grInvalidFont)
    {
        std::fprintf(stderr, "FAIL: invalid font not rejected\n");
        return 1;
    }

    std::printf("test_fonts: embedded and classic font rendering OK\n");
    return 0;
}

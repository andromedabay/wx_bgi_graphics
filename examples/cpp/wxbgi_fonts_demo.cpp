#include "wx_bgi.h"
#include "wx_bgi_ext.h"
#include "bgi_types.h"

#include <array>
#include <chrono>
#include <cstring>
#include <string>
#include <thread>

using namespace bgi;

namespace
{
    struct FontRow
    {
        int id;
        const char *label;
    };

    constexpr FontRow kFonts[] = {
        {DEFAULT_FONT, "Default"},
        {TRIPLEX_FONT, "Triplex"},
        {SMALL_FONT, "Small"},
        {SANS_SERIF_FONT, "Sans Serif"},
        {GOTHIC_FONT, "Gothic"},
        {MODERN_ROBOTO_FONT, "Roboto"},
        {MODERN_PLAYFAIR_DISPLAY_FONT, "Playfair Display"},
        {MODERN_HANDJET_FONT, "Handjet"},
    };
}

int main(int argc, char **argv)
{
    const bool testMode = (argc > 1 && std::strcmp(argv[1], "--test") == 0);
    const auto duration = testMode ? std::chrono::milliseconds(250) : std::chrono::seconds(10);

    if (initwindow(1180, 760, "wx_bgi Embedded Fonts Demo", 40, 40, 0, 1) != 0)
    {
        return 1;
    }

    setbkcolor(BLACK);
    cleardevice();

    std::string title = "Embedded classic + Google OFL fonts";
    std::string subtitle = "UTF-8 Latin sample, automatic exit after 10 seconds";
    std::string sample =
        "The quick brown fox - R\xC3\xA9sum\xC3\xA9 "
        "\xC3\x81\xC3\x89\xC3\x8D\xC3\x93\xC3\x9A "
        "\xC3\xA4\xC3\xAB\xC3\xAF\xC3\xB6\xC3\xBC "
        "\xC3\xB1 \xC3\xA7 \xC3\xA6 \xC3\xB8 \xC3\xBE \xC3\x9F";

    const auto start = std::chrono::steady_clock::now();
    bool rendered_once = false;
    while (wxbgi_is_ready() == 1 &&
           std::chrono::steady_clock::now() - start < duration)
    {
        wxbgi_poll_events();
        if (!rendered_once)
        {
            cleardevice();

            settextstyle(DEFAULT_FONT, HORIZ_DIR, 2);
            setcolor(YELLOW);
            outtextxy(20, 16, title.data());
            setcolor(LIGHTGRAY);
            outtextxy(20, 42, subtitle.data());

            int y = 90;
            for (const auto &font : kFonts)
            {
                settextstyle(font.id, HORIZ_DIR, font.id == SMALL_FONT ? 1 : 2);
                setcolor(WHITE);
                std::string line = std::string(font.label) + ": " + sample;
                outtextxy(20, y, line.data());
                y += font.id == SMALL_FONT ? 44 : 78;
            }
           rendered_once = true;
       }
       std::this_thread::sleep_for(std::chrono::milliseconds(testMode ? 16 : 33));
    }

    closegraph();
    return 0;
}

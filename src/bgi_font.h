#pragma once

#include <array>
#include <cstdint>
#include <string>
#include <utility>

namespace bgi
{

    bool isKnownFont(int fontId);
    const char *fontName(int fontId);
    int fontIdFromName(const std::string &name);
    int fontCount();
    int currentTextScaleX();
    int currentTextScaleY();
    std::pair<int, int> measureText(const std::string &text);
    void drawGlyph(int x, int y, std::uint32_t codepoint, int color);
    void drawText(int x, int y, const std::string &text, int color);

} // namespace bgi

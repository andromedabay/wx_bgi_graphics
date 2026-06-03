#pragma once

#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace bgi
{

    bool isOutlineFont(int fontId);
    const char *outlineFontName(int fontId);
    int outlineFontIdFromName(const std::string &name);

    std::pair<int, int> measureOutlineText(
        int fontId,
        const std::vector<std::uint32_t> &codepoints,
        int scaleX,
        int scaleY,
        bool vertical);

    void drawOutlineText(
        int x,
        int y,
        int fontId,
        const std::vector<std::uint32_t> &codepoints,
        int color,
        int scaleX,
        int scaleY,
        bool vertical);

} // namespace bgi

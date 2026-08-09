#include "bgi_outline_font.h"

#include "bgi_draw.h"
#include "bgi_embedded_fonts.h"
#include "bgi_state.h"
#include "bgi_types.h"

#define STB_TRUETYPE_IMPLEMENTATION
#include <stb/stb_truetype.h>

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <string>
#include <unordered_map>

namespace bgi
{

    namespace
    {
        struct OutlineFontAsset
        {
            int id;
            const char *name;
            const unsigned char *data;
            std::size_t size;
        };

        struct OutlineFontCache
        {
            stbtt_fontinfo info{};
            int ascent{0};
            int descent{0};
            int lineGap{0};
            bool valid{false};
        };

        struct GlyphPlacement
        {
            std::uint32_t codepoint;
            int penAdvance;
        };

        struct OutlineLayout
        {
            std::vector<GlyphPlacement> glyphs;
            int minLeft{0};
            int maxRight{0};
            int baseline{0};
            int width{0};
            int height{0};
            int verticalAdvance{0};
        };

        const OutlineFontAsset kOutlineFonts[] = {
            {MODERN_ROBOTO_FONT, "Roboto", embedded::kRobotoFont, embedded::kRobotoFontSize},
            {MODERN_PLAYFAIR_DISPLAY_FONT, "Playfair Display", embedded::kPlayfairDisplayFont, embedded::kPlayfairDisplayFontSize},
            {MODERN_HANDJET_FONT, "Handjet", embedded::kHandjetFont, embedded::kHandjetFontSize},
        };

        const OutlineFontAsset *findOutlineFont(int fontId)
        {
            for (const auto &font : kOutlineFonts)
            {
                if (font.id == fontId)
                {
                    return &font;
                }
            }
            return nullptr;
        }

        std::string normalizeName(const std::string &name)
        {
            std::string normalized;
            normalized.reserve(name.size());
            for (unsigned char ch : name)
            {
                if (std::isalnum(ch) != 0)
                {
                    normalized.push_back(static_cast<char>(std::tolower(ch)));
                }
            }
            return normalized;
        }

        OutlineFontCache &fontCache(const OutlineFontAsset &asset)
        {
            static std::unordered_map<int, OutlineFontCache> cache;
            auto &entry = cache[asset.id];
            if (entry.valid)
            {
                return entry;
            }

            const int offset = stbtt_GetFontOffsetForIndex(asset.data, 0);
            if (offset >= 0 && stbtt_InitFont(&entry.info, asset.data, offset) != 0)
            {
                stbtt_GetFontVMetrics(&entry.info, &entry.ascent, &entry.descent, &entry.lineGap);
                entry.valid = true;
            }

            return entry;
        }

        OutlineLayout buildHorizontalLayout(
            const OutlineFontAsset &asset,
            const std::vector<std::uint32_t> &codepoints,
            int scaleX,
            int scaleY)
        {
            OutlineLayout layout;
            if (codepoints.empty())
            {
                return layout;
            }

            auto &cache = fontCache(asset);
            if (!cache.valid)
            {
                return layout;
            }

            const float pixelHeight = static_cast<float>(std::max(1, scaleY) * 14);
            const float scaleYf = stbtt_ScaleForPixelHeight(&cache.info, pixelHeight);
            const float scaleXf = scaleYf * static_cast<float>(std::max(1, scaleX)) /
                                  static_cast<float>(std::max(1, scaleY));

            layout.baseline = static_cast<int>(std::ceil(static_cast<float>(cache.ascent) * scaleYf));
            layout.height = std::max(
                1,
                static_cast<int>(std::ceil(static_cast<float>(cache.ascent - cache.descent) * scaleYf)));

            int pen = 0;
            layout.minLeft = 0;
            layout.maxRight = 0;
            layout.glyphs.reserve(codepoints.size());

            for (std::size_t index = 0; index < codepoints.size(); ++index)
            {
                const auto codepoint = codepoints[index];
                int x0 = 0;
                int y0 = 0;
                int x1 = 0;
                int y1 = 0;
                stbtt_GetCodepointBitmapBox(&cache.info, static_cast<int>(codepoint), scaleXf, scaleYf, &x0, &y0, &x1, &y1);

                layout.minLeft = std::min(layout.minLeft, pen + x0);
                layout.maxRight = std::max(layout.maxRight, pen + x1);
                layout.glyphs.push_back({codepoint, pen});

                int advanceWidth = 0;
                int leftBearing = 0;
                stbtt_GetCodepointHMetrics(&cache.info, static_cast<int>(codepoint), &advanceWidth, &leftBearing);
                pen += std::max(1, static_cast<int>(std::lround(static_cast<float>(advanceWidth) * scaleXf)));

                if (index + 1 < codepoints.size())
                {
                    pen += static_cast<int>(std::lround(
                        static_cast<float>(stbtt_GetCodepointKernAdvance(
                            &cache.info,
                            static_cast<int>(codepoint),
                            static_cast<int>(codepoints[index + 1]))) * scaleXf));
                }
            }

            layout.width = std::max(0, layout.maxRight - layout.minLeft);
            layout.verticalAdvance = std::max(1, layout.height + std::max(1, scaleY / 2));
            return layout;
        }

        void plotBitmap(
            int baseX,
            int baseY,
            const unsigned char *bitmap,
            int width,
            int height,
            int color)
        {
            if (bitmap == nullptr || width <= 0 || height <= 0)
            {
                return;
            }

            for (int row = 0; row < height; ++row)
            {
                for (int col = 0; col < width; ++col)
                {
                    const unsigned char alpha = bitmap[row * width + col];
                    if (alpha >= 96)
                    {
                        setPixelWithMode(baseX + col, baseY + row, color, gState.writeMode);
                    }
                }
            }
        }
    } // namespace

    bool isOutlineFont(int fontId)
    {
        return findOutlineFont(fontId) != nullptr;
    }

    const char *outlineFontName(int fontId)
    {
        const auto *asset = findOutlineFont(fontId);
        return asset != nullptr ? asset->name : nullptr;
    }

    int outlineFontIdFromName(const std::string &name)
    {
        const std::string normalized = normalizeName(name);
        for (const auto &asset : kOutlineFonts)
        {
            if (normalizeName(asset.name) == normalized)
            {
                return asset.id;
            }
        }
        return -1;
    }

    std::pair<int, int> measureOutlineText(
        int fontId,
        const std::vector<std::uint32_t> &codepoints,
        int scaleX,
        int scaleY,
        bool vertical)
    {
        const auto *asset = findOutlineFont(fontId);
        if (asset == nullptr || codepoints.empty())
        {
            return {0, 0};
        }

        if (!vertical)
        {
            const auto layout = buildHorizontalLayout(*asset, codepoints, scaleX, scaleY);
            return {layout.width, layout.height};
        }

        int maxWidth = 0;
        int totalHeight = 0;
        for (auto codepoint : codepoints)
        {
            const auto layout = buildHorizontalLayout(*asset, {codepoint}, scaleX, scaleY);
            maxWidth = std::max(maxWidth, layout.width);
            totalHeight += layout.verticalAdvance;
        }
        return {maxWidth, totalHeight};
    }

    void drawOutlineText(
        int x,
        int y,
        int fontId,
        const std::vector<std::uint32_t> &codepoints,
        int color,
        int scaleX,
        int scaleY,
        bool vertical)
    {
        const auto *asset = findOutlineFont(fontId);
        if (asset == nullptr || codepoints.empty())
        {
            return;
        }

        auto &cache = fontCache(*asset);
        if (!cache.valid)
        {
            return;
        }

        const float pixelHeight = static_cast<float>(std::max(1, scaleY) * 14);
        const float scaleYf = stbtt_ScaleForPixelHeight(&cache.info, pixelHeight);
        const float scaleXf = scaleYf * static_cast<float>(std::max(1, scaleX)) /
                              static_cast<float>(std::max(1, scaleY));

        if (!vertical)
        {
            const auto layout = buildHorizontalLayout(*asset, codepoints, scaleX, scaleY);
            const int baselineY = y + layout.baseline;
            const int originX = x - layout.minLeft;

            for (const auto &placement : layout.glyphs)
            {
                int width = 0;
                int height = 0;
                int xoff = 0;
                int yoff = 0;
                unsigned char *bitmap = stbtt_GetCodepointBitmap(
                    &cache.info,
                    scaleXf,
                    scaleYf,
                    static_cast<int>(placement.codepoint),
                    &width,
                    &height,
                    &xoff,
                    &yoff);

                plotBitmap(originX + placement.penAdvance + xoff, baselineY + yoff, bitmap, width, height, color);
                stbtt_FreeBitmap(bitmap, nullptr);
            }
            return;
        }

        int penY = y;
        for (auto codepoint : codepoints)
        {
            const auto layout = buildHorizontalLayout(*asset, {codepoint}, scaleX, scaleY);
            const int baselineY = penY + layout.baseline;
            const int originX = x - layout.minLeft;

            int width = 0;
            int height = 0;
            int xoff = 0;
            int yoff = 0;
            unsigned char *bitmap = stbtt_GetCodepointBitmap(
                &cache.info,
                scaleXf,
                scaleYf,
                static_cast<int>(codepoint),
                &width,
                &height,
                &xoff,
                &yoff);
            plotBitmap(originX + xoff, baselineY + yoff, bitmap, width, height, color);
            stbtt_FreeBitmap(bitmap, nullptr);
            penY += layout.verticalAdvance;
        }
    }

} // namespace bgi

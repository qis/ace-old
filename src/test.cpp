#include "doctest/doctest.h"
#include <array>
#include <string_view>
#include <vector>
#include <cassert>
#include <cstdint>

#include <fmt/format.h>
TEST_CASE("fmt")
{
  REQUIRE(fmt::format("{:.1f}", 0.32) == "0.3");
}

#include <date/tz.h>
TEST_CASE("tz")
{
#ifdef _WIN32
  date::set_install("C:/Ace/lib/tzdata");
#endif
  const auto tz = date::current_zone();
  REQUIRE(tz);
}

#include <pugixml.hpp>
TEST_CASE("pugixml")
{
  pugi::xml_document doc;
  REQUIRE(doc.load_string("<test>data</test>"));
  const auto child = doc.child("test");
  REQUIRE(child);
  const auto text = child.text();
  REQUIRE(text);
  REQUIRE(text.as_string() == std::string_view{ "data" });
}

#include <tbb/parallel_for.h>
TEST_CASE("tbb")
{
  bool success = true;
  std::vector<int> v(1'000, 1);
  tbb::parallel_for(tbb::blocked_range<std::size_t>(0, v.size()), [&](const auto& range) {
    for (auto i = range.begin(); i != range.end(); ++i) {
      success = success && v[i] == 1;
    }
  });
  REQUIRE(success);
}

#include <brotli/decode.h>
TEST_CASE("brotli")
{
  const auto v = BrotliDecoderVersion();
  const auto major = v >> 24 & 0xFF;
  const auto minor = v >> 12 & 0xFFF;
  const auto patch = v & 0xFFF;
  REQUIRE(major == 1);
  REQUIRE(minor == 0);
  REQUIRE(patch == 9);
}

#include <bzlib.h>
TEST_CASE("bzip2")
{
  const auto v = BZ2_bzlibVersion();
  REQUIRE(v);
  std::string_view vs{ v };
  if (const auto pos = vs.find_first_not_of("0123456789."); pos != std::string_view::npos) {
    vs = vs.substr(0, pos);
  }
  REQUIRE(vs == "1.0.8");
}

#include <lzma.h>
TEST_CASE("lzma")
{
  const auto version = lzma_version_number();
  const auto major = version / UINT32_C(10000000);
  const auto minor = (version - major * UINT32_C(10000000)) / UINT32_C(10000);
  const auto patch = (version - major * UINT32_C(10000000) - minor * UINT32_C(10000)) / UINT32_C(10);
  REQUIRE(major == 5);
  REQUIRE(minor == 2);
  REQUIRE(patch == 5);
}

#include <zlib.h>
TEST_CASE("zlib")
{
  const auto vs = zlibVersion();
  REQUIRE(vs);
  REQUIRE(vs == std::string_view{ "1.2.11" });
}

#include <zstd.h>
TEST_CASE("zstd")
{
  const auto version = ZSTD_versionNumber();
  const auto major = (version / 100 / 100);
  const auto minor = (version - major * 100 * 100) / 100;
  const auto patch = (version - major * 100 * 100 - minor * 100);
  REQUIRE(major == 1);
  REQUIRE(minor == 4);
  REQUIRE(patch == 5);
}

#include <jpeglib.h>
#include <turbojpeg.h>
TEST_CASE("jpeg")
{
  std::uint32_t version = LIBJPEG_TURBO_VERSION_NUMBER;
  const auto major = version / 1000000;
  const auto minor = (version - major * 1000000) / 1000;
  const auto patch = version - major * 1000000 - minor * 1000;
  REQUIRE(major == 2);
  REQUIRE(minor == 0);
  REQUIRE(patch == 5);

  jpeg_error_mgr jerr = {};
  jpeg_compress_struct cinfo = {};
  cinfo.err = jpeg_std_error(&jerr);

  jpeg_create_compress(&cinfo);
  REQUIRE(cinfo.mem);

  jpeg_destroy_compress(&cinfo);
  REQUIRE(!cinfo.mem);

  const auto compressor = tjInitCompress();
  REQUIRE(compressor);
  REQUIRE(tjDestroy(compressor) == 0);
}

#include <png.h>
TEST_CASE("png")
{
  const auto vs = png_libpng_ver;
  REQUIRE(vs);
  REQUIRE(std::string_view{ vs } == "1.6.37");
}

#include <webp/decode.h>
#include <webp/demux.h>
#include <webp/encode.h>
#include <webp/mux.h>
TEST_CASE("webp")
{
  std::array<std::uint32_t, 4> versions = {
    static_cast<std::uint32_t>(WebPGetDecoderVersion()),
    static_cast<std::uint32_t>(WebPGetEncoderVersion()),
    static_cast<std::uint32_t>(WebPGetDemuxVersion()),
    static_cast<std::uint32_t>(WebPGetMuxVersion()),
  };
  for (const auto v : versions) {
    const auto major = v >> 16 & 0xFF;
    const auto minor = v >> 8 & 0xFF;
    const auto patch = v & 0xFF;
    REQUIRE(major == 1);
    REQUIRE(minor == 1);
    REQUIRE(patch == 0);
  }
}

#include <tiffio.hxx>
TEST_CASE("tiff")
{
  // clang-format off
  std::array<char, 72> buffer = {
    0x49, 0x49, 0x2A, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x01, 0x03, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x03, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x11, 0x01, 0x04, 0x00, 0x01, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x17, 0x01, 0x04, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
  };
  // clang-format on
  std::istringstream is{ std::string{ buffer.data(), buffer.size() } };
  const auto tif = TIFFStreamOpen("buffer.tiff", &is);
  REQUIRE(true);
  TIFFClose(tif);
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  return context.run();
}

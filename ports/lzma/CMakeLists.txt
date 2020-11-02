cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(lzma VERSION 5.2.5 LANGUAGES C)

set(URL "https://tukaani.org/xz/xz-${PROJECT_VERSION}.tar.gz")
set(SHA "f6f4910fd033078738bd82bfba4f49219d03b17eb0794eb91efbae419f4aba10")
download_source(${URL} ${SHA} src configure.patch)

# Headers
set(headers
  src/src/common/mythread.h
  src/src/common/sysdefs.h
  src/src/common/tuklib_common.h
  src/src/common/tuklib_config.h
  src/src/common/tuklib_cpucores.h
  src/src/common/tuklib_integer.h
  src/src/common/tuklib_physmem.h
  src/src/liblzma/api/lzma.h
  src/src/liblzma/api/lzma/base.h
  src/src/liblzma/api/lzma/bcj.h
  src/src/liblzma/api/lzma/block.h
  src/src/liblzma/api/lzma/check.h
  src/src/liblzma/api/lzma/container.h
  src/src/liblzma/api/lzma/delta.h
  src/src/liblzma/api/lzma/filter.h
  src/src/liblzma/api/lzma/hardware.h
  src/src/liblzma/api/lzma/index.h
  src/src/liblzma/api/lzma/index_hash.h
  src/src/liblzma/api/lzma/lzma12.h
  src/src/liblzma/api/lzma/stream_flags.h
  src/src/liblzma/api/lzma/version.h
  src/src/liblzma/api/lzma/vli.h
  src/src/liblzma/check/check.h
  src/src/liblzma/check/crc32_table_be.h
  src/src/liblzma/check/crc32_table_le.h
  src/src/liblzma/check/crc64_table_be.h
  src/src/liblzma/check/crc64_table_le.h
  src/src/liblzma/check/crc_macros.h
  src/src/liblzma/common/alone_decoder.h
  src/src/liblzma/common/block_buffer_encoder.h
  src/src/liblzma/common/block_decoder.h
  src/src/liblzma/common/block_encoder.h
  src/src/liblzma/common/common.h
  src/src/liblzma/common/easy_preset.h
  src/src/liblzma/common/filter_common.h
  src/src/liblzma/common/filter_decoder.h
  src/src/liblzma/common/filter_encoder.h
  src/src/liblzma/common/index.h
  src/src/liblzma/common/index_encoder.h
  src/src/liblzma/common/memcmplen.h
  src/src/liblzma/common/outqueue.h
  src/src/liblzma/common/stream_decoder.h
  src/src/liblzma/common/stream_flags_common.h
  src/src/liblzma/delta/delta_common.h
  src/src/liblzma/delta/delta_decoder.h
  src/src/liblzma/delta/delta_encoder.h
  src/src/liblzma/delta/delta_private.h
  src/src/liblzma/lzma/fastpos.h
  src/src/liblzma/lzma/lzma2_decoder.h
  src/src/liblzma/lzma/lzma2_encoder.h
  src/src/liblzma/lzma/lzma_common.h
  src/src/liblzma/lzma/lzma_decoder.h
  src/src/liblzma/lzma/lzma_encoder.h
  src/src/liblzma/lzma/lzma_encoder_private.h
  src/src/liblzma/lz/lz_decoder.h
  src/src/liblzma/lz/lz_encoder.h
  src/src/liblzma/lz/lz_encoder_hash.h
  src/src/liblzma/lz/lz_encoder_hash_table.h
  src/src/liblzma/rangecoder/price.h
  src/src/liblzma/rangecoder/range_common.h
  src/src/liblzma/rangecoder/range_decoder.h
  src/src/liblzma/rangecoder/range_encoder.h
  src/src/liblzma/simple/simple_coder.h
  src/src/liblzma/simple/simple_decoder.h
  src/src/liblzma/simple/simple_encoder.h
  src/src/liblzma/simple/simple_private.h
  include/config.h)

# Sources
set(sources
  src/src/common/tuklib_cpucores.c
  src/src/common/tuklib_physmem.c
  src/src/liblzma/check/check.c
  src/src/liblzma/check/crc32_fast.c
  src/src/liblzma/check/crc32_table.c
  src/src/liblzma/check/crc64_fast.c
  src/src/liblzma/check/crc64_table.c
  src/src/liblzma/check/sha256.c
  src/src/liblzma/common/alone_decoder.c
  src/src/liblzma/common/alone_encoder.c
  src/src/liblzma/common/auto_decoder.c
  src/src/liblzma/common/block_buffer_decoder.c
  src/src/liblzma/common/block_buffer_encoder.c
  src/src/liblzma/common/block_decoder.c
  src/src/liblzma/common/block_encoder.c
  src/src/liblzma/common/block_header_decoder.c
  src/src/liblzma/common/block_header_encoder.c
  src/src/liblzma/common/block_util.c
  src/src/liblzma/common/common.c
  src/src/liblzma/common/easy_buffer_encoder.c
  src/src/liblzma/common/easy_decoder_memusage.c
  src/src/liblzma/common/easy_encoder.c
  src/src/liblzma/common/easy_encoder_memusage.c
  src/src/liblzma/common/easy_preset.c
  src/src/liblzma/common/filter_buffer_decoder.c
  src/src/liblzma/common/filter_buffer_encoder.c
  src/src/liblzma/common/filter_common.c
  src/src/liblzma/common/filter_decoder.c
  src/src/liblzma/common/filter_encoder.c
  src/src/liblzma/common/filter_flags_decoder.c
  src/src/liblzma/common/filter_flags_encoder.c
  src/src/liblzma/common/hardware_cputhreads.c
  src/src/liblzma/common/hardware_physmem.c
  src/src/liblzma/common/index.c
  src/src/liblzma/common/index_decoder.c
  src/src/liblzma/common/index_encoder.c
  src/src/liblzma/common/index_hash.c
  src/src/liblzma/common/outqueue.c
  src/src/liblzma/common/stream_buffer_decoder.c
  src/src/liblzma/common/stream_buffer_encoder.c
  src/src/liblzma/common/stream_decoder.c
  src/src/liblzma/common/stream_encoder.c
  src/src/liblzma/common/stream_encoder_mt.c
  src/src/liblzma/common/stream_flags_common.c
  src/src/liblzma/common/stream_flags_decoder.c
  src/src/liblzma/common/stream_flags_encoder.c
  src/src/liblzma/common/vli_decoder.c
  src/src/liblzma/common/vli_encoder.c
  src/src/liblzma/common/vli_size.c
  src/src/liblzma/delta/delta_common.c
  src/src/liblzma/delta/delta_decoder.c
  src/src/liblzma/delta/delta_encoder.c
  src/src/liblzma/lzma/fastpos_table.c
  src/src/liblzma/lzma/lzma2_decoder.c
  src/src/liblzma/lzma/lzma2_encoder.c
  src/src/liblzma/lzma/lzma_decoder.c
  src/src/liblzma/lzma/lzma_encoder.c
  src/src/liblzma/lzma/lzma_encoder_optimum_fast.c
  src/src/liblzma/lzma/lzma_encoder_optimum_normal.c
  src/src/liblzma/lzma/lzma_encoder_presets.c
  src/src/liblzma/lz/lz_decoder.c
  src/src/liblzma/lz/lz_encoder.c
  src/src/liblzma/lz/lz_encoder_mf.c
  src/src/liblzma/rangecoder/price_table.c
  src/src/liblzma/simple/arm.c
  src/src/liblzma/simple/armthumb.c
  src/src/liblzma/simple/ia64.c
  src/src/liblzma/simple/powerpc.c
  src/src/liblzma/simple/simple_coder.c
  src/src/liblzma/simple/simple_decoder.c
  src/src/liblzma/simple/simple_encoder.c
  src/src/liblzma/simple/sparc.c
  src/src/liblzma/simple/x86.c)

# Library
add_library(lzma ${headers} ${sources})
target_include_directories(lzma BEFORE PUBLIC
  include
  src/src/liblzma/common
  src/src/common
  src/src/liblzma/api
  src/src/liblzma/check
  src/src/liblzma/delta
  src/src/liblzma/lz
  src/src/liblzma/lzma
  src/src/liblzma/rangecoder
  src/src/liblzma/simple)

target_compile_definitions(lzma PRIVATE HAVE_CONFIG_H DLL_EXPORT)

if(MSVC)
  target_compile_options(lzma PRIVATE /wd4005 /wd4244 /wd4267 /wd4996 /wd5105)
endif()

# Install
install(TARGETS lzma)

if(NOT SKIP_INSTALL_HEADERS)
  install(DIRECTORY src/src/liblzma/api/lzma DESTINATION include)
  install(FILES src/src/liblzma/api/lzma.h DESTINATION include)
endif()

MFLAGS = --no-print-directory
TARGET =

all: \
  benchmark doctest \
  date fmt pugixml tbb \
  brotli bzip2 lzma zlib zstd \
  jpeg png webp

benchmark:
	@$(MAKE) $(MFLAGS) install/target TARGET=benchmark

doctest:
	@$(MAKE) $(MFLAGS) install/target TARGET=doctest

date:
	@$(MAKE) $(MFLAGS) install/target TARGET=date

fmt:
	@$(MAKE) $(MFLAGS) install/target TARGET=fmt

pugixml:
	@$(MAKE) $(MFLAGS) install/target TARGET=pugixml

tbb:
	@$(MAKE) $(MFLAGS) install/target TARGET=tbb

brotli:
	@$(MAKE) $(MFLAGS) install/target TARGET=brotli

bzip2:
	@$(MAKE) $(MFLAGS) install/target TARGET=bzip2

lzma:
	@$(MAKE) $(MFLAGS) install/target TARGET=lzma

zlib:
	@$(MAKE) $(MFLAGS) install/target TARGET=zlib

zstd:
	@$(MAKE) $(MFLAGS) install/target TARGET=zstd

jpeg:
	@$(MAKE) $(MFLAGS) install/target TARGET=jpeg

png:
	@$(MAKE) $(MFLAGS) install/target TARGET=png

webp:
	@$(MAKE) $(MFLAGS) install/target TARGET=webp

configure/target: \
  build/$(TARGET)/debug/rules.ninja \
  build/$(TARGET)/release/rules.ninja \
  build/$(TARGET)/minsizerel/rules.ninja \
  build/$(TARGET)/relwithdebinfo/rules.ninja

build/target: configure/target
	@ninja -C build/$(TARGET)/debug
	@ninja -C build/$(TARGET)/release
	@ninja -C build/$(TARGET)/minsizerel
	@ninja -C build/$(TARGET)/relwithdebinfo

install/target: build/target
	@ninja -C build/$(TARGET)/debug install
	@ninja -C build/$(TARGET)/release install
	@ninja -C build/$(TARGET)/minsizerel install
	@ninja -C build/$(TARGET)/relwithdebinfo install

build/$(TARGET)/debug/rules.ninja: ports/$(TARGET)/CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=ON \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/ports/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(TARGET)/debug \
	  -S ports/$(TARGET)

build/$(TARGET)/release/rules.ninja: ports/$(TARGET)/CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/ports/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(TARGET)/release \
	  -S ports/$(TARGET)

build/$(TARGET)/minsizerel/rules.ninja: ports/$(TARGET)/CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/ports/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(TARGET)/minsizerel \
	  -S ports/$(TARGET)

build/$(TARGET)/relwithdebinfo/rules.ninja: ports/$(TARGET)/CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=ON \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/ports/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(TARGET)/relwithdebinfo \
	  -S ports/$(TARGET)

# Clean
clean:
	@cmake -E remove_directory build

# Reset
reset: clean
	@cmake -E remove_directory bin
	@cmake -E remove_directory include
	@cmake -E remove_directory lib

# Delete
delete: reset
	@cmake -E remove_directory ports/benchmark/src
	@cmake -E remove_directory ports/brotli/src
	@cmake -E remove_directory ports/bzip2/src
	@cmake -E remove_directory ports/date/src
	@cmake -E remove_directory ports/doctest/src
	@cmake -E remove_directory ports/fmt/src
	@cmake -E remove_directory ports/jpeg/src
	@cmake -E remove_directory ports/lzma/src
	@cmake -E remove_directory ports/png/src
	@cmake -E remove_directory ports/pugixml/src
	@cmake -E remove_directory ports/tbb/src
	@cmake -E remove_directory ports/webp/src
	@cmake -E remove_directory ports/zlib/src
	@cmake -E remove_directory ports/zstd/src

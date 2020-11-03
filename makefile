MAKEFLAGS += --no-print-directory

MFKAGS =
TARGET =

all: benchmark doctest date fmt pugixml tbb brotli bzip2 lzma zlib zstd

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

configure/target: \
  build/$(TARGET)/ace/rules.ninja \
  build/$(TARGET)/debug/rules.ninja \
  build/$(TARGET)/release/rules.ninja

build/target: configure/target
	@ninja -C build/$(TARGET)/ace
	@ninja -C build/$(TARGET)/debug
	@ninja -C build/$(TARGET)/release

install/target: build/target
	@ninja -C build/$(TARGET)/ace install
	@ninja -C build/$(TARGET)/debug install
	@ninja -C build/$(TARGET)/release install

build/$(TARGET)/ace/rules.ninja: ports/$(TARGET)/CMakeLists.txt
	@cmake -GNinja -DCMAKE_BUILD_TYPE=Ace -DBUILD_SHARED_LIBS=ON \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/ports/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(TARGET)/ace \
	  -S ports/$(TARGET)

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
	@cmake -E remove_directory ports/lzma/src
	@cmake -E remove_directory ports/pugixml/src
	@cmake -E remove_directory ports/tbb/src
	@cmake -E remove_directory ports/zlib/src
	@cmake -E remove_directory ports/zstd/src

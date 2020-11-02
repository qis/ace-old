SYSTEM = linux
PREFIX = /opt/ace

# Build
all: configure
	@ninja -C build/$(SYSTEM) -f build-Ace.ninja
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja
	@ninja -C build/$(SYSTEM) -f build-Release.ninja

# Configure
build/$(SYSTEM)/build.ninja: CMakeLists.txt
	@cmake -G "Ninja Multi-Config" \
	  -DCMAKE_CONFIGURATION_TYPES="Ace;Debug;Release" \
	  -DCMAKE_TOOLCHAIN_FILE="$(PREFIX)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -B build/$(SYSTEM)

configure: build/$(SYSTEM)/build.ninja

# Run
run: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja main
	@cmake -E chdir build/$(SYSTEM)/Debug ./main

# Test
test: configure
	@ninja -C build/$(SYSTEM) -f build-Ace.ninja test
	@cmake -E chdir build/$(SYSTEM)/Ace ./test
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja test
	@cmake -E chdir build/$(SYSTEM)/Debug ./test
	@ninja -C build/$(SYSTEM) -f build-Release.ninja test
	@cmake -E chdir build/$(SYSTEM)/Release ./test

# Benchmark
benchmark: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja benchmark
	@cmake -E chdir build/$(SYSTEM)/Release ./benchmark

# Format
format:
	@cmake -P $(PREFIX)/format.cmake src

# Clean
clean:
	@cmake -E remove_directory build/$(SYSTEM)

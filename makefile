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
	@ninja -C build/$(SYSTEM) -f build-Ace.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Ace ./tests
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Debug ./tests
	@ninja -C build/$(SYSTEM) -f build-Release.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Release ./tests

# Benchmark
benchmark: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/Release ./benchmarks

# Format
format:
	@cmake -P $(PREFIX)/format.cmake src

# Clean
clean:
	@cmake -E remove_directory build/$(SYSTEM)

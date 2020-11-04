SYSTEM = linux
PREFIX = /opt/ace

# Build
all: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja
	@ninja -C build/$(SYSTEM) -f build-Release.ninja
	@ninja -C build/$(SYSTEM) -f build-MinSizeRel.ninja
	@ninja -C build/$(SYSTEM) -f build-RelWithDebInfo.ninja

# Configure
build/$(SYSTEM)/build.ninja: CMakeLists.txt
	@cmake -G "Ninja Multi-Config" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo" \
	  -DCMAKE_TOOLCHAIN_FILE="$(PREFIX)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/install" \
	  -B build/$(SYSTEM)

configure: build/$(SYSTEM)/build.ninja

# Run
run: configure
	@ninja -v -C build/$(SYSTEM) -f build-Debug.ninja
	@cmake -P $(PREFIX)/run.cmake build/$(SYSTEM) Debug main

# Test
test: configure
	@ninja -C build/$(SYSTEM) -f build-Debug.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Debug ./tests
	@ninja -C build/$(SYSTEM) -f build-Release.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Release ./tests
	@ninja -C build/$(SYSTEM) -f build-MinSizeRel.ninja tests
	@cmake -E chdir build/$(SYSTEM)/MinSizeRel ./tests
	@ninja -C build/$(SYSTEM) -f build-RelWithDebInfo.ninja tests
	@cmake -E chdir build/$(SYSTEM)/RelWithDebInfo ./tests

# Benchmark
benchmark: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/Release ./benchmarks
	@ninja -C build/$(SYSTEM) -f build-MinSizeRel.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/MinSizeRel ./benchmarks

# Install
install: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja install

# Package
package: configure
	@ninja -C build/$(SYSTEM) -f build-Release.ninja package

# Format
format:
	@cmake -P $(PREFIX)/format.cmake src

# Clean
clean:
	@cmake -E remove_directory build/$(SYSTEM)

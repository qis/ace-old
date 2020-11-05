SYSTEM = linux
PREFIX = /opt/ace

# Build
all: configure
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Debug.ninja main tests benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Release.ninja main tests benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-MinSizeRel.ninja main tests benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-RelWithDebInfo.ninja main tests benchmarks

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
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Debug.ninja main
	@cmake -E chdir build/$(SYSTEM)/Debug ./main

# Test
test: configure
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Debug.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Debug ./tests
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Release.ninja tests
	@cmake -E chdir build/$(SYSTEM)/Release ./tests
	@cmake -E chdir build/$(SYSTEM) ninja -f build-MinSizeRel.ninja tests
	@cmake -E chdir build/$(SYSTEM)/MinSizeRel ./tests
	@cmake -E chdir build/$(SYSTEM) ninja -f build-RelWithDebInfo.ninja tests
	@cmake -E chdir build/$(SYSTEM)/RelWithDebInfo ./tests

# Benchmark
benchmark: configure
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Debug.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/Debug ./benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-Release.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/Release ./benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-MinSizeRel.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/MinSizeRel ./benchmarks
	@cmake -E chdir build/$(SYSTEM) ninja -f build-RelWithDebInfo.ninja benchmarks
	@cmake -E chdir build/$(SYSTEM)/RelWithDebInfo ./benchmarks

# Format
format:
	@cmake -P $(PREFIX)/format.cmake src

# Clean
clean:
	@cmake -E remove_directory build/$(SYSTEM)

# Ace
C++ toolchain for Windows and Linux.

## Windows

<details>
<summary><b>Requirements</b></summary>

Install [Git](https://git-scm.com/downloads).

```
Select Components
☐ Windows Explorer integration
☐ Associate .git* configuration files with the default text editor
☐ Associate .sh files to be run with Bash

Choosing the default editor used by Git
Use Visual Studio Code as Git's default editor

Adjusting the name of the initial branch in new repositories
◉ Override the default branch name for new repositories
Specify the name "git init" should use for the initial branch: master

Configuring the line ending conversions
◉ Checkout as-is, commit as-is

Configuring the terminal emulator to use Git Bash
◉ Use Windows' default console window

Choose the default behavior of `git pull`
◉ Rebase

Choose a credential helper
◉ None
```

Install [LLVM](https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/LLVM-11.0.0-win64.exe).

```
Install Options
◉ Add LLVM to the system PATN for all users
```

Install [NASM](https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-installer-x64.exe)

```
☐ RDOFF
☐ Manual
☐ VS8 integration
```

Install [Visual Studio Preview](https://visualstudio.microsoft.com/vs/preview/).

```
Workloads
☑ Desktop development with C++
☑ Node.js development

Installation Details
+ Desktop development with C++
  ☐ Test Adapter for Boost.Test
  ☐ Test Adapter for Google Test
  ☐ Live Share
+ Node.js development
  ☐ Web Deploy
```

Install Visual Studio extensions.

- [Hide Suggestion And Outlining Margins][hi]
- [Trailing Whitespace Visualizer][ws]

[hi]: https://marketplace.visualstudio.com/items?itemName=MussiKara.HideSuggestionAndOutliningMargins
[ws]: https://marketplace.visualstudio.com/items?itemName=MadsKristensen.TrailingWhitespaceVisualizer

Add the following directories to the `Path` system environment variable.

```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Msbuild\Microsoft\VisualStudio\NodeJs
C:\Program Files\NASM
```

Set the `VSCMD_SKIP_SENDTELEMETRY` system environment variable to `1`.

</details>

Install toolchain.

```cmd
git clone -b develop https://github.com/qis/ace C:/Ace
cd C:\Ace && make
```

Add `C:\Ace\bin` to the system `Path` environment variable.

## Ubuntu

<details>
<summary><b>Requirements</b></summary>

Install basic development packages.

```sh
sudo apt install -y binutils-dev gcc-10 g++-10 gdb make nasm ninja-build manpages-dev
```

Install [CMake](https://cmake.org/).

```sh
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4-Linux-x86_64.tar.gz
sudo tar xf cmake-3.18.4-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
rm -f cmake-3.18.4-Linux-x86_64.tar.gz

sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
. /etc/profile.d/cmake.sh
```

Install [Node](https://nodejs.org/).

```sh
sudo rm -rf /opt/node; sudo mkdir -p /opt/node
wget https://nodejs.org/dist/v12.16.3/node-v12.16.3-linux-x64.tar.xz
sudo tar xf node-v12.16.3-linux-x64.tar.xz -C /opt/node --strip-components=1
rm -f node-v12.16.3-linux-x64.tar.xz

sudo tee /etc/profile.d/node.sh >/dev/null <<'EOF'
export PATH="/opt/node/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/node.sh
. /etc/profile.d/node.sh
```

Set system GCC C and C++ compiler.

```sh
for i in gcc; do sudo update-alternatives --remove-all $i; done
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100
```

Set system C and C++ compiler.

```sh
for i in c++ cc; do sudo update-alternatives --remove-all $i; done
sudo update-alternatives --install /usr/bin/gcc cc  /usr/bin/gcc 100
sudo update-alternatives --install /usr/bin/g++ c++ /usr/bin/g++ 100
```

</details>

Install toolchain.

```sh
sudo mkdir /opt/ace
sudo chown $(id -un):$(id -gn) /opt/ace
git clone -b develop https://github.com/qis/ace /opt/ace
cd /opt/ace && make
```

## Ports
This toolchain includes the following third party libraries.

### Development
- [benchmark](https://github.com/google/benchmark/releases) 1.5.2
- [doctest](https://github.com/onqtam/doctest/releases) 2.4.0

### Utility
- [date](https://github.com/HowardHinnant/date) 3.0.0
- [fmt](https://github.com/fmtlib/fmt/releases) 7.1.0
- [pugixml](https://github.com/zeux/pugixml/releases) 1.10
- [tbb](https://github.com/oneapi-src/oneTBB/releases) 2020.3

### Compression
- [brotli](https://github.com/google/brotli/releases) 1.0.9
- [bzip2](https://sourceware.org/pub/bzip2/) 1.0.8
- [lzma](https://tukaani.org/xz/) 5.2.5
- [zlib](https://www.zlib.net/) 1.2.11
- [zstd](https://github.com/facebook/zstd/releases) 1.4.5

### Image Formats
- [jpeg](https://github.com/libjpeg-turbo/libjpeg-turbo/releases) 2.0.5
- [png](http://www.libpng.org/pub/png/libpng.html) 1.6.37
- [webp](https://developers.google.com/speed/webp/download) 1.1.0

# Cascades/QML starter (CMake)

This variant uses CMake with a BB10 qcc toolchain file so the executable lands in a predictable output directory for packaging.

```bash
make
```

If you open the project in an editor with CMake support, configure it with:

```bash
cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=../../cmake/bb10-qcc-toolchain.cmake
cmake --build build
```

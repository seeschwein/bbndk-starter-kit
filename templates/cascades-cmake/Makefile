APP := cascadeshello
BUILD := build
TOOLCHAIN := ../../cmake/bb10-qcc-toolchain.cmake

.PHONY: all configure compile package clean
all: package

configure:
	mkdir -p $(BUILD)
	cmake -S . -B $(BUILD) -G Ninja -DCMAKE_TOOLCHAIN_FILE=$(TOOLCHAIN)

compile: configure
	cmake --build $(BUILD)

package: compile
	blackberry-nativepackager -package $(APP).bar -devMode bar-descriptor.xml

clean:
	rm -rf build $(APP).bar

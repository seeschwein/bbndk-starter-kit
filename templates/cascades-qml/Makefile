APP := cascadeshello
BUILD := build/arm
QMAKE ?= qmake

.PHONY: all configure compile package clean
all: package
configure:
	mkdir -p $(BUILD)
	cd $(BUILD) && $(QMAKE) ../../$(APP).pro CONFIG+=device
compile: configure
	$(MAKE) -C $(BUILD)
package: compile
	blackberry-nativepackager -package $(APP).bar -devMode bar-descriptor.xml
clean:
	rm -rf build $(APP).bar

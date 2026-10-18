APP := hellocli
CC := qcc
CFLAGS ?= -O2
QCC_TARGET ?= gcc_ntoarmv7le

.PHONY: all compile package inspect clean
all: package
compile: $(APP)
$(APP): hello.c
	$(CC) -V$(QCC_TARGET) $(CFLAGS) $< -o $@
package: $(APP)
	blackberry-nativepackager -package $(APP).bar -devMode bar-descriptor.xml
inspect: package
	blackberry-nativepackager -list $(APP).bar bar-descriptor.xml
clean:
	rm -f $(APP) $(APP).bar

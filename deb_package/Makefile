#!/usr/bin/make -f
# -*- makefile -*-
#--------------------------------------------------------------------- Variables
SERVER_VERSION = $(version)
#SERVER_BUILD_NUMBER = "$(BUILD_NUMBER).$(BUILD_BRANCH)"
SERVER_BASE = /opt/server
#UI_BASE = /usr/share/nginx/html/dist
#UI_BASE_ML = /usr/share/nginx/html/smart-datacenter-ml-ui
EXPLODED_FILES = `pwd`/build

default: deb
.PHONY: clean

clean:
	#dh_testdir
	#dh_testroot
	#dh_clean
	rm -rf build

.PHONY: prepare
prepare:
	mkdir -p $(EXPLODED_FILES)
	#mkdir -p $(EXPLODED_FILES)/dist
        #mkdir -p $(EXPLODED_FILES)/smart-datacenter-ml-ui
	unzip  `pwd`/Awakedata-server-*.zip -d $(EXPLODED_FILES)
	cp -r `pwd`/DEBIAN $(EXPLODED_FILES)
	#sed -i s/"server_version"/$(SERVER_VERSION)/g $(CURDIR)/DEBIAN/control
	sed -i s/"server_version"/$(SERVER_VERSION)/g $(EXPLODED_FILES)/DEBIAN/control
	#tar xzvf $(CURDIR)/-${version}-*.tar -C $(EXPLODED_FILES)/server


.PHONY: build
build: prepare
	echo "build server"
	mkdir -p build/buildroot/$(SERVER_BASE)
	#mkdir -p build/buildroot/$(UI_BASE)
	#mkdir -p build/buildroot/$(UI_BASE_ML)
	mkdir -p build/buildroot/data/sw
	mkdir -p build/buildroot/preserve/logs
	mkdir -p build/buildroot/usr/lib/systemd/system/
	cp -r $(EXPLODED_FILES)/server-*/* build/buildroot/$(SERVER_BASE)/
	#cp custom.conf build/buildroot/$(SERVER_BASE)/conf/
	cp -r $(EXPLODED_FILES)/server-*/conf/* build/buildroot/data/sw
	#cp -r $(EXPLODED_FILES)/smart-datacenter-ui/dist/* build/buildroot/$(UI_BASE)/
	#cp -r $(EXPLODED_FILES)/smart-datacenter-ml-ui/dist/* build/buildroot/$(UI_BASE_ML)/
	cp $(EXPLODED_FILES)/server-*/conf/server.service build/buildroot/usr/lib/systemd/system/
	cp -r $(EXPLODED_FILES)/DEBIAN build/buildroot/
.PHONT: deb
deb: build
	dpkg -b `pwd`/build/buildroot Awakedata-server-$(SERVER_VERSION).deb

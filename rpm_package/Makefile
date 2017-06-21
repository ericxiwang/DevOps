#--------------------------------------------------------------------- Variables
ST_VERSION = $(version)
ST_BUILD_NUMBER = "$(BUILD_NUMBER).$(BUILD_BRANCH)"
ST_BASE = /opt/blueice/smart-datacenter
UI_BASE = /usr/share/nginx/html/smart-datacenter-ui
#UI_BASE_ML = /usr/share/nginx/html/smart-datacenter-ml-ui
EXPLODED_FILES = $(CURDIR)/build


#----------------------------------------------------------------------- Targets
default: rpm

.PHONY: clean
clean:
	rm -fr build

.PHONY: check
check:
ifndef version
	$(error "version" is undefined. Please define it by setting environmental variable "version". For example: export version=2.2)
endif
ifndef BUILD_NUMBER
	$(error BUILD_NUMBER is undefined. You can define it by setting environmental variable BUILD_NUMBER. For exampleL export BUILD_NUMBER=25)
endif

.PHONY: prepare
prepare:
	mkdir -p $(EXPLODED_FILES)
	mkdir -p $(EXPLODED_FILES)/smart-datacenter-ui
	#mkdir -p $(EXPLODED_FILES)/smart-datacenter-ml-ui
	unzip  $(CURDIR)/server-$(version)-* -d $(EXPLODED_FILES)
	tar xzvf $(CURDIR)/smart_datacenter_ui-${version}-*.tar -C $(EXPLODED_FILES)/smart-datacenter-ui
	#tar xzvf $(CURDIR)/smart-datacenter-ml-ui-${version}-*.tar -C $(EXPLODED_FILES)/smart-datacenter-ml-ui

.PHONY: build
build: prepare
	echo "Building $(ST_VERSION)"
	# Priming buildroot with exploded JMeter
	mkdir -p build/buildroot/$(ST_BASE)
	mkdir -p build/buildroot/$(UI_BASE)
	#mkdir -p build/buildroot/$(UI_BASE_ML)
	mkdir -p build/buildroot/data/sw
	mkdir -p build/buildroot/preserve/logs
	mkdir -p build/buildroot/usr/lib/systemd/system/
	cp -r $(EXPLODED_FILES)/server-$(version)-*/* build/buildroot/$(ST_BASE)/
	cp custom.conf build/buildroot/$(ST_BASE)/conf/
	cp -r $(EXPLODED_FILES)/server-$(version)-*/conf/* build/buildroot/data/sw
	cp -r $(EXPLODED_FILES)/smart-datacenter-ui/dist/* build/buildroot/$(UI_BASE)/
	#cp -r $(EXPLODED_FILES)/smart-datacenter-ml-ui/dist/* build/buildroot/$(UI_BASE_ML)/
	cp smart-datacenter.service build/buildroot/usr/lib/systemd/system/
	#cp ChangeLog build/buildroot/$(BASE)/
	#mkdir -p build/buildroot/etc/profile.d
	#echo 'export PATH="$(BASE)/extras:$$PATH"' > build/buildroot/etc/profile.d/jmeter-si.sh


.PHONY: rpm
rpm: build
	rpmbuild -bb                            \
	         --buildroot $(CURDIR)/build/buildroot    \
	         --define="_rpmdir ./build"     \
	         --define="VERSION $(version)"  \
	         --define="RELEASE $(ST_BUILD_NUMBER)"  \
	         --define="__prefix /"    \
	         --define="_target_os Linux"    \
	         Specfile


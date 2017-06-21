Instructions
============

This project is used to build blueice-smart-terminal rpm package.
In order for build to complete you will need to manually download
terminal_server.zip and smart-terminal-ui.tar into project root.
You can find these artifacts on jenkins server.

If trying this on your machine:

```
make clean
version=2.1 BUILD_NUMBER=1 make rpm
```

If integrating with jenkins:
1. Make sure you pass `version` parameter in your jenkins job
2. Build step will look like this:
```
make clean
make rpm
```

RPM can be found in `build/x86_64/`

```yum --showduplicates list | grep blueice```
```
output sample:
blueice-smart-datacenter.x86_64          2.1-51.dev                      northstar-development
blueice-smart-datacenter.x86_64          2.1-52.release                  northstar-production
```
yum install <package name>-<version info>

```yum install blueice-smart-datacenter-2.1-52.release ```

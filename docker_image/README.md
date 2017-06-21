Setup
=====
put `config` file in `~/.docker/` folder

Build
=====
docker build -t ericxiwang/smart-terminal:${version}-${BUILD_NUMBER} .
docker push ericxiwang/smart-terminal:${version}-${BUILD_NUMBER}

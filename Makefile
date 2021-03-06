# Makefile based on https://github.com/Masterminds/glide/blob/master/Makefile

GO                 ?= go
DIST_DIRS          := find * -type d -exec
VERSION            ?= $(shell git describe --tags)

build:
	${GO} build -o apisite -ldflags "-X main.version=${VERSION}" *.go

install: build
	install -d ${DESTDIR}/usr/local/bin/
	install -m 755 ./apisite ${DESTDIR}/usr/local/bin/apisite

clean:
	rm -f ./apisite
	rm -rf ./dist

vendor:
	@echo "*** $@:glide ***"
	which glide > /dev/null || curl https://glide.sh/get | sh
	@echo "*** $@ ***"
	glide install

bootstrap-dist:
	${GO} get -u github.com/Masterminds/gox

build-all:
	gox -verbose \
	-ldflags "-X main.version=${VERSION}" \
	-os="linux darwin windows" \
	-arch="amd64 386" \
	-osarch="!darwin/arm64" \
	-output="dist/{{.OS}}-{{.Arch}}/{{.Dir}}" .

dist: build-all
	cd dist && \
	$(DIST_DIRS) cp ../LICENSE {} \; && \
	$(DIST_DIRS) cp ../README.md {} \; && \
	$(DIST_DIRS) tar -zcf apisite-${VERSION}-{}.tar.gz {} \; && \
	$(DIST_DIRS) zip -r apisite-${VERSION}-{}.zip {} \; && \
	cd ..

.PHONY: build install clean bootstrap-dist build-all dist

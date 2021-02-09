
PP=`pwd`
DIR=../F20-1015
IMG=
PY=


all: README.md README.html build

build:
	( cd bsvr/main ; go build main.go )

%.md: %.raw.md $(PY) $(IMG) Makefile
	m4 -P $< >$@

%.html: %.md
	blackfriday-tool ./$< $@
	echo cat ./${DIR}/md.css $@ >/tmp/$@
	cat ./${DIR}/css/pre ./${DIR}/css/markdown.css ./${DIR}/css/post ./${DIR}/md.css ./${DIR}/css/hpre $@ ./${DIR}/css/hpost >/tmp/$@
	mv /tmp/$@ ./$@
	echo "file://${PP}/$@" >>open.1

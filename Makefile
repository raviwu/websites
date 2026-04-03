.PHONY: sync serve-tempo serve-lw serve-pur build-tempo build-lw build-pur build-all

sync:
	./scripts/sync-content.sh

serve-tempo:
	cd sites/tempo && hugo server -p 1313

serve-lw:
	cd sites/lw-studio && hugo server -p 1314

serve-pur:
	cd sites/purmuurfuuur && hugo server -p 1315

build-tempo:
	cd sites/tempo && hugo --minify

build-lw:
	cd sites/lw-studio && hugo --minify

build-pur:
	cd sites/purmuurfuuur && hugo --minify

build-all: build-tempo build-lw build-pur

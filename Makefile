.PHONY: sync serve-tempo serve-lw serve-pur serve-dz build-tempo build-lw build-pur build-dz build-all

sync:
	./scripts/sync-content.sh

serve-tempo:
	cd sites/tempo && hugo server -D -p 1313

serve-lw:
	cd sites/lw-studio && hugo server -D -p 1314

serve-pur:
	cd sites/purmuurfuuur && hugo server -D -p 1315

serve-dz:
	cd sites/draft-zero && hugo server -D -p 1316

build-tempo:
	cd sites/tempo && hugo --minify

build-lw:
	cd sites/lw-studio && hugo --minify

build-pur:
	cd sites/purmuurfuuur && hugo --minify

build-dz:
	cd sites/draft-zero && hugo --minify

build-all: build-tempo build-lw build-pur build-dz

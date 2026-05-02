.PHONY: sync publish serve-tempo serve-lw serve-pur serve-dz serve-pikmin build-tempo build-lw build-pur build-dz build-pikmin build-all

sync:
	./scripts/sync-content.sh

publish:
	./scripts/sync-content.sh
	git add sites/
	git diff --cached --stat
	git commit -m "sync: publish content from Obsidian vault" || echo "Nothing to commit"
	git push

serve-tempo:
	cd sites/tempo && hugo server -D -p 1313

serve-lw:
	cd sites/lw-studio && hugo server -D -p 1314

serve-pur:
	cd sites/purmuurfuuur && hugo server -D -p 1315

serve-dz:
	cd sites/draft-zero && hugo server -D -p 1316

serve-pikmin:
	cd sites/pikmin && hugo server -D -p 1317

build-tempo:
	cd sites/tempo && hugo --minify

build-lw:
	cd sites/lw-studio && hugo --minify

build-pur:
	cd sites/purmuurfuuur && hugo --minify

build-dz:
	cd sites/draft-zero && hugo --minify

build-pikmin:
	cd sites/pikmin && hugo --minify

build-all: build-tempo build-lw build-pur build-dz build-pikmin

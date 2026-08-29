dev:
  nix develop --command qs -p ./shell.qml

lint:
  nix develop --command bash -c 'VFS=$(ls -dt /run/user/$UID/quickshell/vfs/*/ | head -1); for qmldir in $(find . -name qmldir -not -path "./.*"); do dir=$(dirname "$qmldir"); name=$(echo "$dir" | sed "s|^\./||; s|/|.|g"); target="$VFS/qs/$dir"; if [ -d "$target" ] && [ ! -f "$target/qmldir" ]; then { echo "module qs.$name"; cat "$qmldir"; } > "$target/qmldir"; fi; done; FLAGS=$(echo "$QML_IMPORT_PATH $VFS" | tr ":" " " | tr " " "\n" | sed "s/^/-I /"); find . -type f -name "*.qml" -exec qmllint $FLAGS {} +'

format:
  nix develop --command find . -type f -name "*.qml" -exec qmlformat --inplace {} +

typecheck:
  nix develop --command bash -c 'shopt -s globstar nullglob; files=(**/*.js **/*.mjs **/*.cjs); if (( ${#files[@]} )); then tsc --project tsconfig.json; else printf "%s\n" "No JavaScript files to typecheck."; fi'

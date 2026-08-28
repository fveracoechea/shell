dev:
  nix develop --command qs -p ./shell.qml

lint:
  nix develop --command bash -c 'FLAGS=$(echo "$QML_IMPORT_PATH" | tr ":" "\n" | sed "s/^/-I /"); find . -type f -name "*.qml" -exec qmllint $FLAGS {} +'

format:
  nix develop --command find . -type f -name "*.qml" -exec qmlformat --inplace {} +

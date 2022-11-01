#! /bin/bash

MODE=""

modeSet() {
  if [ ! -z "$MODE" ]
  then
    echo "==> ! ERROR ! You cannot set the mode to more than one option"
    echo
    exit 1
  fi
}

echo
echo '======================='
echo ' Release Script        '
echo '======================='
echo
echo '=> Parsing Input'

while getopts ':pmM' OPTION
do
  case "${OPTION}" in
    p)
      modeSet
      MODE="patch"
      ;;
    m)
      modeSet
      MODE="minor"
      ;;
    M)
      modeSet 
      MODE="major"
      ;;
  esac
done

if [ -z "$MODE" ]
then
  echo '==> ! ERROR ! No Mode Selected'
fi

echo '=> Running Release'
echo "==| Mode: $MODE"

echo "=> Building..."
tsc
git add -A
git commit -m 'release: Build Module'

echo "=> Creating Changelog"
case "$MODE" in
  'patch') 
    changelog -p -x dist
    ;;
  'minor') 
    changelog -m -x dist
    ;;
  'major')
    changelog -M -x dist
    ;;
esac

# Add Changelog and commit
git add -A
git commit -m 'Update Changelog'

case "$MODE" in
  'patch') 
    npm version patch
    ;;
  'minor') 
    npm version minor
    ;;
  'major')
    npm version major
    ;;
esac

git push origin
git push origin --tags

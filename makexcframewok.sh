#!/bin/bash
## usage:
## sh makexcframewok.sh iOS-Strict/AppsFlyerLib.framework iOS-Strict/AppsFlyerLib.xcframework
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;35m'
COLORS=("$BLUE" "$ORANGE" "$CYAN")
NC='\033[0m'
function printInfo () {
   printf "${GREEN}INFO\t${NC} $1\n"
}

function printInfoColorIndex () {
   printf "${COLORS[$2]}INFO\t${NC} $1\n"
}

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
ARCHS_TOEXTRACT=("armv7,arm64" "i386,x86_64")
FRAMEWORK="$PWD/$1"
FRAMEWORK_FILENAME=$(basename $FRAMEWORK)
SUB_DIRS=("ios-armv7_arm64" "ios-i386_x86_64-simulator" "ios-x86_64-maccatalyst")
printInfo "Framework to slice up $FRAMEWORK"

THINED_FRAMEWORKS=()

for i in ${!ARCHS_TOEXTRACT[@]}
do
ARCHS=${ARCHS_TOEXTRACT[$i]}
SUB_DIR="${FRAMEWORK%/*}/${SUB_DIRS[$i]}"
FRAMEWORK_COPY="$SUB_DIR/$FRAMEWORK_FILENAME"

printInfoColorIndex "Create temp thinned framework $i"
[ -d "$SUB_DIR" ] && rm -rf "$SUB_DIR"
mkdir "$SUB_DIR"

cp -R $FRAMEWORK "$SUB_DIR/"

FRAMEWORK_EXECUTABLE_NAME="Versions/A/AppsFlyerLib"
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK_COPY/$FRAMEWORK_EXECUTABLE_NAME"

printInfoColorIndex "Executable is $FRAMEWORK_EXECUTABLE_PATH" $i
IFS=',' read -ra AR <<< "$ARCHS"
EXTRACTED_ARCHS=()
for ARCH in "${AR[@]}"
do
   printInfoColorIndex "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME to $FRAMEWORK_EXECUTABLE_PATH-$ARCH" $i
   lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
   EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

printInfoColorIndex "Merging extracted architectures: ${ARCHS}" $i
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

printInfoColorIndex "Replacing creating thinned version" $i

THINNED_FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK_COPY/$FRAMEWORK_EXECUTABLE_NAME"
rm "$THINNED_FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$THINNED_FRAMEWORK_EXECUTABLE_PATH"
THINED_FRAMEWORKS+=("$FRAMEWORK_COPY")
done

[ -d "$PWD/$2" ] && rm -rf "$PWD/$2"


printInfo "Creating xcframework from: ${THINED_FRAMEWORKS}"
xcodebuild -create-xcframework -framework "${THINED_FRAMEWORKS[0]}" -framework "${THINED_FRAMEWORKS[1]}" -output "$PWD/$2"

printInfo "Clean up"

for DIR in ${SUB_DIRS[@]} 
do
   rm -rf "${FRAMEWORK%/*}/${DIR}"
done

#!/bin/bash

IDF_COMMIT=$(git -C "$IDF_PATH" rev-parse --short HEAD || echo "")
IDF_BRANCH=$(git -C "$IDF_PATH" symbolic-ref --short HEAD || git -C "$IDF_PATH" tag --points-at HEAD || echo "")
idf_version_string=${IDF_BRANCH//\//_}"-$IDF_COMMIT"

archive_path="dist/arduino-esp32-libs-$1-$idf_version_string.tar.gz"
pio_zip_archive_path="dist/framework-arduinoespressif32.zip"
pio_zip_archive_libs_path="dist/framework-arduinoespressif32-libs.zip"

mkdir -p dist && rm -rf "$archive_path"
if [ -d "out" ]; then
	cd out && tar zcf "../$archive_path" * && cd ..
fi

cd out
echo "Creating PlatformIO Tasmota framework-arduinoespressif32"
mkdir -p arduino-esp32/cores/esp32
mkdir -p arduino-esp32/tools/partitions
cp -rf ../components/arduino/tools arduino-esp32
cp -rf ../components/arduino/cores arduino-esp32
cp -rf ../components/arduino/libraries arduino-esp32
cp -rf ../components/arduino/variants arduino-esp32
cp -f ../components/arduino/CMa* arduino-esp32
cp -f ../components/arduino/idf* arduino-esp32
cp -f ../components/arduino/Kco* arduino-esp32
cp -f ../components/arduino/pac* arduino-esp32
rm -rf arduino-esp32/docs
rm -rf arduino-esp32/tests
rm -rf arduino-esp32/libraries/RainMaker
rm -rf arduino-esp32/libraries/Insights
rm -rf arduino-esp32/libraries/SPIFFS
rm -rf arduino-esp32/libraries/ESP_SR
rm -rf arduino-esp32/tools/esp32-arduino-libs
rm -rf arduino-esp32/tools/gen_insights_package.py
cp -rf tools/esp32-arduino-libs arduino-esp32/tools/
cp ../package.json arduino-esp32/package.json
cp ../core_version.h arduino-esp32/cores/esp32/core_version.h
cp -rf arduino-esp32/tools/esp32-arduino-libs framework-arduinoespressif32-libs/
cp -rf arduino-esp32/ framework-arduinoespressif32/

# If the framework is needed as tar.gz uncomment next line
# tar --exclude=.* -zcf ../$pio_archive_path framework-arduinoespressif32/
7z a -mx=9 -tzip -xr'!.*' ../$pio_zip_archive_path framework-arduinoespressif32/
7z a -mx=9 -tzip -xr'!.*' ../$pio_zip_archive_libs_path framework-arduinoespressif32-libs/
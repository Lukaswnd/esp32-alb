#/bin/bash

source ./tools/config.sh

#
# CLONE/UPDATE ARDUINO
#
echo "Updating ESP32 Arduino..."
if [ ! -d "$AR_COMPS/arduino" ]; then
	git clone $AR_REPO_URL "$AR_COMPS/arduino"
fi

if [ -z $AR_BRANCH ]; then
	if [ -z $GITHUB_HEAD_REF ]; then
		current_branch=`git branch --show-current`
	else
		current_branch="$GITHUB_HEAD_REF"
	fi
	echo "Current Branch: $current_branch"
	if [[ "$current_branch" != "master" && `git_branch_exists "$AR_COMPS/arduino" "$current_branch"` == "1" ]]; then
		export AR_BRANCH="$current_branch"
	else
		if [ "$IDF_TAG" ]; then #tag was specified at build time
			AR_BRANCH_NAME="idf-$IDF_TAG"
		elif [ "$IDF_COMMIT" ]; then #commit was specified at build time
			AR_BRANCH_NAME="idf-$IDF_COMMIT"
		else
			AR_BRANCH_NAME="idf-$IDF_BRANCH"
		fi
		has_ar_branch=`git_branch_exists "$AR_COMPS/arduino" "$AR_BRANCH_NAME"`
		if [ "$has_ar_branch" == "1" ]; then
			export AR_BRANCH="$AR_BRANCH_NAME"
		else
			has_ar_branch=`git_branch_exists "$AR_COMPS/arduino" "$AR_PR_TARGET_BRANCH"`
			if [ "$has_ar_branch" == "1" ]; then
				export AR_BRANCH="$AR_PR_TARGET_BRANCH"
			fi
		fi
	fi
fi

if [ "$AR_BRANCH" ]; then
	echo "AR_BRANCH='$AR_BRANCH'"
	git -C "$AR_COMPS/arduino" checkout "$AR_BRANCH" && \
	git -C "$AR_COMPS/arduino" fetch && \
	git -C "$AR_COMPS/arduino" pull --ff-only
fi
if [ $? -ne 0 ]; then exit 1; fi

#
# CLONE/UPDATE ESP32-ARDUINO-LIBS
#
if [ ! -d "$IDF_LIBS_DIR" ]; then
	echo "Cloning esp32-arduino-libs..."
	git clone "$AR_LIBS_REPO_URL" "$IDF_LIBS_DIR"
else
	echo "Updating esp32-arduino-libs..."
	git -C "$IDF_LIBS_DIR" fetch && \
	git -C "$IDF_LIBS_DIR" pull --ff-only
fi
if [ $? -ne 0 ]; then exit 1; fi


# Remove unwanted directories
rm -rf "$AR_COMPS/arduino/docs" \
       "$AR_COMPS/arduino/idf_component_examples" \
       "$AR_COMPS/arduino/tests" \
       "$AR_COMPS/arduino/libraries/RainMaker" \
       "$AR_COMPS/arduino/libraries/Insights" \
       "$AR_COMPS/arduino/libraries/SPIFFS" \
       "$AR_COMPS/arduino/libraries/ESP_SR" \
       "$AR_COMPS/arduino/libraries/TFLiteMicro"

if [ $? -ne 0 ]; then
    echo "Error removing directories"
    exit 1
fi

# Replace CMakeLists.txt and idf_component.yml
rm -rf "$AR_COMPS/arduino/CMakeLists.txt" "$AR_COMPS/arduino/idf_component.yml"

cp "$AR_ROOT/configs/CMakeLists.txt" "$AR_COMPS/arduino/CMakeLists.txt"
if [ $? -ne 0 ]; then
    echo "Error copying CMakeLists.txt"
    exit 1
fi

cp "$AR_ROOT/configs/idf_component.yml" "$AR_COMPS/arduino/idf_component.yml"
if [ $? -ne 0 ]; then
    echo "Error copying idf_component.yml"
    exit 1
fi

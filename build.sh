#!/usr/bin/env bash
set -eu

# Obviously a rough-draft for prototyping a more robust shell script for use in builds.
# Assumes it'll be run from this folder.

VERSION=`cat VERSION.md`

# Get just the 'patch' part
MAJOR=${VERSION%%.*}
PATCH_RAW=${VERSION##*.}

# Ensures there are three digits in PATCH, even if the first one or two must be zeros.
# If we're worried about overrun... uh... "just add more zeroes"?
printf -v PATCH "%03d" $PATCH_RAW

# Aims to ensure a monotonically-increasing build number.
BUILD_NUM="$MAJOR$PATCH"

# to build (for Android, on a Win machine... at least)
flutter build apk --build-name $VERSION --build-number $BUILD_NUM

# to test the command-line built version (for Android), verifying version info is properly set
# flutter run --use-application-binary build/app/outputs/apk/release/app-release.apk
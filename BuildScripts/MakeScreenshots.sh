#!/bin/bash

#  MakeScreenshots.sh
#  OpenBrew
#
#  Created by David Shirley 2 on 1/10/16.
#  Copyright © 2016 OpenBrew. All rights reserved.
#
#  This script is run from the MakeScreenshots build target

set -e

cd ${PROJECT_DIR}/ScreenshotAutomation

if ! which -s snapshot; then
  echo "ERROR: The program 'snapshot' is not in your PATH."
  echo "Please install it with 'sudo gem install snapshot'"
  echo "For more information visit https://github.com/fastlane/snapshot"
  exit 1
fi

if ! which -s frameit; then
  echo "ERROR: The program 'snapshot' is not in your PATH."
  echo "Please install it with 'sudo gem install frameit'"
  echo "For more information visit https://github.com/fastlane/frameit"
  exit 1
fi

rm -rf ${PROJECT_DIR}/Images/Screenshots

# This must be in sync with the output directory in the Snapfile
SNAPSHOT_OUTPUT_DIRECTORY="${PROJECT_DIR}/Images/Screenshots/Full/en-US"

snapshot

# Copy some of the output files into a folder that can be uploaded to iTunes
cd ${SNAPSHOT_OUTPUT_DIRECTORY}/../../
mkdir iTunes
cd iTunes

cp ${SNAPSHOT_OUTPUT_DIRECTORY}/*TableOfContents.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/*RecipeOverview.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/*AbvCalculation.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/*HopAdditionsExpanded.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/*HopAdditionsSettings.png .

# Copy some of the photos that are shown on the website
cd ${SNAPSHOT_OUTPUT_DIRECTORY}/../../
mkdir Website
cd Website

cp ${SNAPSHOT_OUTPUT_DIRECTORY}/iPhone5s-TableOfContents.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/iPhone5s-AbvCalculation.png .
cp ${SNAPSHOT_OUTPUT_DIRECTORY}/iPhone5s-HopAdditionsExpanded.png .

# Put the frame around the output files
frameit space-gray

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
OUTPUT_DIR="${PROJECT_DIR}/Images/Screenshots/Full/en-US"

snapshot

# Copy some of the output files into a folder that can be uploaded to iTunes
cd ${OUTPUT_DIR}/../../
mkdir -p iTunes/en-US
cd iTunes/en-US

cp ${OUTPUT_DIR}/*TableOfContents.png .
cp ${OUTPUT_DIR}/*RecipeOverview.png .
cp ${OUTPUT_DIR}/*AbvCalculation.png .
cp ${OUTPUT_DIR}/*HopAdditionsExpanded.png .
cp ${OUTPUT_DIR}/*HopAdditionsSettings.png .

# Copy some of the photos that are shown on the website
cd ${OUTPUT_DIR}/../../
mkdir -p Website/en-US
cd Website/en-US

cp ${OUTPUT_DIR}/iPhone5s-TableOfContents.png .
cp ${OUTPUT_DIR}/iPhone5s-AbvCalculation.png .
cp ${OUTPUT_DIR}/iPhone5s-HopAdditionsExpanded.png .

# Put the frame around the output files
frameit space-gray

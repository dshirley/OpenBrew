#!/bin/bash

#  MakeScreenshots.sh
#  OpenBrew
#
#  Created by David Shirley 2 on 1/10/16.
#  Copyright © 2016 OpenBrew. All rights reserved.
#
#  This script is run from the MakeScreenshots build target

cd ${PROJECT_DIR}/ScreenshotAutomation

if ! `which snapshot`; then
  echo "ERROR: The program 'snapshot' is not in your PATH."
  echo "Please install it with 'sudo gem install snapshot'"
  echo "For mor information visit https://github.com/fastlane/snapshot"
  exit 1
fi

snapshot

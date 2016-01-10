[![Build Status](https://travis-ci.org/dshirley/OpenBrew.svg?branch=master)](https://travis-ci.org/dshirley/OpenBrew)

# OpenBrew

OpenBrew is a home brewing app for iOS.  OpenBrew is to provides a clean,
minimal interface for designing beer recipes on the go.

# Optional Development Tools

Third-party library dependencies are managed with [Cocoapods](https://cocoapods.org/). The third-party libraries are
checked into this repo, so you will *not* need to run `pod install` to get started. Cocoapods is only needed in order
to update which third-party libraries are used.

    sudo gem install cocoapods

To run the screenshot automation scripts, install two of the [Fastlane](https://github.com/fastlane/fastlane) tools.

    # Install the tools
    brew install imagemagick
    sudo gem install snapshot frameit

    # Setup frameit. Follow the instructions.
    frameit setup


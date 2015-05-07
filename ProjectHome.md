# Key Logger for OSX #

Key logger with emphasis on 'develop your own program using this as a base'. Written in C (configuration reader includes objective-c for simplicity). Uses Carbon and Cocoa frameworks.


## Features ##

Simple logger that records key down and key up events with time and keycode. All keys are recorded (incl. modifier keys). The log is saved as xml to /tmp/osxKeyLogger.log.

If you want to develop your own logger, see functions **recordKeysCallback** and **createEventListenerLoopSourceAndRun** in **main.m**.



## Installation ##

  1. Download [osxkeylogger.app](http://osxkeylogger.googlecode.com/files/osxkeylogger-20110227.zip)
  1. Unzip in terminal: unzip osxkeylogger-20110227.zip
  1. Edit logFile entry in info.plist (in terminal: open osxkeylogger.app/Contents/Info.plist). Default logFile is /tmp/osxKeyLogger.log.
  1. launch osxKeyLogger.

## Options ##

  1. Keys can be printed to stdout:
    1. Change logFile entry to "stdout" (without the aphostropes) in info.plist.
    1. run in terminal: ./osxkeylogger.app/Contents/MacOS/osxkeylogger

## Known 'Features' ##

  * No known bugs


## Aknowledgements ##

  * [logo](http://cocoawithlove.com/2011/01/advanced-drawing-using-appkit.html)
  * [Introduction to Quartz Event Taps](http://stackoverflow.com/questions/4512106/how-to-create-virtual-keyboard-in-osx)
  * [APIs and References](http://www.google.fi)

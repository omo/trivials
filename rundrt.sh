#!/bin/sh

export DYLD_FRAMEWORK_PATH=./WebKitBuild/Debug
export WEBKIT_UNSET_DYLD_FRAMEWORK_PATH=1
./WebKitBuild/Debug/DumpRenderTree $*

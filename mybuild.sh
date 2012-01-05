#!/bin/sh
reclap.rb ./Tools/Scripts/build-webkit --debug $@ | ./Tools/Scripts/filter-build-webkit --no-color
#reclap.rb ./Tools/Scripts/build-webkit --debug $@
#MESSAGE=`echo 'build fiinished!: '``herebr`
#growlnotify -t WebKit -m "$MESSAGE"

#!/bin/bash

set -e

carton install --deployment 2>&1 | tee .carton.log
if [ $? == 0 ] ; then
  rm -rf ./local/cache "$HOME/.cpanm" .carton.log
  mkdir -p /deps
  mv local /deps
  exit 0
fi

carton install --deployment
if [ $? != 0 ] ; then
  echo "***** BEGIN build.log"
  cat $HOME/.cpanm/build.log
  echo "******"

  echo "***** BEGIN carton install log (without the 'Successfully installed' lines)"
  egrep -v "^Successfully installed " .carton.log | grep -v "/bin/tar: Ignoring unknown extended header keyword"
  echo "******"

  echo "****** carton install failed, search log backwards until 'BEGIN build.log' and debug it"
  echo "******"
  exit 1
fi

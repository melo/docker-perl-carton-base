#!/bin/sh

carton install --deployment
if [ $? == 0 ] ; then
  rm -rf ./local/cache "$HOME/.cpanm"
  mkdir -p /app/deps
  mv local /app/deps
  exit 0
fi

carton install --deployment
if [ $? != 0 ] ; then
  echo "***** BEGIN build.log"
  cat $HOME/.cpanm/build.log
  echo "******"
  echo "****** carton install failed, search log backwards until 'BEGIN build.log' and debug it"
  echo "******"
  exit 1
fi

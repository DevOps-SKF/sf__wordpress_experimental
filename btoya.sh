#!/bin/bash
YADIR=SF_Backup
SRCDIR="."
BaseFN=sf__exp
DIR=/tmp
FN=BaseFN-$(date +'%Y%m%d-%H%M').tgz


# .File and .DIR are skipped by tar by defult, that's good in this 
printf "\nCreate $DIR/$FN\n"
tar -czvf $DIR/$FN $SRCDIR/*
if [ $? != 0 ]; then
  printf "TAR error, exiting"
fi

# Check if YADIR exists
curl --user $YA_user:$YA_webdavkey -X PROPFIND -H "Depth: 1" https://webdav.yandex.ru/ -s > /tmp/tmp
grep -Rq "/$YADIR/" /tmp/tmp
if [ $? != 0 ]; then
  printf "\nCreate dir"
  curl -X MKCOL --user $YA_user:$YA_webdavkey https://webdav.yandex.ru/$YADIR
fi
rm /tmp/tmp

printf "\nUploading"
curl -T $DIR/$FN --user $YA_user:$YA_webdavkey https://webdav.yandex.ru/$YADIR/$FN > /dev/null
# --progress-bar --verbose -o /dev/stdout
if [ $? == 0 ]; then
  printf "\nBackup uploaded, deleting local copy"
  rm $DIR/$FN
else
  printf "\nBackup NOT uploaded"
fi
printf "\n\n"
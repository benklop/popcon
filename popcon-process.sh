#!/bin/sh

BASEDIR=/org/popcon.debian.org/popcon-mail
MAILDIR=../Mail
WEBDIR=../www
LOGDIR=$BASEDIR/../logs
BINDIR=$BASEDIR/../bin
SUMMARYDIR=$BASEDIR/all-popcon-results

# Remove entries older than # number of days
DAYLIMIT=20

set -e
cd $BASEDIR
umask 0002
# rotate files
mv $MAILDIR/survey new-popcon-entries
touch $MAILDIR/survey
chmod go-rwx $MAILDIR/survey

# process entries
$BINDIR/prepop.pl <new-popcon-entries >$LOGDIR/prepop.out 2>&1

# delete outdated entries
rm -f results
find popcon-entries -type f -mtime +$DAYLIMIT -print0 | xargs -0 rm -f --
find popcon-entries -type f | xargs cat \
        | nice -15 $BINDIR/popanal.py >$LOGDIR/popanal.out 2>&1
cp results $WEBDIR/all-popcon-results.txt
gzip -f $WEBDIR/all-popcon-results.txt
cp $WEBDIR/all-popcon-results.txt.gz $SUMMARYDIR/popcon-`date +"%Y-%m-%d"`.gz

cd ../popcon-stat
find $SUMMARYDIR -type f -print | sort | $BINDIR/popcon-stat.pl

cd ../popcon-web
$BINDIR/popcon.pl >$LOGDIR/popcon.log

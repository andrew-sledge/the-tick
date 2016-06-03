#!/bin/bash

## Commands
WGET=`which wget`
RPM2CPIO=`which rpm2cpio`
MKDIR=`which mkdir`
TAR=`which tar`
CPIO=`which cpio`
SED=`which sed`
R=`pwd`

## Directories
TICK=/srv/tick
VENDOR=$TICK/vendor

T=0
I=0
C=0
K=0
ARGS="$@"

if [[ $ARGS == *"telegraf"* ]]
then
	T=1
fi
if [[ $ARGS == *"influxdb"* ]]
then
	I=1
fi
if [[ $ARGS == *"chronograf"* ]]
then
	C=1
fi
if [[ $ARGS == *"kapacitor"* ]]
then
	K=1
fi
if [[ $ARGS == *"all"* ]]
then
	T=1
	I=1
	C=1
	K=1
fi
$MKDIR -p $VENDOR

## Install telegraf
if [[ $T -eq 1 ]]
then
	$WGET https://dl.influxdata.com/telegraf/releases/telegraf-0.13.1_linux_amd64.tar.gz -O $VENDOR/telegraf-0.13.1_linux_amd64.tar.gz
	$MKDIR -p $VENDOR/telegraf
	$TAR -xvzf $VENDOR/telegraf-0.13.1_linux_amd64.tar.gz -C $VENDOR/telegraf
	cp -R $VENDOR/telegraf/telegraf-0.13.1-1/* $TICK/
	$SED -i "s@/etc/telegraf@$TICK/etc/telegraf@" $TICK/etc/telegraf/telegraf.conf
fi

## Install influxdb
if [[ $I -eq 1 ]]
then
	$WGET https://dl.influxdata.com/influxdb/releases/influxdb-0.13.0_linux_amd64.tar.gz -O $VENDOR/influxdb-0.13.0_linux_amd64.tar.gz
	$MKDIR -p $VENDOR/influxdb
	$TAR -xvzf $VENDOR/influxdb-0.13.0_linux_amd64.tar.gz -C $VENDOR/influxdb
	cp -R $VENDOR/influxdb/influxdb-0.13.0-1/* $TICK/
	$SED -i "s@/var/lib/influxdb/meta@$TICK/var/lib/influxdb/meta@" $TICK/etc/influxdb/influxdb.conf
	$SED -i "s@/var/lib/influxdb/data@$TICK/var/lib/influxdb/data@" $TICK/etc/influxdb/influxdb.conf
	$SED -i "s@/var/lib/influxdb/wal@$TICK/var/lib/influxdb/wal@" $TICK/etc/influxdb/influxdb.conf
	$SED -i "s@/etc/ssl/influxdb.pem@$TICK/etc/ssl/influxdb.pem@" $TICK/etc/influxdb/influxdb.conf
fi

## Install chronograf
if [[ $C -eq 1 ]]
then
	$WGET https://dl.influxdata.com/chronograf/releases/chronograf-0.13.0-1.x86_64.rpm -O $VENDOR/chronograf-0.13.0-1.x86_64.rpm
	$MKDIR -p $VENDOR/chronograf
	(cd $VENDOR/chronograf && $RPM2CPIO $VENDOR/chronograf-0.13.0-1.x86_64.rpm | $CPIO -idmv)
	cp -R $VENDOR/chronograf/* $TICK/
	$SED -i "s@/opt/chronograf/chronograf.db/@$TICK/opt/chronograf/chronograf.db@" $TICK/opt/chronograf/config.toml
fi

## Install kapacitor
if [[ $K -eq 1 ]]
then
	$WGET https://dl.influxdata.com/kapacitor/releases/kapacitor-0.13.1_linux_amd64.tar.gz -O $VENDOR/kapacitor-0.13.1_linux_amd64.tar.gz
	$MKDIR -p $VENDOR/kapacitor
	$TAR -xvzf $VENDOR/kapacitor-0.13.1_linux_amd64.tar.gz -C $VENDOR/kapacitor
	cp -R $VENDOR/kapacitor/kapacitor-0.13.1-1/* $TICK/
	$SED -i "s@/var/lib/kapacitor@$TICK/var/lib/kapacitor@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/etc/ssl/kapacitor.pem@$TICK/etc/ssl/kapacitor.pem@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/var/log/kapacitor/kapacitor.log@$TICK/var/log/kapacitor/kapacitor.log@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/var/lib/kapacitor/replay@$TICK/var/lib/kapacitor/replay@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/var/lib/kapacitor/tasks@$TICK/var/lib/kapacitor/tasks@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/var/lib/kapacitor/kapacitor.db@$TICK/var/lib/kapacitor/kapacitor.db@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/etc/kapacitor/cert.pem@$TICK/etc/kapacitor/cert.pem@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/etc/kapacitor/key.pem@$TICK/etc/kapacitor/key.pem@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/etc/ssl/influxdb.pem@$TICK/etc/ssl/influxdb.pem@" $TICK/etc/kapacitor/kapacitor.conf
	$SED -i "s@/usr/share/collectd/types.db@$TICK/usr/share/collectd/types.db@" $TICK/etc/kapacitor/kapacitor.conf
fi

cd $R

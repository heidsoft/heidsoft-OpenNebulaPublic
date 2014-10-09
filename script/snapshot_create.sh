#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2002-2014, OpenNebula Project (OpenNebula.org), C12G Labs        #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

source $(dirname $0)/xenrc
source $(dirname $0)/../../scripts_common.sh

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Check and get DataStores Dir                              #
##--------------------------------------------------------------------------##
if [ -z "${ONE_LOCATION}" ]; then
    VAR_DIR_LOCATION=/var/lib/one
else
    VAR_DIR_LOCATION=$ONE_LOCATION/var
fi

PWD=$(pwd)
DOMAIN="$1"
SNAP_ID="$2"
DOMAIN_ID="$3"
SAVE_FILE="snap.$SNAP_ID.save"
DOMAIN_DIR=

cd $VAR_DIR_LOCATION/datastores

log_debug "SNAPSHOTCREATE : CMD = snapshot_create $*."
echo "SNAPSHOTCREATE : CMD = snapshot_create $*." >> ~/xen-vmm.log
##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Find Domain Dir                                           #
##--------------------------------------------------------------------------##
for dir in `find . -name disk.0`
do
  path=`dirname $dir`
  FIND_DOMAIN_DIR=$(echo "$path" | grep "[^0-9]$DOMAIN_ID$")
  if [ -n "$FIND_DOMAIN_DIR" -a -z "$DOMAIN_DIR" ];then
    DOMAIN_DIR=$path
    log_debug "SNAPSHOTCREATE : Find path DOMAIN_DIR=$DOMAIN_DIR."
  fi
done

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE :You must ensure Domain_Dir isn't NULL                              #
##--------------------------------------------------------------------------##
if [ -z $DOMAIN_DIR ];then
  log_error "SNAPSHOTCREATE action DOMAIN_DIR can not be NULL."
  cd $PWD
  exit 1
fi

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Create domain mem-snap file                               #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTCREATE : Create domain mem-snap file."
exec_and_log "$XM_SAVE $DOMAIN $DOMAIN_DIR/$SAVE_FILE" \
    "SNAPSHOTCREATE : Could not Get VM state file from vm=$DOMAIN_ID"

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Create domain disk-snap file                              #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTCREATE : Create domain disk-snap file."
cd $DOMAIN_DIR
filelist=$(ls disk.*)
for domain_file in $filelist
do
  cp -f $domain_file  snap.$SNAP_ID.$domain_file
done
cd -

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Create domain config-snap file                            #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTCREATE : Create domain config-snap file."
cd $DOMAIN_DIR
filelist1=$(ls deployment.*)
for dy_file in $filelist1
do
  cp -f $dy_file  snap.$SNAP_ID.$dy_file
done
cd -

##--------------------------------------------------------------------------##
# SNAPSHOTCREATE : Restore domain                                            #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTCREATE : Restore domain."
exec_and_log "$XM_RESTORE $DOMAIN_DIR/$SAVE_FILE" \
    "SNAPSHOTCREATE : Could restore VM state file for vm=$DOMAIN_ID"

cd $PWD
exit 0

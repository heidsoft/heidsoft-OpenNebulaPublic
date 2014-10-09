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
# SNAPSHOTREVERT : Check and get DataStores Dir                              #
##--------------------------------------------------------------------------##
if [ -z "${ONE_LOCATION}" ]; then
    VAR_DIR_LOCATION=/var/lib/one
else
    VAR_DIR_LOCATION=$ONE_LOCATION/var
fi

log_debug "SNAPSHOTREVERT : CMD = snapshot_revert $*."
echo "SNAPSHOTREVERT : CMD = snapshot_revert $*." >> ~/xen-vmm.log

PWD=$(pwd)
DOMAIN="$1"
SNAP_ID="$2"
DOMAIN_ID="$3"
SAVE_FILE="snap.$SNAP_ID.save"
DOMAIN_DIR=
TIMEOUT=

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT : Find Domain Dir                                           #
##--------------------------------------------------------------------------##
cd $VAR_DIR_LOCATION/datastores

for dir in `find . -name disk.0`
do
  path=`dirname $dir`
  FIND_DOMAIN_DIR=$(echo "$path" | grep "[^0-9]$DOMAIN_ID$")
  if [ -n "$FIND_DOMAIN_DIR" -a -z "$DOMAIN_DIR" ];then
    DOMAIN_DIR=$path
    log_debug "Find path DOMAIN_DIR=$DOMAIN_DIR."
  fi
done

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT :You must ensure Domain_Dir isn't NULL                      #
##--------------------------------------------------------------------------##
if [ -z $DOMAIN_DIR ];then
  log_error "SNAPSHOTREVERT action DOMAIN_DIR can not be NULL."
  cd $PWD
  exit 1
fi

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT : Shutdown VM                                               #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTREVERT : Shutdown VM."
deploy_id=$1

if [ -z "$SHUTDOWN_TIMEOUT" ]; then
    TIMEOUT=120
else
    TIMEOUT=$SHUTDOWN_TIMEOUT
fi

exec_and_log "$XM_SHUTDOWN $deploy_id" \
    "SNAPSHOTREVERT : Could not shutdown $deploy_id"

# exec_and_log "$XM_DELETE $deploy_id" \
#    "Could not delete $deploy_id"

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT :Delete domain disk                                         #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTREVERT : Delete domain disk."
rm $DOMAIN_DIR/disk.*

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT :Restore domain disk-snap                                   #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTREVERT : Restore domain disk-snap."
cd $DOMAIN_DIR
if [ -a snap.$SNAP_ID.disk.0 ];then
  cp -f snap.$SNAP_ID.disk.0  disk.0
else
  log_error "SNAPSHOTREVERT action Domain snapshot can not be FIND."
  cd $PWD
  exit 1
fi

if [ -a snap.$SNAP_ID.disk.1 ];then
  cp -f snap.$SNAP_ID.disk.1  disk.1
fi

if [ -a snap.$SNAP_ID.disk.2 ];then
  cp -f snap.$SNAP_ID.disk.2  disk.2
fi

if [ -a snap.$SNAP_ID.disk.3 ];then
  cp -f snap.$SNAP_ID.disk.3  disk.3
fi
cd -

##--------------------------------------------------------------------------##
# SNAPSHOTREVERT :Restore domain mem-snap                                    #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTREVERT : Restore domain mem-snap."
exec_and_log "$XM_RESTORE $DOMAIN_DIR/$SAVE_FILE" \
    "SNAPSHOTREVERT : Could restore VM state file for vm=$DOMAIN_ID"

cd $PWD
exit 0
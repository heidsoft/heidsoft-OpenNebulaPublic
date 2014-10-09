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
# SNAPSHOTDELETE : Check and get DataStores Dir                              #
##--------------------------------------------------------------------------##
if [ -z "${ONE_LOCATION}" ]; then
    VAR_DIR_LOCATION=/var/lib/one
else
    VAR_DIR_LOCATION=$ONE_LOCATION/var
fi

log_debug "SNAPSHOTDELETE : CMD = snapshot_delete $*."
echo "SNAPSHOTDELETE : CMD = snapshot_delete $*." >> ~/xen-vmm.log

PWD=$(pwd)
DOMAIN="$1"
SNAP_ID="$2"
DOMAIN_ID="$3"
DOMAIN_DIR=

cd $VAR_DIR_LOCATION/datastores

##--------------------------------------------------------------------------##
# SNAPSHOTDELETE : Find Domain Dir                                           #
##--------------------------------------------------------------------------##
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
# SNAPSHOTDELETE :You must ensure Domain_Dir isn't NULL                      #
##--------------------------------------------------------------------------##
if [ -z $DOMAIN_DIR ];then
  log_error "SNAPSHOTDELETE action DOMAIN_DIR can not be NULL."
  cd $PWD
  exit 1
fi

##--------------------------------------------------------------------------##
# SNAPSHOTDELETE : Delete domain mem-snap,disk-snap and config-snap file     #
##--------------------------------------------------------------------------##
log_debug "SNAPSHOTDELETE : Delete domain mem-snap,disk-snap and config-snap file."
rm -f $DOMAIN_DIR/snap.$SNAP_ID.*

cd $PWD
exit 0
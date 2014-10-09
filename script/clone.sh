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
# CLONE : Check and get DataStores Dir                                       #
##--------------------------------------------------------------------------##
if [ -z "${ONE_LOCATION}" ]; then
    VAR_DIR_LOCATION=/var/lib/one
else
    VAR_DIR_LOCATION=$ONE_LOCATION/var
fi

log_debug "CLONE : CMD = clone $*."
echo "CLONE : CMD = clone $*.." >> ~/xen-vmm.log

PWD=$(pwd)
TARGET_DOMAIN="$1"
SOURCE_DOMAIN_ID="$2"
TARGET_DOMAIN_FILE="$3"
TARGET_DOMAIN_ID="$4"
SOURCE_DOMAIN_DIR=
TARGET_DOMAIN_DIR=

##--------------------------------------------------------------------------##
# CLONE : Find Source and Target Domain Dir                                  #
##--------------------------------------------------------------------------##
cd $VAR_DIR_LOCATION/datastores
for dir in `find . -name disk.0`
do
  path=`dirname $dir`
  FIND_SOURCE_DOMAIN_DIR=$(echo "$path" | grep "[^0-9]$SOURCE_DOMAIN_ID$")
  FIND_TARGET_DOMAIN_DIR=$(echo "$path" | grep "[^0-9]$TARGET_DOMAIN_ID$")
  if [ -n "$FIND_SOURCE_DOMAIN_DIR" -a -z "$SOURCE_DOMAIN_DIR" ];then
    SOURCE_DOMAIN_DIR=$path
    log_debug "CLONE : Find path SOURCE_DOMAIN_DIR=$SOURCE_DOMAIN_DIR"
  fi

  if [ -n "$FIND_TARGET_DOMAIN_DIR" -a -z "$TARGET_DOMAIN_DIR" ];then
    TARGET_DOMAIN_DIR=$path
    log_debug "CLONE : Find path TARGET_DOMAIN_DIR=$TARGET_DOMAIN_DIR"
  fi
done

##--------------------------------------------------------------------------##
# CLONE : You must ensure Source Domain Dir isn't NULL                       #
##--------------------------------------------------------------------------##
if [ -z $SOURCE_DOMAIN_DIR ];then
  log_error "CLONE action SOURCE_DOMAIN_DIR can not be NULL."
  cd $PWD
  exit 1
fi

##--------------------------------------------------------------------------##
# CLONE : When Target Domain Dir is NULL, We create it!!!                    #
##--------------------------------------------------------------------------##
if [ -z $TARGET_DOMAIN_DIR ];then
  log_debug "CLONE : TARGET_DOMAIN_DIR can not be NULL,Create it!!!."
  cd $SOURCE_DOMAIN_DIR
  cd ..
  mkdir -p $TARGET_DOMAIN_ID
  cd $TARGET_DOMAIN_ID
  TARGET_DOMAIN_DIR=$(pwd)
  cd $VAR_DIR_LOCATION/datastores
  log_debug "CLONE : Create path TARGET_DOMAIN_DIR=$TARGET_DOMAIN_DIR."
fi

##--------------------------------------------------------------------------##
# CLONE : Domain Copy                                                        #
##--------------------------------------------------------------------------## 
cp -f $SOURCE_DOMAIN_DIR/disk.* $TARGET_DOMAIN_DIR/
cp -f $TARGET_DOMAIN_FILE $TARGET_DOMAIN_DIR/

log_debug "CLONE : Success."
cd $PWD

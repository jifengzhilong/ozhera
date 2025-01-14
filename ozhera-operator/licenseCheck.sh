#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

APPEND_ARG=""
FOLDER="./"
LINE_FLAG="=============================================="
TARGET_FILE="./license-list"

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`


if [ -n "$1" ]; then
    echo "checking module $1"
    APPEND_ARG="-f $1"
    FOLDER="$1"
else
    echo "checking whole project"
fi

echo "Running command: mvn clean package -DskipTests=true -PlicenseCheck $APPEND_ARG"

mvn clean package -DskipTests=true -PlicenseCheck $APPEND_ARG

status=$?
if [ $status -eq 0 ]; then
  echo "mvn command exec success"
else
  echo "${red}mvn command exec fail${reset}"
  exit 1
fi


#contact and generate license file
rm -rf $TARGET_FILE
LICENSE_FILES=`find $FOLDER -type f -name "THIRD-PARTY.txt"|grep generated-sources`

echo "Find license files:"
echo "$LICENSE_FILES"

for i in $LICENSE_FILES
    do
        echo "$LINE_FLAG" >> $TARGET_FILE
        echo $i >> $TARGET_FILE
        cat $i >> $TARGET_FILE
    done

echo "license files generated at $TARGET_FILE"

#fix missing license dependencies
missingLicense=(
    "(Unknown license) jsr173_api:(Apache License, Version 2.0) jsr173_api"
    "(Unknown license) \"Java Concurrency in Practice\" book annotations:(BEA licensed) \"Java Concurrency in Practice\" book annotations"
    "(Unknown license) Java Portlet Specification V2.0:(Apache License, Version 2.0) Java Portlet Specification V2.0"
)

for i in "${missingLicense[@]}"; do
    search=`echo $i |awk -F: '{print $1}'`
    replace=`echo $i |awk -F: '{print $2}'`
    sed -i.bak 's/'"$search"'/'"$replace"'/g' $TARGET_FILE
done

if [ -f $TARGET_FILE.bak ]; then
  rm -rf $TARGET_FILE.bak
fi

check_unknown_license=`cat $TARGET_FILE | grep "Unknown license"`

#checking unknown license
if grep -q "Unknown license" $TARGET_FILE
then
    echo "${red}Find unknown license${reset}"
    echo "$check_unknown_license"
    #exit 1
fi

allowLicense=(
    "CDDL"
    "Apache"
    "Common Development and Distribution License"
    "Eclipse Public License"
    "MIT"
    "The 3-Clause BSD License"
    "Public domain"
    "JSR.*107"
    "Common Public License Version 1.0"
    "org.scijava:native-lib-loader"
    "org.codehaus.woodstox:stax2-api"
    "net.jcip:jcip-annotations",
    "Mulan Permissive Software License"
    "BSD"
    "BSD 3-clause"
    "BSD 2-clause"
    "Eclipse Distribution License 2.0"
    "The JDOM License"
    "Dual-license"
    "CPL"
    "Mozilla v2"
    "EPL"
    "EPL-1.0 License"
    "JSON License"
    "Eclipse Distribution License - v 1.0"
    "EDL 1.0"
)

#filter allow license
license_need_check=`cat $TARGET_FILE | grep -v "generated-sources/license/THIRD-PARTY.txt" | grep -v "third-party dependencies" | grep -v "The project has no dependencies." | grep -v $LINE_FLAG`

for i in "${allowLicense[@]}"; do
    license_need_check=`echo "$license_need_check"|grep -vi "$i"`
done

# remove empty lines
echo $license_need_check | sed '/^[[:space:]]*$/d' > license-need-check

if [ ! -s license-need-check ]; then
    echo "${green}All dependencies license looks good${reset}"
else
    echo "${red}Please check below license${reset}"
    cat license-need-check
fi

rm -f license-list
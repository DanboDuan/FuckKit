#!/bin/bash
export LC_ALL="en_US.UTF-8"

function XcodeBuildCmd() {
    XcodeBuildBase="xcodebuild"
    if [[ ! 0"$XCODE_VERSION" == "0" ]]; then
        XcodeBuildBase="/Applications/Xcode-${XCODE_VERSION}.app/Contents/Developer/usr/bin/xcodebuild"
    fi
    echo $XcodeBuildBase
}

# XcodeBuildBase=$(XcodeBuildCmd)

function arm64_to_sim_o() {
    lib_o=$1
    arm64-to-sim "$lib_o"
}

function arm64_to_sim_lib() {
    lib_a=$1
    arm64_a="${lib_a}.arm64"
    arm64_sim_a="${lib_a}.arm64_sim"
    lib_a_back="${lib_a}.backup"
    if [ -n "$lib_a" ] && [ -f "$lib_a" ]; then
        fat=$(lipo -info "$lib_a"| grep Architectures | grep arm64)
        if [ -z "$fat" ];then
            return 0
        fi
        echo "arm64-to-sim ${lib_a}"
        rm -fr "$arm64_a"
        rm -fr "$arm64_sim_a"
        lipo -thin arm64 "$lib_a" -output "$arm64_a"
        ar x "$arm64_a"
        o_file_result=$(find . -type f -iname '*.o'| tr '\n' ';' | tr '\ ' ',')
        o_files=${o_file_result//;/$'\n'}
        for o_file_line in $o_files
        do
            o_file="${o_file_line//,/$''}"
            if [ -n "$o_file" ];then
                arm64_to_sim_o "$o_file"
            fi
        done
        ar crv "$arm64_sim_a" *.o
        rm *.o
        rm -fr "$arm64_a"
        mv "$lib_a" "$lib_a_back"
        mv "$arm64_sim_a" "$lib_a"
    fi
}


function arm64_to_sim_directory() {
    directory=$1
    mkdir -p tmp
    cd tmp
    result=$(find $directory -type f -iname '*.a'| tr '\n' ';' | tr '\ ' ',')
    libs=${result//;/$'\n'}
    for line in $libs
    do
      lib="${line//,/$''}"
      ## ttnet lib not 
      if [[ "$lib" == *libsscronet.a* ]];
      then
          continue
      fi
      if [ -n "$lib" ];then
          arm64_to_sim_lib "$lib"
      fi
    done
}

function revert_directory() {
    directory=$1
    echo $directory
    result=$(find $directory -type f -iname '*.a'| tr '\n' ';' | tr '\ ' ',')
    libs=${result//;/$'\n'}
    for line in $libs
    do
      lib="${line//,/$''}"
      ## ttnet lib not 
      if [[ "$lib" == *libsscronet.a* ]];
      then
          continue
      fi
      lib_backup="${lib}.backup"
      if [ -f "$lib" ] && [ -f "$lib_backup" ];then
        mv "$lib_backup" "$lib"
      fi
    done
}

workspace=$(pwd)
VERBOSE=0
REVERT=0
while getopts ":s:rv" opt; do
  case $opt in
    s)
      workspace=$OPTARG
      ;;
    r)
      REVERT=1
      ;;
    v)
      VERBOSE=1
      ;;
    :) 
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
    ?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

if [[ ! -d "$workspace" ]]; then
    echo "${workspace} is not a directory"
    exit 1
fi

if [[ $REVERT == 1 ]]; then
    revert_directory $workspace
    exit 0
fi

arm64_to_sim_directory $workspace





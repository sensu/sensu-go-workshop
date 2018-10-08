#!/bin/bash

WORK_DIR=/tmp/sensu-asset-builder
BUILD_DIR=$WORK_DIR/build
OUTPUT_DIR=$WORK_DIR/assets
mkdir -p $BUILD_DIR $OUTPUT_DIR

# Read arguments
while getopts ha:b:l:i:v:o: argument;
do
  case "${argument}"
    in
      h)
        echo "Option -h prints this help!" >&2
        exit 0;
        ;;
      a)
        ASSET_NAME=${OPTARG}
        ;;
      v)
        ASSET_VERSION="_${OPTARG}"
        ;;
      b)
        BIN=${OPTARG}
        ;;
      l)
        LIB=${OPTARG}
        ;;
      i)
        INCLUDED=${OPTARG}
        ;;
      o)
        OTHER=${OPTARG}
        ;;
  esac
done;

# Options
OPTIONS=($BIN, $LIB, $INCLUDE)

# Build the asset
if [[ -n $ASSET_NAME ]];
  then
    PKG_DIR="${BUILD_DIR}/${ASSET_NAME}${ASSET_VERSION}";
    if [[ -d $PKG_DIR ]]; then
      echo "Cleaning up pre-existing build directory: ${PKG_DIR}";
      rm -rf $PKG_DIR;
    fi
    echo "Creating asset build directory: ${PKG_DIR}.";
    mkdir -p $PKG_DIR/bin $PKG_DIR/lib $PKG_DIR/include;
  else
    echo "ERROR: no option -a provided. Please provide an asset package name.";
    exit 2;
fi
if [[ -n $BIN ]]; then
  IFS=',' read -r -a BINARIES <<< "${BIN}"
  for INDEX in "${!BINARIES[@]}"
  do
    BINARY="${BINARIES[$INDEX]}"
    if [[ -e $BINARY ]]; then
      cp $BINARY $PKG_DIR/bin/;
    else
      echo "ERROR: file not found: ${BINARY}"
      exit 2;
    fi
  done
fi
if [[ -n $LIB ]]; then
  IFS=',' read -r -a LIBRARIES <<< "${LIB}"
  for INDEX in "${!LIBRARIES[@]}"
  do
    LIBRARY="${LIBRARIES[$INDEX]}";
    if [[ -e $LIBRARY ]]; then
      cp $LIBRARY $PKG_DIR/lib/;
    else
      echo "ERROR: file not found: ${LIBRARY}"
      exit 2;
    fi
  done
fi
if [[ -n $INCLUDED ]]; then
  IFS=',' read -r -a INCLUDES <<< "${INCLUDED}"
  for INDEX in "${!INCLUDES[@]}"
  do
    INCLUDE="${INCLUDES[$INDEX]}"
    if [[ -e $INCLUDE ]]; then
      cp $INCLUDE $PKG_DIR/include/;
    else
      echo "ERROR: file not found: ${INCLUDE}"
      exit 2;
    fi
  done
fi
if [[ -n $OTHER ]]; then
  IFS=',' read -r -a OTHERS <<< "${OTHER}"
  for INDEX in "${!OTHERS[@]}"
  do
    DIR="${OTHERS[$INDEX]}"
    if [[ -d $DIR ]]; then
      cp -r $DIR $PKG_DIR/;
    else
      echo "ERROR: other directory not found: ${DIR}"
      exit 2;
    fi
  done
fi

ASSET="${OUTPUT_DIR}/${ASSET_NAME}${ASSET_VERSION}.tar.gz"
echo "";
echo "Packaging contents of ${PKG_DIR} into ${ASSET}";
echo "";
tar -zcf $ASSET -C $PKG_DIR .
if [[ -e $ASSET ]]; then
  shasum -a 512 $ASSET;
fi

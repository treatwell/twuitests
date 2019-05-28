#!/bin/bash
XCODE_USER_TEMPLATES_DIR="${HOME}/Library/Developer/Xcode/Templates/File_templates"
TEMPLATES_DIR="UITests"
PARAM=$1

if ([ -n "${PARAM}" ] && [ "clear" == "${PARAM}" ]); then
rm -fR ${XCODE_USER_TEMPLATES_DIR}/${TEMPLATES_DIR}
echo "Templated were removed"
else
    mkdir -p ${XCODE_USER_TEMPLATES_DIR}
    rm -fR ${XCODE_USER_TEMPLATES_DIR}/${TEMPLATES_DIR}
    cp -R ${TEMPLATES_DIR} ${XCODE_USER_TEMPLATES_DIR}
    echo "Templates added"
fi

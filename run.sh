#!/usr/bin/env bash
set -e
set -o pipefail

if [[ -e "${PWD}/gradew" ]]; then
    echo "${PWD}/gradlew exists."
    exit 0
fi

WORKING_DIR=$(mktemp -d)
echo "Creating a temporary directory ${WORKING_DIR}. It will be deleted automatically after this script is done"

GRADLE_PACKAGE="${WORKING_DIR}/gradle.zip"
trap 'rm -rf ${WORKING_DIR}' EXIT INT

function parse_json() {
    python -c "import json,sys;obj=json.load(sys.stdin);print obj['$1'];"
}

function gradle_bootstrap() {
    if which docker 2>&1 > /dev/null; then
        echo "Using Gradle Docker in ${PWD}"
        docker run --rm -u gradle -v "$PWD":/home/gradle/project -w /home/gradle/project gradle gradle ${@}
        return 0
    fi
    #Fetch the current gradle for bootstrapping
    gradle_version_info=$(curl -sSL "https://services.gradle.org/versions/current")
    gradle_version=$(echo "$gradle_version_info" | parse_json "version")
    gradle_download_url=$(echo "$gradle_version_info" | parse_json "downloadUrl")
    gradle_checksum=$(echo "$gradle_version_info" | parse_json "checksumUrl")
    gradle_wrapper_checksum=$(echo "$gradle_version_info" | parse_json "wrapperChecksumUrl")
    local gradle_exec="${WORKING_DIR}/gradle-${gradle_version}/bin/gradle"
    if ! [[ -f "${gradle_exec}" ]]; then
        echo "Downloading Gradle ($gradle_version) from $gradle_download_url to ${GRADLE_PACKAGE}"
        curl -L "$gradle_download_url" -o ${GRADLE_PACKAGE}
        unzip -q -d "${WORKING_DIR}" "${GRADLE_PACKAGE}"
    fi
    ${gradle_exec} "${@}"
}

if [[ $# == 0 ]]; then
    gradle_version_ref=""
else
    gradle_version_ref="--gradle-version $1"
    shift
fi

gradle_bootstrap --no-daemon --no-build-cache wrapper ${gradle_version_ref} --distribution-type all


#! /bin/bash

# Return if the user is valid or not. Returns 'true' if user exists, and
# 'false' if not.
#
# Uses the GitHub "Get a single user" API feature
# https://developer.github.com/v3/users/#get-a-single-user
#
# Usage:
#     is-valid-user TARGET_GITHUB_USERNAME
#
# Params:
#     TARGET_GITHUB_USERNAME - GitHub username you want to check for validity
#

# Sanity check: Make sure we have the appropriate number of arguments
if [ $# -ne 1 ]; then
    echo "Error: Requires exactly one argument: The target GitHub username."
    echo
    exit 1;
fi

# Module constants
API_BASE="https://api.github.com"
API_VER_ACCEPTS="application/vnd.github.v3+json"

# Collect cmd args
TARGET_GITHUB_USERNAME=$1

# Construct curl command
cmd="curl -s -i -X GET -H 'Accepts:$API_VER_ACCEPTS' $API_BASE/users/$TARGET_GITHUB_USERNAME"

# Capture stdout, exit on errors
cmd_out="$($cmd || exit 1)"

# Sniff the HTTP response status
http_status="$(echo $cmd_out | cut -d ' ' -f 2)"

# If we get a 200, the user exists, return true. Otherwise, the user doesn't
# exist, return false.
if [ $http_status -eq 200 ]; then
    echo 'true'
else
    echo 'false'
fi

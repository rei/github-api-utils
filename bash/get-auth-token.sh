#! /bin/bash

# Get an existing authorization token from an authorization name. If the
# authorization is not found, return nothing.
#
# Uses the GitHub "List your authorizations" API feature
# https://developer.github.com/v3/oauth_authorizations/#list-your-authorizations
#
# Usage:
#     get-auth-token GITHUB_USERNAME GITHUB_AUTH_NAME
#
# Params:
#     GITHUB_USERNAME - Your GitHub username
#     GITHUB_AUTH_NAME - The name of your authorization to get the token from. See https://github.com/settings/applications#personal-access-tokens
#

# Sanity check: Make sure we have the appropriate number of arguments
if [ $# -ne 2 ]; then
    echo "Error: Requires exactly two arguments: Your GitHub username, and the authorization name."
    echo
    exit 1;
fi

# Module constants
API_BASE="https://api.github.com"
API_VER_ACCEPTS="application/vnd.github.v3+json"

# Collect cmd args
GITHUB_USERNAME=$1
GITHUB_AUTH_NAME=$2

# Construct curl command
cmd="curl -s -i -X GET -u $GITHUB_USERNAME -d '' -H 'Accepts:$API_VER_ACCEPTS' $API_BASE/authorizations"

# Capture stdout, exit on errors
cmd_out="$($cmd || exit 1)"

# Sniff the HTTP response status
http_status="$(echo $cmd_out | cut -d ' ' -f 2)"

# If we did not get a 200, something went wrong. Exit with failure
if [ $http_status -ne 200 ]; then
    echo
    echo "Error listing your authorizations! Response header + body from GitHub:"
    echo
    echo "$cmd_out"
    echo
    exit 1
fi

# Parse and return the authorization token
echo "$cmd_out" | grep -B1 "\"note\": \"$GITHUB_AUTH_NAME\"" | grep '"token":' | cut -d '"' -f 4

#! /bin/bash

# Create a new authorization and return its token. Exit with errors if any are
# encountered, including if the authorization already exists.
#
# Uses the GitHub OAuth Authorizations "Create a new authorization" API feature
# https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization
#
# Usage:
#     create-new-auth GITHUB_USERNAME GITHUB_AUTH_NAME OAUTH_SCOPES
#
# Params:
#     GITHUB_USERNAME - Your GitHub username
#     GITHUB_AUTH_NAME - Name for your new authorization
#     OAUTH_SCOPES - OAuth access scopes. See http://developer.github.com/v3/oauth/#scopes

# Sanity check: Make sure we have the appropriate number of arguments
if [ $# -ne 3 ]; then
    echo "Error: Requires exactly three arguments: Your GitHub username, the authorization name, and its authorization scopes."
    echo
    exit 1;
fi

# Module constants
API_BASE="https://api.github.com"
API_VER_ACCEPTS="application/vnd.github.v3+json"

# Collect cmd args
GITHUB_USERNAME=$1
GITHUB_AUTH_NAME=$2
OAUTH_SCOPES=$(echo $3 | sed 's/^\(.*\)$/"\1"/g' | sed 's/,/","/g')

# Construct curl command
cmd="curl -s -i -X POST -u $GITHUB_USERNAME -d {\"scopes\":[$OAUTH_SCOPES],\"note\":\"$GITHUB_AUTH_NAME\"} -H 'Accepts:$API_VER_ACCEPTS' $API_BASE/authorizations"

# Capture stdout, exit on errors
cmd_out="$($cmd || exit 1)"

# Sniff the HTTP response status
http_status="$(echo $cmd_out | cut -d ' ' -f 2)"

# If we did not get a 201, something went wrong. Exit with failure
if [ $http_status -ne 201 ]; then
    echo
    echo "Error creating new authorization '$GITHUB_AUTH_NAME'! Response header + body from GitHub:"
    echo
    echo "$cmd_out"
    echo
    exit 1
fi

# Parse and return the authorization token
# auth_token=$(echo "$cmd_out" | grep -B1 "\"note\": \"$GITHUB_AUTH_NAME" | grep '"token":' | cut -d '"' -f 4)
echo "$cmd_out" | grep '"token":' | cut -d '"' -f 4

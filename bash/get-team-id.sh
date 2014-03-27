#! /bin/bash

# Get team ID from name
#
# Uses the GitHub "List teams" API feature
# http://developer.github.com/v3/orgs/teams/#list-teams
#
# Usage:
#     get-team-id ORG_NAME TEAM_NAME AUTH_TOKEN
#
# Params:
#     ORG_NAME - GitHub orgnaization name
#     TEAM_NAME - Name of the team
#     AUTH_TOKEN - Your GitHub OAuth token. Requires `read:org` scope. See http://developer.github.com/v3/oauth/#scopes

# Sanity check: Make sure we have the appropriate number of arguments
if [ $# -ne 3 ]; then
    echo "Error: Requires exactly three arguments: The organization name, the team name, and your OAuth token."
    echo
    exit 1;
fi

# Module constants
API_BASE="https://api.github.com"
API_VER_ACCEPTS="application/vnd.github.v3+json"

# Collect cmd args
ORG_NAME=$1
TEAM_NAME=$2
AUTH_TOKEN=$3

# Construct curl command
cmd="curl -s -i -X GET -u $AUTH_TOKEN:x-oauth-basic -d '' -H 'Accepts:$API_VER_ACCEPTS' $API_BASE/orgs/$ORG_NAME/teams"

# Capture stdout, exit on errors
cmd_out="$($cmd || exit 1)"

# Sniff the HTTP response status
http_status="$(echo $cmd_out | cut -d ' ' -f 2)"

# If we did not get a 200, something went wrong. Exit with failure
if [ $http_status -ne 200 ]; then
    echo
    echo "Error getting team ID! Response header + body from GitHub:"
    echo
    echo "$cmd_out"
    echo
    exit 1
fi

# Parse and return the team ID
echo "$cmd_out" | grep -A1 "\"name\": \"$TEAM_NAME\"" | grep '"id":' | sed 's/^ *"id": \(.*\),/\1/g'

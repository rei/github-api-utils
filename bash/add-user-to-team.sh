#! /bin/bash

# Add a GitHub user to the specified team given the team ID.
#
# Uses the GitHub "Add a team member" API feature
# http://developer.github.com/v3/orgs/teams/#add-team-member
#
# Usage:
#     add-user-to-team TARGET_GITHUB_USERNAME GITHUB_TEAM_ID AUTH_TOKEN
#
# Params:
#     TARGET_GITHUB_USERNAME - Username of the user you want to add to the team
#     GITHUB_TEAM_ID - ID of the team you want to add the user to
#     AUTH_TOKEN - Your GitHub OAuth token. Requires `admin:org` scope. See http://developer.github.com/v3/oauth/#scopes
#

# Sanity check: Make sure we have the appropriate number of arguments
if [ $# -ne 3 ]; then
    echo "Error: Requires exactly three arguments: Your GitHub username, the target GitHub username, and a GitHub team ID."
    echo
    exit 1;
fi

# Module constants
API_BASE="https://api.github.com"
API_VER_ACCEPTS="application/vnd.github.v3+json"

# Collect cmd args
TARGET_GITHUB_USERNAME=$1
GITHUB_TEAM_ID=$2
AUTH_TOKEN=$3

# Make sure user's username exists
echo "Checking username '$TARGET_GITHUB_USERNAME'..."
USER_EXISTS="$(./is-valid-user $TARGET_GITHUB_USERNAME || exit 1)"
if [ $USER_EXISTS = "false" ]; then
    echo "Error: User '$TARGET_GITHUB_USERNAME' does not exist."
    echo
    exit 1
fi
echo "User '$TARGET_GITHUB_USERNAME' is valid."
echo

# Construct curl command
cmd="curl -s -i -X PUT -u $AUTH_TOKEN:x-oauth-basic -d '' -H 'Accepts:$API_VER_ACCEPTS' $API_BASE/teams/$GITHUB_TEAM_ID/members/$TARGET_GITHUB_USERNAME"

# Capture stdout
cmd_out="$($cmd || exit 1)"

# Sniff the HTTP response status
http_status="$(echo $cmd_out | cut -d ' ' -f 2)"

# If we did not get a 204, something went wrong. Exit with failure
if [ $http_status -ne 204 ]; then
    echo "Error adding member to team! Are you sure it exists?"
    echo "Response header + body from GitHub:"
    echo
    echo "$cmd_out"
    echo
    exit 1
fi

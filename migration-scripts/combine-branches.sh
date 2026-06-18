#!/bin/bash

set -e

# The branch each package's individual branch starts from. This will normally be main.
BASE_BRANCH=main

# The branch we'll create.
COMBINED_BRANCH=combined-$(date -u +%Y%m%dT%H%M%S)

# The prefix used for each individual migration branch
BRANCH_PREFIX=scripted-migrate-

git checkout -q -b ${COMBINED_BRANCH} ${BASE_BRANCH}

for pkg in $*
do
  git cherry-pick ${BRANCH_PREFIX}${pkg} > /dev/null
done

echo "Created ${COMBINED_BRANCH}"
# Just to make sure the next iteration doesn't use the same branch name...
sleep 1

#!/bin/bash

set -e

if [[ $1 == "" ]]
then
  echo "Specify file containing list of packages"
  exit 1
fi
PACKAGES_FILE=$1

# The branch to checkout before each change. Normally main,
# but we sometimes want to use something else.
BASE_BRANCH=main

# The version of Librarian to use (via docker)
V=$(go run github.com/googleapis/librarian/cmd/librarian@latest config get version)

# Temporary override to use the latest docker image
# V=latest

# The prefix to use for each migration branch
BRANCH_PREFIX=scripted-migrate-

for pkg in $(cat ${PACKAGES_FILE})
do
  echo "Migrating ${pkg}"
  git checkout -q -b ${BRANCH_PREFIX}${pkg} ${BASE_BRANCH}
  yq --yaml-output "(.libraries[] | select(.name == \"${pkg}\") | .skip_generate) = false" \
    < librarian.yaml > after.yaml
  mv after.yaml librarian.yaml
  # Note: uses local version of librarian, for simplicity.
  librarian tidy
  docker run -u $(id -u):$(id -g) -v .:/repo -v ~/.cache:/.cache -w /repo \
     docker.io/library/librarian-nodejs:${V} generate -v ${pkg} > ../logs/migrate-${pkg}.txt
  git add --all > /dev/null
  git commit -a -m "chore: migrate ${pkg} to librarian" > /dev/null
done

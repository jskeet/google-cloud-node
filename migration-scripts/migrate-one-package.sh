#!/bin/bash

set -e

if [[ $1 == "" ]]
then
  echo "Specify the package to migrate"
  exit 1
fi
PKG=$1

# The branch to checkout before each change. Normally main,
# but we sometimes want to use something else.
BASE_BRANCH=main

# The version of Librarian to use (via docker)
V=$(go run github.com/googleapis/librarian/cmd/librarian@latest config get version)

# Temporary override to use the latest docker image
# V=latest

# The prefix to use for each migration branch
BRANCH_PREFIX=scripted-migrate-

echo "Migrating ${PKG}"
git checkout -q -b ${BRANCH_PREFIX}${PKG} ${BASE_BRANCH}
yq --yaml-output "(.libraries[] | select(.name == \"${PKG}\") | .skip_generate) = false" \
  < librarian.yaml > after.yaml
mv after.yaml librarian.yaml
# Note: uses local version of librarian, for simplicity.
librarian tidy
docker run -u $(id -u):$(id -g) -v .:/repo -v ~/.cache:/.cache -w /repo \
    docker.io/library/librarian-nodejs:${V} generate -v ${PKG} > ../logs/migrate-${PKG}.txt
git add --all > /dev/null
git commit -a -m "chore: migrate ${PKG} to librarian" > /dev/null

#!/bin/bash

set -e

if [[ $1 == "" ]]
then
  echo "Specify file containing list of packages"
  exit 1
fi
PACKAGES_FILE=$1

# The prefix of each migration branch
BRANCH_PREFIX=scripted-migrate-

for pkg in $(cat ${PACKAGES_FILE})
do
  # Just check that git show will work so we can die if not...
  git show ${BRANCH_PREFIX}${pkg} ${BASE_BRANCH} --raw > /dev/null
  if git show ${BRANCH_PREFIX}${pkg} ${BASE_BRANCH} --raw \
    | grep -E ^: | cut -d' ' -f 5,6 \
    | grep -vE "^D\\s+packages/${pkg}/\\.OwlBot\\.yaml" \
    | grep -vE "^D\\s+packages/${pkg}/\\.gitattributes" \
    | grep -vE "^D\\s+packages/${pkg}/CODE_OF_CONDUCT\\.md" \
    | grep -vE "^D\\s+packages/${pkg}/CONTRIBUTING\\.md" \
    | grep -vE "^D\\s+packages/${pkg}/LICENSE" \
    | grep -vE "^D\\s+packages/${pkg}/prettier\\.config\\.js" \
    | grep -vE "^D\\s+packages/${pkg}/\\.prettierrc\\.js" \
    | grep -vE "^D\\s+packages/${pkg}/\\.prettierignore" \
    | grep -vE "^D\\s+packages/${pkg}/\\.eslintignore" \
    | grep -vE "^D\\s+packages/${pkg}/\\.eslintrc\\.json" \
    | grep -vE 'M\s+librarian.yaml' \
    | grep -vE "M\\s+packages/${pkg}/\\.repo-metadata\\.json" > /dev/null
  then
    echo "${pkg} complex"
  else
    echo "${pkg} simple"
  fi
done

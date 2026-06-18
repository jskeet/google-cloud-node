#!/bin/bash

set -e

if [[ $1 == "" ]]
then
  echo "Specify package to generate"
  exit 1
fi

PKG=$1

# First run the copy
echo "Copying"
docker run --rm --user $(id -u):$(id -g) \
  -v .:/repo -w /repo -v ../googleapis-gen:/googleapis-gen \
  --env HOME=/tmp gcr.io/cloud-devrel-public-resources/owlbot-cli:latest copy-code \
   --source-repo=/googleapis-gen --config-file=handwritten/$PKG/.OwlBot.yaml

# Then post-process
echo "Post-processing"
docker run --rm --user $(id -u):$(id -g) -v $(pwd):/repo -w /repo --env HOME=/tmp \
  gcr.io/cloud-devrel-public-resources/owlbot-nodejs-mono-repo:latest \
  handwritten/$PKG

# Then commit with a suitably bland commit message, but one which is a feat
# (as this *should* prompt a release)
git add --all
git commit --allow-empty -a -m "feat: regenerated $PKG"

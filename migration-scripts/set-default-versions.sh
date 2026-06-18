#!/bin/bash

for pkg in $(ls packages)
do
  DEFAULT_VERSION=$(jq -r '.default_version' < packages/$pkg/.repo-metadata.json)
  yq --yaml-output "(.libraries[] | select(.name == \"$pkg\") | .nodejs.default_version) = \"$DEFAULT_VERSION\"" < librarian.yaml > after.yaml
  mv after.yaml librarian.yaml
done
librarian tidy

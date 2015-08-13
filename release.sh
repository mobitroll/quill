#!/bin/bash

# This script generates distribution files, tags them, and pushes them
# to a branch called 'release', which is never pulled into other branches.
# A release can then be made on GitHub from the release branch.

# USAGE:
# $ ./release.sh 0.20.2

# abort script if something errors
set -e

if [[ $1 =~ ^[0-9]+.[0-9]+.[0-9]+$ ]]; then
  echo 'Version number' $1 'valid. Continuing...'
else
  echo 'Usage: ./release.sh 0.20.2'
  exit 1
fi

# check whether we have uncommitted/untracked changes and abort if so
git diff-index --quiet HEAD || (echo 'Uncommitted/untracked changes present. Aborting release.' && exit 1)

git checkout release

# otherwise, reset to master to pull in latest src changes
git reset --hard origin/master

# pull release again so we have the history of releases
git pull origin release

# remove lines consisting of 'dist' from .gitignore
perl -pi.orig -e 's/\/dist\n//' .gitignore

# generate the dist files
grunt dist

# commit and push dist files to release branch
git add dist/*
git commit -m 'Release '$1
git push origin release

# tag the files and push tags
echo 'tagging files with v'$1
git tag v$1
git push --tags

# add /dist back to .gitignore
mv .gitignore.orig .gitignore

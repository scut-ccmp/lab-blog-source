#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
rm -rf  public/post*
find ./public -type f -name '*.html' -exec rm {} \;
find ./public -type f -name '*.xml' -exec rm {} \;
cd public
git checkout master
cd ..
# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master -f

# Come Back up to the Project Root
cd ..

# Add changes to source.
git add .

# Commit changes.
git commit -m "$msg"

# Push source.
git push

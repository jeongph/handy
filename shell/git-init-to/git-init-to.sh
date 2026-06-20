#!/bin/bash

# Fields
repository_name=""

# Run
echo -e "✨ Enter target repository link: "
read repository_name

echo `git init`
echo `git add --all`
echo `git commit -m \"init: initialize\"`
echo `git remote add origin $repository_name`
echo `git branch -M main`
echo `git push -u origin main`
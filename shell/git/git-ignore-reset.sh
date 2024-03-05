#!/bin/bash

echo `git rm --cached -r .`
echo `git add .`
echo `git commit -m "feat: Reset gitignore"`

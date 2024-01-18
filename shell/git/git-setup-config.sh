#!/bin/bash

# Fields
git_user_name=""
git_user_email=""

# Run
echo -e "🪄  Welcome to the git global configuration setup bash (exit: CTRL+Z)."

echo -e "✨ Enter your name: "
read git_user_name
echo -e "📩 Enter your email: "
read git_user_email

echo `git config --global user.name $git_user_name`
echo `git config --global user.email $git_user_email`

echo -e "✅ Settings up like this 👇"
echo `git config --list | grep user.`

echo -e "\n"
echo -e "🎉 All setup complete. BYE!!"

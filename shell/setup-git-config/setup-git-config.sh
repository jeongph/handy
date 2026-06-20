#!/bin/bash
# git 글로벌 user 설정 (대화형, 본인 정보 기본값)
# 엔터만 치면 기본값 적용, 다른 값 입력 시 그 값으로 설정

DEFAULT_NAME="JeongUk Park"
DEFAULT_EMAIL="jeongph.dev@gmail.com"

echo "🪄 git 글로벌 설정 (엔터: 기본값, 취소: CTRL+C)"

read -p "이름 [$DEFAULT_NAME]: " name
name="${name:-$DEFAULT_NAME}"

read -p "이메일 [$DEFAULT_EMAIL]: " email
email="${email:-$DEFAULT_EMAIL}"

git config --global user.name "$name"
git config --global user.email "$email"

echo "✅ 설정 완료:"
git config --global --get-regexp '^user\.'

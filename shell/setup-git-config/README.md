# setup-git-config

Git의 전역 사용자 이름과 이메일을 대화형으로 설정하는 스크립트다. Enter를 누르면 아래에 적힌 기본값을 적용한다.

## 하는 일

- `user.name`, `user.email`을 대화형으로 입력받아 `git config --global`에 설정
- 엔터만 치면 기본값(`JeongUk Park` / `jeongph.dev@gmail.com`) 적용, 다른 값 입력 시 그 값으로 설정
- 설정 후 현재 user 설정을 출력

## 실행

```sh
# 원격
bash <(curl -fsSL https://handy.jeongph.dev/setup-git-config)
# 로컬
bash shell/setup-git-config/setup-git-config.sh
```

## 수동으로 할 때

스크립트 없이 직접 설정하려면:

```sh
git config --global user.name "JeongUk Park"
git config --global user.email jeongph.dev@gmail.com
git config --list
```

# setup-git-config

git 글로벌 user 설정을 대화형으로 적용하는 스크립트. 본인 정보가 기본값이라 엔터만 쳐도 된다.

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

# git-init-to

로컬 프로젝트를 입력한 원격 저장소로 초기화·푸시하는 스크립트.

## 하는 일

대상 원격 저장소 링크를 입력받아 다음을 순서대로 실행한다:

1. `git init`
2. `git add --all`
3. `git commit -m "init: initialize"`
4. `git remote add origin <링크>`
5. `git branch -M main`
6. `git push -u origin main`

## 실행

```sh
# 원격
bash <(curl -fsSL https://handy.jeongph.dev/git-init-to)
# 로컬
bash shell/git-init-to/git-init-to.sh
```

## 주의

- 이미 git 저장소인 디렉토리에서 실행하지 말 것 (기존 이력과 충돌)
- 원격 저장소는 비어 있어야 한다 (push 충돌 방지)

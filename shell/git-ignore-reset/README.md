# git-ignore-reset

`.gitignore`를 변경한 뒤 캐시를 비우고 ignore 규칙을 다시 적용하는 스크립트.

## 하는 일

`.gitignore`를 수정해도 이미 추적 중인 파일은 계속 추적된다. 이 스크립트는 인덱스(캐시)를 비워 ignore 규칙을 전체에 다시 적용한다:

1. `git rm --cached -r .` — 인덱스에서 전체 제거
2. `git add .` — ignore 규칙을 반영해 다시 추가
3. `git commit -m "feat: Reset gitignore"`

## 실행

```sh
# 원격
bash <(curl -fsSL https://jeongph.dev/handy/git-ignore-reset)
# 로컬
bash shell/git-ignore-reset/git-ignore-reset.sh
```

## 주의

- working tree의 실제 파일은 지워지지 않는다 (인덱스만 갱신)
- 커밋 후 `git push`는 수동으로 한다 (스크립트는 push하지 않음)

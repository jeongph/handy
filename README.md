# handy

자주 쓰는 셸 스크립트·치트시트 모음.

## 구조

- `shell/` — 실행 스크립트 (각 폴더에 스크립트 + 사용법 `README.md`)
- `cheatsheet/` — 읽는 치트시트·가이드 문서

## 원격 실행

```sh
bash <(curl -fsSL https://handy.jeongph.dev/<스크립트명>)
```

> 단축 도메인 `handy.jeongph.dev/*`는 Cloudflare Worker 라우터가 GitHub raw로 연결한다. (셋업: #9)

## 스크립트 (shell/)

### [setup-alias](shell/setup-alias/)

자주 쓰는 alias 선택 설치/제거

```sh
source <(curl -fsSL https://handy.jeongph.dev/setup-alias)
```

### [setup-git-config](shell/setup-git-config/)

git 글로벌 user 설정 (본인 정보 기본값)

```sh
bash <(curl -fsSL https://handy.jeongph.dev/setup-git-config)
```

### [git-init-to](shell/git-init-to/)

로컬 프로젝트를 원격 저장소로 초기화·푸시

```sh
bash <(curl -fsSL https://handy.jeongph.dev/git-init-to)
```

### [git-ignore-reset](shell/git-ignore-reset/)

`.gitignore` 변경 후 캐시 재설정

```sh
bash <(curl -fsSL https://handy.jeongph.dev/git-ignore-reset)
```

### [ssh-config-sync](shell/ssh-config-sync/)

SSH config 병합·동기화 — clone 후 로컬 실행 (로컬 설정 파일 필요). [사용법](shell/ssh-config-sync/)

### [claude-code-clean-remove](shell/claude-code-clean-remove/)

Claude Code 네이티브 설치본 제거 — clone 후 일반 터미널에서 실행. [사용법](shell/claude-code-clean-remove/)

### [chmod755](shell/chmod755/)

현재 디렉토리에 755 권한 부여 — 로컬 실행. [사용법](shell/chmod755/)

## 치트시트 (cheatsheet/)

- **guide** — [gh](cheatsheet/guide/gh.md) · [tmux](cheatsheet/guide/tmux.md) · [claude-code](cheatsheet/guide/claude-code.md)
- **git** — [first-commit](cheatsheet/git/first-commit.md) · [local-config](cheatsheet/git/local-config.md)
- **macos** — [env-variables](cheatsheet/macos/env-variables.md)

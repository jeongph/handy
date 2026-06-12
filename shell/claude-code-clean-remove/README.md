# Claude Code Clean Remove

Claude Code 네이티브 설치본(`curl -fsSL https://claude.ai/install.sh | bash` 로 깐 것)을 깔끔하게 제거하는 스크립트.

`install.sh` 는 `claude install` 을 호출해 런처/버전 저장소를 `~/.local` 아래에 깔기 때문에 별도 uninstall 명령이 없다 → 수동 삭제가 정답.

> ⚠️ **Claude Code 안에서 실행하지 말 것.** 실행 중인 자기 자신을 지우게 된다. 일반 터미널 창에서 실행한다. (스크립트가 `CLAUDECODE` 환경변수를 감지해 막아준다.)

## 실행

```bash
# 대화형으로 모드 선택
./claude-code-clean-remove.sh

# 바이너리만 제거 (설정·로그인 유지)
./claude-code-clean-remove.sh --binary

# 완전 삭제 (확인 생략)
./claude-code-clean-remove.sh --full --yes

# 미리보기 (실제 삭제 안 함)
./claude-code-clean-remove.sh --full --dry-run
```

## 제거 모드

| 모드 | 제거 대상 | 용도 |
|------|-----------|------|
| `--binary` | 런처 + 버전 저장소 | 깔끔히 재설치 (설정·로그인·플러그인 유지) |
| `--full` | 위 + 설정·데이터·전역설정·Keychain 로그인 | 흔적까지 완전 삭제 |

## 삭제되는 항목

| 항목 | 경로 | `--binary` | `--full` |
|------|------|:---:|:---:|
| 런처(심볼릭 링크) | `~/.local/bin/claude` | ✓ | ✓ |
| 버전 바이너리 저장소 | `~/.local/share/claude` | ✓ | ✓ |
| 설정·프로젝트·플러그인·세션·기록 | `~/.claude` | | ✓ |
| 전역 설정·로그인 상태 | `~/.claude.json`, `~/.claude.json.backup` | | ✓ |
| Keychain 로그인 인증정보 (macOS) | service `Claude Code-credentials` | | ✓ |

## 옵션

| 옵션 | 동작 |
|------|------|
| `--binary` | 바이너리/런처/버전 저장소만 제거 |
| `--full` | 설정·로그인까지 완전 삭제 |
| `-y`, `--yes` | 확인 프롬프트 없이 진행 |
| `-n`, `--dry-run` | 삭제하지 않고 대상만 출력 (용량 포함) |
| `-h`, `--help` | 도움말 |

## 자동으로 건드리지 않는 것

안전을 위해 다음은 스크립트가 손대지 않고 안내만 한다.

- **PATH** — `~/.zshrc` 의 `export PATH="$HOME/.local/bin:$PATH"` 는 claude 전용이 아니라 `~/.local/bin` 의 다른 도구(pipx 등)도 쓰므로 직접 판단해 제거한다.
- **alias** — `c` / `cx` / `c-yolo` 는 [`setup-aliases.sh`](../setup-alias/) 가 관리하므로 거기서 제거한다:
  ```bash
  ./setup-aliases.sh --remove
  ```

## 검증

```bash
which claude   # 아무것도 안 나오면 제거 완료 (새 터미널 또는 hash -r 후)
```

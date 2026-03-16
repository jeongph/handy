# Setup Aliases

자주 사용하는 alias들을 쉘 RC 파일에 선택적으로 추가하는 스크립트

## 실행

```bash
source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)
```

체크박스 UI에서 원하는 alias를 선택한 뒤 Enter로 적용

이후 업데이트는 `alias-fetch`로 실행

## 제거

```bash
source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh) --remove
```

스크립트가 설치한 모든 alias를 RC 파일에서 제거하고 현재 셸에서 해제

## 옵션

```bash
# 전체 alias 추가 (선택 UI 생략)
source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh) --all

# 제거
source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh) --remove

# 대화형 모드 (RC 파일 직접 선택)
./setup-aliases.sh -i

# 도움말
./setup-aliases.sh -h
```

## 체크박스 조작법

| 키 | 동작 |
|----|------|
| `↑` `↓` | 항목 이동 |
| `Space` | 선택/해제 토글 |
| `a` | 전체 선택 |
| `n` | 전체 해제 |
| `Enter` | 확인 |
| `q` | 취소 |

## 상태 표시

| 표시 | 의미 |
|------|------|
| `[✓] name → value` | 신규 추가 예정 |
| `[✓] name → value` (흐리게) | 이미 설치됨 (동일 값) |
| `[✓] name old => new` | 값 변경 (빨간=현재, 초록=신규) |

## RC 파일 관리 방식

스크립트는 마커 블록으로 alias를 관리합니다:

```bash
# >>> https://jeongph.dev/handy/setup-aliases.sh >>>
alias alias-fetch='source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)'
alias c='claude'
...
# <<< https://jeongph.dev/handy/setup-aliases.sh <<<
```

- 설치/업데이트 시 블록 전체를 교체
- `--remove` 시 블록 전체를 삭제
- 블록 밖의 사용자 alias에는 영향 없음

## 포함된 Alias

### 필수 (항상 포함)
| Alias | 명령어 |
|-------|--------|
| `alias-fetch` | `source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)` |

### Claude Code
| Alias | 명령어 |
|-------|--------|
| `c` | `claude` |
| `cx` | `claude --dangerously-skip-permissions --effort max` |
| `c-sudo` | `claude --dangerously-skip-permissions` |

### Tmux
| Alias | 명령어 |
|-------|--------|
| `t` | `tmux` |
| `tn` | `tmux new -s` |
| `tls` | `tmux ls` |
| `ta` | `tmux a` |
| `tat` | `tmux a -t` |
| `tkt` | `tmux kill-session -t` |
| `tk` | `tmux kill-session` |

### Kubernetes
| Alias | 명령어 |
|-------|--------|
| `k` | `kubectl` |
| `ktl` | `kubectl` |

### Directory
| Alias | 명령어 |
|-------|--------|
| `ll` | `ls -lF` |
| `la` | `ls -alF` |
| `..` | `cd ..` |
| `...` | `cd ../..` |

## 특징

- 체크박스 UI로 alias 선택 설치
- 마커 블록 방식으로 안전한 설치/업데이트/제거
- 기존 alias와 값 비교하여 상태 표시 (신규/동일/변경)
- bash/zsh 모두 호환 (`/dev/tty` 사용)
- `source <(curl ...)` 파이프 실행에서도 정상 동작
- 비대화형 환경 자동 감지 → `--all` 모드 전환
- source 방식 실행 시 alias 자동 적용/해제

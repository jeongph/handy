# Setup Aliases

자주 사용하는 alias들을 쉘 RC 파일에 중복 없이 추가하는 스크립트

## 실행

```bash
source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)
```

이후 업데이트는 `alias-fetch`로 실행

## 옵션

```bash
# 대화형 모드 (RC 파일 직접 선택)
./setup-aliases.sh -i
./setup-aliases.sh --interactive

# 도움말
./setup-aliases.sh -h
```

## 포함된 Alias

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
| `tnew` | `tmux new -s` |
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

- 쉘 자동 감지 (`$SHELL` 기반)
- 중복 추가 방지
- 대화형 모드 지원
- source 방식 실행 시 alias 자동 적용

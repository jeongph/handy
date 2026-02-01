# Setup Aliases

자주 사용하는 alias들을 쉘 RC 파일에 중복 없이 추가하는 스크립트

## 실행

```bash
wget -O - https://raw.githubusercontent.com/jeongph/handy/refs/heads/main/shell/setup-alias/setup-aliases.sh | bash
```

## 옵션

```bash
# 대화형 모드 (RC 파일 직접 선택)
./setup-aliases.sh -i
./setup-aliases.sh --interactive

# 도움말
./setup-aliases.sh -h
```

## 포함된 Alias

### Tmux
| Alias | 명령어 |
|-------|--------|
| `t` | `tmux` |
| `tnew` | `tmux new -s` |
| `tls` | `tmux ls` |
| `ta` | `tmux a` |
| `tat` | `tmux a -t` |

### Kubernetes
| Alias | 명령어 |
|-------|--------|
| `k` | `kubectl` |
| `ktl` | `kubectl` |

### Directory
| Alias | 명령어 |
|-------|--------|
| `ll` | `ls -la` |
| `la` | `ls -A` |
| `..` | `cd ..` |
| `...` | `cd ../..` |

## 특징

- 쉘 자동 감지 (`$SHELL` 기반)
- 중복 추가 방지
- 대화형 모드 지원

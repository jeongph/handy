#!/bin/bash

# setup-aliases.sh
# 자주 사용하는 alias들을 쉘 RC 파일에 중복 없이 추가하는 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 추가할 alias 목록 (name|value 형식)
ALIASES=(
    "alias-update|wget -O - https://raw.githubusercontent.com/jeongph/handy/refs/heads/main/shell/setup-alias/setup-aliases.sh | bash"
    # Claude code
    "c|claude"
    "c-sudo|claude --dangerously-skip-permissions"
    # Tmux
    "t|tmux"
    "tnew|tmux new -s"
    "tls|tmux ls"
    "ta|tmux a"
    "tat|tmux a -t"
    # Kubernetes
    "k|kubectl"
    "ktl|kubectl"
    # Directory
    "ll|ls -la"
    "la|ls -A"
    "..|cd .."
    "...|cd ../.."
)

# RC 파일 자동 감지
detect_rc_file() {
    local shell_name
    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            echo "$HOME/.bashrc"
            ;;
        *)
            echo ""
            ;;
    esac
}

# 대화형 RC 파일 선택
select_rc_file() {
    echo "RC 파일을 선택하세요:"
    echo "1) ~/.zshrc"
    echo "2) ~/.bashrc"
    echo "3) ~/.bash_profile"
    echo "4) 직접 입력"

    read -p "선택 (1-4): " choice

    case "$choice" in
        1)
            echo "$HOME/.zshrc"
            ;;
        2)
            echo "$HOME/.bashrc"
            ;;
        3)
            echo "$HOME/.bash_profile"
            ;;
        4)
            read -p "RC 파일 경로 입력: " custom_path
            # ~ 확장 처리
            echo "${custom_path/#\~/$HOME}"
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}" >&2
            exit 1
            ;;
    esac
}

# alias 존재 여부 확인
alias_exists() {
    local rc_file="$1"
    local alias_name="$2"

    grep -q "^alias ${alias_name}=" "$rc_file" 2>/dev/null
}

# alias 추가
add_alias() {
    local rc_file="$1"
    local alias_name="$2"
    local alias_value="$3"

    if alias_exists "$rc_file" "$alias_name"; then
        echo -e "${YELLOW}[SKIP]${NC} alias '$alias_name' 이미 존재"
        return 0
    fi

    echo "alias ${alias_name}='${alias_value}'" >> "$rc_file"
    echo -e "${GREEN}[ADD]${NC} alias ${alias_name}='${alias_value}'"
}

# 메인 로직
main() {
    local interactive=false
    local rc_file=""

    # 인자 파싱
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interactive)
                interactive=true
                shift
                ;;
            -h|--help)
                echo "사용법: $0 [-i|--interactive]"
                echo ""
                echo "옵션:"
                echo "  -i, --interactive  대화형 모드로 RC 파일 선택"
                echo "  -h, --help         도움말 출력"
                exit 0
                ;;
            *)
                echo -e "${RED}알 수 없는 옵션: $1${NC}" >&2
                exit 1
                ;;
        esac
    done

    # RC 파일 결정
    if [ "$interactive" = true ]; then
        rc_file=$(select_rc_file)
    else
        rc_file=$(detect_rc_file)

        if [ -z "$rc_file" ]; then
            echo -e "${YELLOW}쉘을 자동 감지할 수 없습니다. 대화형 모드로 전환합니다.${NC}"
            rc_file=$(select_rc_file)
        fi
    fi

    # RC 파일 존재 확인
    if [ ! -f "$rc_file" ]; then
        echo -e "${YELLOW}$rc_file 파일이 없습니다. 새로 생성합니다.${NC}"
        touch "$rc_file"
    fi

    echo ""
    echo "대상 RC 파일: $rc_file"
    echo "================================"
    echo ""

    # alias 추가
    local added=0
    local skipped=0

    for entry in "${ALIASES[@]}"; do
        local alias_name="${entry%%|*}"
        local alias_value="${entry#*|}"

        if alias_exists "$rc_file" "$alias_name"; then
            echo -e "${YELLOW}[SKIP]${NC} alias '$alias_name' 이미 존재"
            skipped=$((skipped + 1))
        else
            echo "alias ${alias_name}='${alias_value}'" >> "$rc_file"
            echo -e "${GREEN}[ADD]${NC} alias ${alias_name}='${alias_value}'"
            added=$((added + 1))
        fi
    done

    echo ""
    echo "================================"
    echo -e "완료: ${GREEN}${added}개 추가${NC}, ${YELLOW}${skipped}개 스킵${NC}"
    echo ""
    echo "적용하려면 다음 명령을 실행하세요:"
    echo -e "  ${GREEN}source $rc_file${NC}"
}

main "$@"

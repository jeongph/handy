#!/bin/bash

# setup-aliases.sh
# 자주 사용하는 alias들을 쉘 RC 파일에 선택적으로 추가하는 스크립트

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 카테고리|이름|값 형식의 alias 목록
ALIAS_ENTRIES=(
    "General|alias-fetch|source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)"
    "Claude Code|c|claude"
    "Claude Code|cx|claude --dangerously-skip-permissions --effort max"
    "Claude Code|c-sudo|claude --dangerously-skip-permissions"
    "Tmux|t|tmux"
    "Tmux|tn|tmux new -s"
    "Tmux|tls|tmux ls"
    "Tmux|ta|tmux a"
    "Tmux|tat|tmux a -t"
    "Tmux|tkt|tmux kill-session -t"
    "Tmux|tk|tmux kill-session"
    "Kubernetes|k|kubectl"
    "Kubernetes|ktl|kubectl"
    "Directory|ll|ls -lF"
    "Directory|la|ls -alF"
    "Directory|..|cd .."
    "Directory|...|cd ../.."
)

# RC 파일 자동 감지
detect_rc_file() {
    local shell_name
    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *)    echo "" ;;
    esac
}

# 대화형 RC 파일 선택
select_rc_file() {
    echo "RC 파일을 선택하세요:" > /dev/tty
    echo "1) ~/.zshrc" > /dev/tty
    echo "2) ~/.bashrc" > /dev/tty
    echo "3) ~/.bash_profile" > /dev/tty
    echo "4) 직접 입력" > /dev/tty

    read -p "선택 (1-4): " choice < /dev/tty

    case "$choice" in
        1) echo "$HOME/.zshrc" ;;
        2) echo "$HOME/.bashrc" ;;
        3) echo "$HOME/.bash_profile" ;;
        4)
            read -p "RC 파일 경로 입력: " custom_path < /dev/tty
            echo "${custom_path/#\~/$HOME}"
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}" > /dev/tty
            return 1
            ;;
    esac
}

# alias 존재 여부 확인
alias_exists() {
    local rc_file="$1"
    local alias_name="$2"
    grep -q "^alias ${alias_name}=" "$rc_file" 2>/dev/null
}

# 키 입력 읽기 (bash/zsh 호환)
read_key() {
    local key
    if [ -n "$ZSH_VERSION" ]; then
        read -rsk1 key < /dev/tty
    else
        IFS= read -rsn1 key < /dev/tty
    fi

    if [[ "$key" == $'\x1b' ]]; then
        if [ -n "$ZSH_VERSION" ]; then
            read -rsk2 -t 0.1 key < /dev/tty 2>/dev/null || key=""
        else
            read -rsn2 -t 0.1 key < /dev/tty 2>/dev/null || key=""
        fi
        case "$key" in
            '[A') echo "UP" ;;
            '[B') echo "DOWN" ;;
            *)    echo "OTHER" ;;
        esac
    elif [[ "$key" == " " ]]; then
        echo "SPACE"
    elif [[ "$key" == "" || "$key" == $'\n' ]]; then
        echo "ENTER"
    elif [[ "$key" == "a" || "$key" == "A" ]]; then
        echo "ALL"
    elif [[ "$key" == "n" || "$key" == "N" ]]; then
        echo "NONE"
    elif [[ "$key" == "q" || "$key" == "Q" ]]; then
        echo "QUIT"
    else
        echo "OTHER"
    fi
}

# 메뉴 라인 수 계산
count_menu_lines() {
    local lines=0
    local prev_cat=""
    for entry in "${ALIAS_ENTRIES[@]}"; do
        local cat="${entry%%|*}"
        if [[ "$cat" != "$prev_cat" ]]; then
            [[ $lines -gt 0 ]] && lines=$((lines + 1))
            lines=$((lines + 1))
            prev_cat="$cat"
        fi
        lines=$((lines + 1))
    done
    lines=$((lines + 2))
    echo "$lines"
}

# 메뉴 그리기
draw_menu() {
    local prev_cat=""
    local idx=0
    local sel_count=0

    for entry in "${ALIAS_ENTRIES[@]}"; do
        local cat="${entry%%|*}"
        local rest="${entry#*|}"
        local name="${rest%%|*}"
        local value="${rest#*|}"

        # 카테고리 헤더
        if [[ "$cat" != "$prev_cat" ]]; then
            [[ -n "$prev_cat" ]] && printf '\033[K\n' > /dev/tty
            printf "  \033[1;36m── %s ──\033[0m\033[K\n" "$cat" > /dev/tty
            prev_cat="$cat"
        fi

        # 선택 표시
        local check=" "
        if [[ "${selected[$idx]}" == "1" ]]; then
            check="\033[0;32m✓\033[0m"
            sel_count=$((sel_count + 1))
        fi

        # 커서 위치에 따라 하이라이트
        if [[ $idx -eq $cursor ]]; then
            printf "\033[1m▸ \033[0m[${check}] \033[1m%-10s\033[0m \033[2m→\033[0m %s\033[K\n" "$name" "$value" > /dev/tty
        else
            printf "  [${check}] %-10s \033[2m→\033[0m %s\033[K\n" "$name" "$value" > /dev/tty
        fi

        idx=$((idx + 1))
    done

    # 선택 현황
    printf '\033[K\n' > /dev/tty
    printf "  \033[2m%d/%d 선택됨\033[0m\033[K" "$sel_count" "${#ALIAS_ENTRIES[@]}" > /dev/tty
}

# 체크박스 선택 UI
select_aliases() {
    local count=${#ALIAS_ENTRIES[@]}
    local total_lines
    total_lines=$(count_menu_lines)
    cursor=0

    # 전체 선택으로 초기화
    for ((i=0; i<count; i++)); do
        selected[$i]=1
    done

    # 커서 숨기기 & Ctrl+C 시 복원
    printf '\033[?25l' > /dev/tty
    trap 'printf "\033[?25h\n" > /dev/tty; return 1' INT

    # 안내 헤더
    printf '\n' > /dev/tty
    printf "  \033[1m적용할 alias를 선택하세요\033[0m\n" > /dev/tty
    printf "  \033[2m↑↓ 이동 │ Space 선택 │ a 전체선택 │ n 전체해제 │ Enter 확인 │ q 취소\033[0m\n" > /dev/tty
    printf '\n' > /dev/tty

    # 초기 그리기
    draw_menu
    printf '\n' > /dev/tty

    while true; do
        local key
        key=$(read_key)

        case "$key" in
            UP)    [[ $cursor -gt 0 ]] && cursor=$((cursor - 1)) ;;
            DOWN)  [[ $cursor -lt $((count - 1)) ]] && cursor=$((cursor + 1)) ;;
            SPACE) selected[$cursor]=$(( 1 - ${selected[$cursor]} )) ;;
            ALL)   for ((i=0; i<count; i++)); do selected[$i]=1; done ;;
            NONE)  for ((i=0; i<count; i++)); do selected[$i]=0; done ;;
            ENTER) break ;;
            QUIT)
                printf '\033[?25h' > /dev/tty
                printf '\n' > /dev/tty
                echo -e "${YELLOW}취소되었습니다.${NC}" > /dev/tty
                return 1
                ;;
        esac

        # 메뉴 위치로 이동 후 재그리기
        printf '\033[%dA\r' "$total_lines" > /dev/tty
        draw_menu
        printf '\n' > /dev/tty
    done

    printf '\033[?25h' > /dev/tty
    printf '\n' > /dev/tty
    return 0
}

# 메인 로직
main() {
    # zsh 호환성: 0-based 배열 인덱싱 (함수 종료 시 자동 복원)
    [ -n "$ZSH_VERSION" ] && setopt LOCAL_OPTIONS KSH_ARRAYS

    local interactive=false
    local select_all=false
    typeset -a selected

    # 인자 파싱
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interactive)
                interactive=true
                shift
                ;;
            -a|--all)
                select_all=true
                shift
                ;;
            -h|--help)
                echo "사용법: $0 [옵션]"
                echo ""
                echo "옵션:"
                echo "  -i, --interactive  대화형 모드로 RC 파일 선택"
                echo "  -a, --all          전체 alias 추가 (선택 UI 생략)"
                echo "  -h, --help         도움말 출력"
                return 0
                ;;
            *)
                echo -e "${RED}알 수 없는 옵션: $1${NC}" >&2
                return 1
                ;;
        esac
    done

    # 대화형 터미널 확인
    if [ "$select_all" = false ] && ! [ -c /dev/tty ]; then
        echo -e "${YELLOW}대화형 터미널이 아닙니다. 전체 alias를 추가합니다.${NC}"
        select_all=true
    fi

    # RC 파일 결정
    local rc_file=""
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

    # alias 선택
    if [ "$select_all" = true ]; then
        for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
            selected[$i]=1
        done
    else
        if ! select_aliases; then
            return 1
        fi
    fi

    # 선택된 항목 확인
    local sel_count=0
    for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
        [[ "${selected[$i]}" == "1" ]] && sel_count=$((sel_count + 1))
    done

    if [ "$sel_count" -eq 0 ]; then
        echo -e "${YELLOW}선택된 alias가 없습니다.${NC}"
        return 0
    fi

    echo ""
    echo "대상 RC 파일: $rc_file"
    echo "================================"
    echo ""

    # 선택된 alias 추가
    local added=0
    local skipped=0

    for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
        [[ "${selected[$i]}" != "1" ]] && continue

        local entry="${ALIAS_ENTRIES[$i]}"
        local rest="${entry#*|}"
        local alias_name="${rest%%|*}"
        local alias_value="${rest#*|}"

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

    if [ "$added" -gt 0 ]; then
        echo ""
        # source로 실행된 경우: 현재 셸에 바로 적용
        # bash로 실행된 경우: 자식 셸이라 적용 불가 → 안내 출력
        if [[ "${BASH_SOURCE[0]}" != "${0}" ]] 2>/dev/null || [ -n "$ZSH_EVAL_CONTEXT" ]; then
            source "$rc_file"
            echo -e "${GREEN}alias가 현재 셸에 적용되었습니다.${NC}"
        else
            echo -e "${YELLOW}현재 셸에 바로 적용하려면:${NC}"
            echo -e "  ${GREEN}source $rc_file${NC}"
        fi
    fi
}

main "$@"

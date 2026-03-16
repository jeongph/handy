#!/bin/bash

# setup-aliases.sh
# 자주 사용하는 alias들을 쉘 RC 파일에 선택적으로 추가하는 스크립트
# 마커 블록으로 관리하여 설치/업데이트/제거를 안전하게 처리

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 마커
MARKER_BEGIN="# >>> https://jeongph.dev/handy/setup-aliases.sh >>>"
MARKER_END="# <<< https://jeongph.dev/handy/setup-aliases.sh <<<"

# 항상 포함되는 alias
ALWAYS_ALIAS_NAME="alias-fetch"
ALWAYS_ALIAS_VALUE="source <(curl -fsSL https://jeongph.dev/handy/setup-aliases.sh)"

# 카테고리|이름|값
ALIAS_ENTRIES=(
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

# ── RC 파일 ──

detect_rc_file() {
    local shell_name
    shell_name=$(basename "$SHELL")
    case "$shell_name" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        *)    echo "" ;;
    esac
}

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

# ── 마커 블록 관리 ──

block_exists() {
    local rc_file="$1"
    grep -Fq "$MARKER_BEGIN" "$rc_file" 2>/dev/null
}

get_block_content() {
    local rc_file="$1"
    local start_line end_line
    start_line=$(grep -Fn "$MARKER_BEGIN" "$rc_file" 2>/dev/null | head -1 | cut -d: -f1)
    [ -z "$start_line" ] && return
    end_line=$(grep -Fn "$MARKER_END" "$rc_file" 2>/dev/null | head -1 | cut -d: -f1)
    [ -z "$end_line" ] && return
    sed -n "${start_line},${end_line}p" "$rc_file"
}

remove_block() {
    local rc_file="$1"
    local start_line end_line
    start_line=$(grep -Fn "$MARKER_BEGIN" "$rc_file" 2>/dev/null | head -1 | cut -d: -f1)
    [ -z "$start_line" ] && return 0
    end_line=$(grep -Fn "$MARKER_END" "$rc_file" 2>/dev/null | head -1 | cut -d: -f1)
    [ -z "$end_line" ] && return 0
    # 마커 앞 빈 줄도 함께 제거
    if [ "$start_line" -gt 1 ]; then
        local prev_line
        prev_line=$(sed -n "$((start_line - 1))p" "$rc_file")
        [ -z "$prev_line" ] && start_line=$((start_line - 1))
    fi
    sed "${start_line},${end_line}d" "$rc_file" > "${rc_file}.tmp.$$" && mv "${rc_file}.tmp.$$" "$rc_file"
}

# 블록 캐시에서 특정 alias 값 추출
block_alias_value() {
    local alias_name="$1"
    [ -z "$block_cache" ] && return
    local line
    line=$(echo "$block_cache" | grep "^alias ${alias_name}=" | head -1)
    [ -z "$line" ] && return
    local value="${line#alias ${alias_name}=}"
    if [[ "$value" == \'*\' ]]; then
        value="${value#\'}"
        value="${value%\'}"
    elif [[ "$value" == \"*\" ]]; then
        value="${value#\"}"
        value="${value%\"}"
    fi
    echo "$value"
}

# ── 키 입력 (bash/zsh 호환) ──

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

# ── 메뉴 UI ──

count_menu_lines() {
    local lines=2  # 고정 alias: 헤더(1) + 항목(1)
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

draw_menu() {
    local prev_cat="_required_"
    local idx=0
    local sel_count=0
    local total_count=${#ALIAS_ENTRIES[@]}

    # 고정 alias
    printf "  \033[1;36m── 필수 ──\033[0m\033[K\n" > /dev/tty
    if [[ "$always_status" == "changed" ]]; then
        printf "  [\033[0;32m✓\033[0m] %-10s \033[0;31m%s\033[0m \033[2m=>\033[0m \033[0;32m%s\033[0m\033[K\n" \
            "$ALWAYS_ALIAS_NAME" "$always_current" "$ALWAYS_ALIAS_VALUE" > /dev/tty
    elif [[ "$always_status" == "installed" ]]; then
        printf "  \033[2m[✓] %-10s → %s\033[0m\033[K\n" "$ALWAYS_ALIAS_NAME" "$ALWAYS_ALIAS_VALUE" > /dev/tty
    else
        printf "  [\033[0;32m✓\033[0m] %-10s \033[2m→\033[0m %s\033[K\n" "$ALWAYS_ALIAS_NAME" "$ALWAYS_ALIAS_VALUE" > /dev/tty
    fi

    for entry in "${ALIAS_ENTRIES[@]}"; do
        local cat="${entry%%|*}"
        local rest="${entry#*|}"
        local name="${rest%%|*}"
        local value="${rest#*|}"
        local astate="${alias_status[$idx]}"
        local is_cursor=false
        [[ $idx -eq $cursor ]] && is_cursor=true

        # 카테고리 헤더
        if [[ "$cat" != "$prev_cat" ]]; then
            printf '\033[K\n' > /dev/tty
            printf "  \033[1;36m── %s ──\033[0m\033[K\n" "$cat" > /dev/tty
            prev_cat="$cat"
        fi

        local check=" "
        if [[ "${selected[$idx]}" == "1" ]]; then
            check="\033[0;32m✓\033[0m"
            sel_count=$((sel_count + 1))
        fi

        if [[ "$astate" == "installed" ]]; then
            if [ "$is_cursor" = true ]; then
                printf "\033[1m▸ \033[0m\033[2m[${check}\033[2m] %-10s → %s\033[0m\033[K\n" "$name" "$value" > /dev/tty
            else
                printf "  \033[2m[${check}\033[2m] %-10s → %s\033[0m\033[K\n" "$name" "$value" > /dev/tty
            fi
        elif [[ "$astate" == "changed" ]]; then
            local current="${alias_current[$idx]}"
            if [ "$is_cursor" = true ]; then
                printf "\033[1m▸ \033[0m[${check}] \033[1m%-10s\033[0m \033[0;31m%s\033[0m \033[2m=>\033[0m \033[0;32m%s\033[0m\033[K\n" \
                    "$name" "$current" "$value" > /dev/tty
            else
                printf "  [${check}] %-10s \033[0;31m%s\033[0m \033[2m=>\033[0m \033[0;32m%s\033[0m\033[K\n" \
                    "$name" "$current" "$value" > /dev/tty
            fi
        else
            if [ "$is_cursor" = true ]; then
                printf "\033[1m▸ \033[0m[${check}] \033[1m%-10s\033[0m \033[2m→\033[0m %s\033[K\n" "$name" "$value" > /dev/tty
            else
                printf "  [${check}] %-10s \033[2m→\033[0m %s\033[K\n" "$name" "$value" > /dev/tty
            fi
        fi

        idx=$((idx + 1))
    done

    printf '\033[K\n' > /dev/tty
    printf "  \033[2m%d/%d 선택됨\033[0m\033[K" "$sel_count" "$total_count" > /dev/tty
}

select_aliases() {
    local count=${#ALIAS_ENTRIES[@]}
    local total_lines
    total_lines=$(count_menu_lines)
    cursor=0

    for ((i=0; i<count; i++)); do
        selected[$i]=1
    done

    printf '\033[?25l' > /dev/tty
    trap 'printf "\033[?25h\n" > /dev/tty; return 1' INT

    printf '\n' > /dev/tty
    printf "  \033[1m적용할 alias를 선택하세요\033[0m\n" > /dev/tty
    printf "  \033[2m↑↓ 이동 │ Space 선택 │ a 전체선택 │ n 전체해제 │ Enter 확인 │ q 취소\033[0m\n" > /dev/tty
    printf '\n' > /dev/tty

    draw_menu

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
                printf '\n\n' > /dev/tty
                echo -e "${YELLOW}취소되었습니다.${NC}" > /dev/tty
                return 1
                ;;
        esac

        printf '\033[%dA\r' "$((total_lines - 1))" > /dev/tty
        draw_menu
    done

    printf '\033[?25h' > /dev/tty
    printf '\n\n' > /dev/tty
    return 0
}

# ── 상태 분석 ──

analyze_aliases() {
    local rc_file="$1"

    block_cache=""
    if block_exists "$rc_file"; then
        block_cache=$(get_block_content "$rc_file")
    fi

    # 고정 alias
    local current
    current=$(block_alias_value "$ALWAYS_ALIAS_NAME")
    if [ -n "$current" ]; then
        if [[ "$current" == "$ALWAYS_ALIAS_VALUE" ]]; then
            always_status="installed"
        else
            always_status="changed"
            always_current="$current"
        fi
    else
        always_status="new"
        always_current=""
    fi

    # 선택 alias
    for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
        local entry="${ALIAS_ENTRIES[$i]}"
        local rest="${entry#*|}"
        local name="${rest%%|*}"
        local new_value="${rest#*|}"

        current=$(block_alias_value "$name")
        if [ -n "$current" ]; then
            if [[ "$current" == "$new_value" ]]; then
                alias_status[$i]="installed"
            else
                alias_status[$i]="changed"
                alias_current[$i]="$current"
            fi
        else
            alias_status[$i]="new"
        fi
    done
}

# ── 메인 ──

main() {
    [ -n "$ZSH_VERSION" ] && setopt LOCAL_OPTIONS KSH_ARRAYS

    local interactive=false
    local select_all=false
    local remove_mode=false
    typeset -a selected
    typeset -a alias_status
    typeset -a alias_current
    local always_status=""
    local always_current=""
    local block_cache=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interactive) interactive=true; shift ;;
            -a|--all) select_all=true; shift ;;
            --remove) remove_mode=true; shift ;;
            -h|--help)
                echo "사용법: $0 [옵션]"
                echo ""
                echo "옵션:"
                echo "  -i, --interactive  대화형 모드로 RC 파일 선택"
                echo "  -a, --all          전체 alias 추가/업데이트 (선택 UI 생략)"
                echo "  --remove           설치된 모든 alias 제거"
                echo "  -h, --help         도움말 출력"
                return 0
                ;;
            *) echo -e "${RED}알 수 없는 옵션: $1${NC}" >&2; return 1 ;;
        esac
    done

    if [ "$select_all" = false ] && [ "$remove_mode" = false ] && ! [ -c /dev/tty ]; then
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

    if [ ! -f "$rc_file" ]; then
        if [ "$remove_mode" = true ]; then
            echo -e "${YELLOW}$rc_file 파일이 없습니다.${NC}"
            return 0
        fi
        echo -e "${YELLOW}$rc_file 파일이 없습니다. 새로 생성합니다.${NC}"
        touch "$rc_file"
    fi

    # ── 제거 모드 ──
    if [ "$remove_mode" = true ]; then
        if ! block_exists "$rc_file"; then
            echo -e "${YELLOW}설치된 alias 블록이 없습니다.${NC}"
            return 0
        fi

        echo ""
        echo "대상 RC 파일: $rc_file"
        echo "================================"
        echo ""
        echo "제거될 alias:"

        get_block_content "$rc_file" | grep "^alias " | while read -r line; do
            local name_eq="${line#alias }"
            local aname="${name_eq%%=*}"
            echo -e "  ${RED}[-]${NC} ${aname}"
        done

        echo ""
        echo "================================"
        echo ""
        read -p "제거하시겠습니까? (y/N): " confirm < /dev/tty

        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo -e "${YELLOW}취소되었습니다.${NC}"
            return 0
        fi

        remove_block "$rc_file"

        # 현재 셸에서 alias 해제 (source 실행 시)
        if [[ "${BASH_SOURCE[0]}" != "${0}" ]] 2>/dev/null || [ -n "$ZSH_EVAL_CONTEXT" ]; then
            unalias "$ALWAYS_ALIAS_NAME" 2>/dev/null
            for entry in "${ALIAS_ENTRIES[@]}"; do
                local rest="${entry#*|}"
                local name="${rest%%|*}"
                unalias "$name" 2>/dev/null
            done
            echo -e "${GREEN}alias 블록이 제거되고 현재 셸에서 해제되었습니다.${NC}"
        else
            echo -e "${GREEN}alias 블록이 제거되었습니다.${NC}"
            echo -e "${YELLOW}현재 셸에 반영하려면 새 터미널을 열어주세요.${NC}"
        fi
        return 0
    fi

    # ── 설치/업데이트 모드 ──
    analyze_aliases "$rc_file"

    if [ "$select_all" = true ]; then
        for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
            selected[$i]=1
        done
    else
        if ! select_aliases; then
            return 1
        fi
    fi

    echo ""
    echo "대상 RC 파일: $rc_file"
    echo "================================"
    echo ""

    local added=0
    local updated=0
    local removed=0
    local unchanged=0

    # 고정 alias 상태
    if [[ "$always_status" == "installed" ]]; then
        echo -e "${DIM}[=]${NC} alias '$ALWAYS_ALIAS_NAME' 변경 없음"
        unchanged=$((unchanged + 1))
    elif [[ "$always_status" == "changed" ]]; then
        echo -e "${CYAN}[UPDATE]${NC} alias ${ALWAYS_ALIAS_NAME}='${ALWAYS_ALIAS_VALUE}'"
        updated=$((updated + 1))
    else
        echo -e "${GREEN}[ADD]${NC} alias ${ALWAYS_ALIAS_NAME}='${ALWAYS_ALIAS_VALUE}'"
        added=$((added + 1))
    fi

    # 선택 alias 상태
    for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
        local entry="${ALIAS_ENTRIES[$i]}"
        local rest="${entry#*|}"
        local alias_name="${rest%%|*}"
        local alias_value="${rest#*|}"
        local astate="${alias_status[$i]}"

        if [[ "${selected[$i]}" == "1" ]]; then
            if [[ "$astate" == "installed" ]]; then
                echo -e "${DIM}[=]${NC} alias '$alias_name' 변경 없음"
                unchanged=$((unchanged + 1))
            elif [[ "$astate" == "changed" ]]; then
                echo -e "${CYAN}[UPDATE]${NC} alias ${alias_name}='${alias_value}'"
                updated=$((updated + 1))
            else
                echo -e "${GREEN}[ADD]${NC} alias ${alias_name}='${alias_value}'"
                added=$((added + 1))
            fi
        elif [[ "$astate" == "installed" || "$astate" == "changed" ]]; then
            echo -e "${RED}[REMOVE]${NC} alias '${alias_name}'"
            removed=$((removed + 1))
        fi
    done

    # 블록 교체: 기존 제거 → 새로 작성
    remove_block "$rc_file"
    {
        echo ""
        echo "$MARKER_BEGIN"
        echo "alias ${ALWAYS_ALIAS_NAME}='${ALWAYS_ALIAS_VALUE}'"
        for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
            [[ "${selected[$i]}" != "1" ]] && continue
            local entry="${ALIAS_ENTRIES[$i]}"
            local rest="${entry#*|}"
            local alias_name="${rest%%|*}"
            local alias_value="${rest#*|}"
            echo "alias ${alias_name}='${alias_value}'"
        done
        echo "$MARKER_END"
    } >> "$rc_file"

    # 제거된 alias는 현재 셸에서 해제
    if [ "$removed" -gt 0 ]; then
        if [[ "${BASH_SOURCE[0]}" != "${0}" ]] 2>/dev/null || [ -n "$ZSH_EVAL_CONTEXT" ]; then
            for ((i=0; i<${#ALIAS_ENTRIES[@]}; i++)); do
                if [[ "${selected[$i]}" != "1" && ("${alias_status[$i]}" == "installed" || "${alias_status[$i]}" == "changed") ]]; then
                    local entry="${ALIAS_ENTRIES[$i]}"
                    local rest="${entry#*|}"
                    local alias_name="${rest%%|*}"
                    unalias "$alias_name" 2>/dev/null
                fi
            done
        fi
    fi

    echo ""
    echo "================================"
    local summary="완료:"
    [ "$added" -gt 0 ] && summary+=" ${GREEN}${added}개 추가${NC},"
    [ "$updated" -gt 0 ] && summary+=" ${CYAN}${updated}개 업데이트${NC},"
    [ "$removed" -gt 0 ] && summary+=" ${RED}${removed}개 제거${NC},"
    [ "$unchanged" -gt 0 ] && summary+=" ${DIM}${unchanged}개 동일${NC},"
    summary="${summary%,}"
    echo -e "$summary"

    if [ "$added" -gt 0 ] || [ "$updated" -gt 0 ] || [ "$removed" -gt 0 ]; then
        echo ""
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

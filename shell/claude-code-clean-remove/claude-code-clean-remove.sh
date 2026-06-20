#!/usr/bin/env bash
set -euo pipefail

# claude-code-clean-remove.sh
# Claude Code 네이티브 설치본을 깔끔하게 제거하는 스크립트
# 설치 방식: curl -fsSL https://claude.ai/install.sh | bash
#   (install.sh -> claude install 이 런처/버전 저장소를 ~/.local 아래에 설치)
#
# 모드
#   --binary  바이너리/런처/버전 저장소만 제거 (설정·로그인·플러그인 유지)
#   --full    위 + 설정·데이터·전역설정·Keychain 로그인까지 완전 삭제
#   (미지정)  대화형으로 선택

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# 제거 대상 경로
BIN_LINK="$HOME/.local/bin/claude"          # 런처(심볼릭 링크)
VERSION_STORE="$HOME/.local/share/claude"   # 버전 바이너리 저장소
CONFIG_DIR="$HOME/.claude"                  # 설정·프로젝트·플러그인·세션·기록
CONFIG_JSON="$HOME/.claude.json"            # 전역 설정·로그인 상태
CONFIG_JSON_BAK="$HOME/.claude.json.backup"
KEYCHAIN_SERVICE="Claude Code-credentials"  # macOS Keychain 로그인 인증정보

MODE=""            # binary | full (비어 있으면 대화형 선택)
ASSUME_YES=false
DRY_RUN=false

usage() {
    cat <<EOF
사용법: $(basename "$0") [옵션]

옵션:
  --binary       바이너리/런처/버전 저장소만 제거 (설정·로그인 유지)
  --full         설정·데이터·전역설정·Keychain 로그인까지 완전 삭제
  -y, --yes      확인 프롬프트 없이 진행
  -n, --dry-run  실제로 삭제하지 않고 대상만 출력
  -h, --help     도움말 출력

예시:
  ./$(basename "$0")                 # 대화형으로 모드 선택
  ./$(basename "$0") --binary        # 바이너리만 제거
  ./$(basename "$0") --full --yes    # 완전 삭제 (확인 생략)
  ./$(basename "$0") --full -n       # 완전 삭제 미리보기 (dry-run)
EOF
}

# ── 인자 파싱 ──
while [[ $# -gt 0 ]]; do
    case "$1" in
        --binary)     MODE="binary"; shift ;;
        --full)       MODE="full"; shift ;;
        -y|--yes)     ASSUME_YES=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -h|--help)    usage; exit 0 ;;
        *) echo -e "${RED}알 수 없는 옵션: $1${NC}" >&2; usage; exit 1 ;;
    esac
done

# ── 안전장치: Claude Code 세션 안에서 실행 방지 ──
if [ -n "${CLAUDECODE:-}" ] || [ -n "${CLAUDE_CODE:-}" ]; then
    echo -e "${RED}Claude Code 세션 안에서 실행 중인 것 같습니다.${NC}"
    echo -e "${YELLOW}실행 중인 자기 자신을 지우게 됩니다. 일반 터미널에서 실행하세요.${NC}"
    exit 1
fi

# ── 유틸 ──
human_size() {
    local p="$1"
    { [ -e "$p" ] || [ -L "$p" ]; } || { echo "-"; return; }
    du -sh "$p" 2>/dev/null | awk '{print $1}'
}

rm_path() {
    local p="$1"
    if [ ! -e "$p" ] && [ ! -L "$p" ]; then
        echo -e "  ${DIM}[skip]${NC}    $p ${DIM}(없음)${NC}"
        return
    fi
    local size; size=$(human_size "$p")
    if $DRY_RUN; then
        echo -e "  ${YELLOW}[dry]${NC}     rm -rf $p ${DIM}(${size})${NC}"
    else
        rm -rf "$p"
        echo -e "  ${GREEN}[removed]${NC} $p ${DIM}(${size})${NC}"
    fi
}

remove_keychain() {
    if [ "$(uname -s)" != "Darwin" ]; then
        return
    fi
    if ! security find-generic-password -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
        echo -e "  ${DIM}[skip]${NC}    Keychain '$KEYCHAIN_SERVICE' ${DIM}(없음)${NC}"
        return
    fi
    if $DRY_RUN; then
        echo -e "  ${YELLOW}[dry]${NC}     security delete-generic-password -s '$KEYCHAIN_SERVICE'"
    elif security delete-generic-password -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
        echo -e "  ${GREEN}[removed]${NC} Keychain '$KEYCHAIN_SERVICE'"
    else
        echo -e "  ${RED}[fail]${NC}    Keychain 삭제 실패 (수동: security delete-generic-password -s '$KEYCHAIN_SERVICE')"
    fi
}

choose_mode() {
    echo -e "${BOLD}Claude Code 제거 범위를 선택하세요${NC}" > /dev/tty
    echo "  1) 바이너리만 제거  (설정·로그인·플러그인 유지, 재설치 시 이어짐)" > /dev/tty
    echo "  2) 완전 삭제        (설정·데이터·로그인·플러그인까지 전부)" > /dev/tty
    printf "선택 (1/2, 기본 1): " > /dev/tty
    local ans; read -r ans < /dev/tty || ans=""
    case "$ans" in
        2) MODE="full" ;;
        *) MODE="binary" ;;
    esac
}

confirm() {
    $ASSUME_YES && return 0
    printf "${YELLOW}정말 진행할까요? (y/N): ${NC}" > /dev/tty
    local c; read -r c < /dev/tty || c=""
    [[ "$c" == "y" || "$c" == "Y" ]]
}

# ── 모드 결정 ──
if [ -z "$MODE" ]; then
    if [ -c /dev/tty ]; then
        choose_mode
    else
        MODE="binary"   # 비대화형이면 안전하게 바이너리만
    fi
fi

# ── 미리보기 ──
echo
echo -e "${BOLD}제거 대상${NC} ${DIM}(mode=${MODE})${NC}"
echo -e "  런처            : $BIN_LINK"
echo -e "  버전 저장소     : $VERSION_STORE ${DIM}($(human_size "$VERSION_STORE"))${NC}"
if [ "$MODE" = "full" ]; then
    echo -e "  설정·데이터     : $CONFIG_DIR ${DIM}($(human_size "$CONFIG_DIR"))${NC}"
    echo -e "  전역 설정       : $CONFIG_JSON, $CONFIG_JSON_BAK"
    [ "$(uname -s)" = "Darwin" ] && echo -e "  Keychain 로그인 : $KEYCHAIN_SERVICE"
fi
echo

$DRY_RUN && echo -e "${CYAN}(dry-run: 실제로 삭제하지 않습니다)${NC}"

if ! $DRY_RUN; then
    if ! confirm; then
        echo -e "${YELLOW}취소되었습니다.${NC}"
        exit 0
    fi
fi

# ── 실행 ──
echo
echo -e "${BOLD}진행${NC}"
rm_path "$BIN_LINK"
rm_path "$VERSION_STORE"
if [ "$MODE" = "full" ]; then
    rm_path "$CONFIG_DIR"
    rm_path "$CONFIG_JSON"
    rm_path "$CONFIG_JSON_BAK"
    remove_keychain
fi

hash -r 2>/dev/null || true

echo
$DRY_RUN && { echo -e "${CYAN}dry-run 종료 (변경 없음).${NC}"; exit 0; }
echo -e "${GREEN}완료.${NC}"

# ── 후속 안내 ──
if command -v claude >/dev/null 2>&1; then
    echo -e "${YELLOW}참고:${NC} 현재 셸에 'claude'가 아직 잡힙니다. 새 터미널을 열거나 ${BOLD}hash -r${NC} 후 ${BOLD}which claude${NC}로 확인하세요."
fi
echo -e "${DIM}PATH/alias 는 자동으로 건드리지 않았습니다:${NC}"
echo -e "${DIM}  - ~/.zshrc 의 export PATH=\"\$HOME/.local/bin:\$PATH\" 는 다른 도구도 쓰므로 직접 판단${NC}"
echo -e "${DIM}  - c / cx / c-yolo alias 는 setup-alias.sh --remove 로 제거${NC}"

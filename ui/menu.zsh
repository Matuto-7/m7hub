# ============================
# M7 HUB - Menu principal
# ============================

matuto_hub() {

    clear

    local WIDTH=$(tput cols)

    # calcula a largura visual real de uma string,
    # compensando emojis que ocupam 2 colunas na tela
    # mas contam como 1 caractere pro shell
    local -A M7_WIDE_CHARS=(
        "👤" 1 "🚀" 1
    )
    vwidth() {
        local str="$1"
        local extra=0
        local ch
        for ch in "${(@k)M7_WIDE_CHARS}"; do
            local tmp="$str"
            while [[ "$tmp" == *"$ch"* ]]; do
                extra=$((extra + 1))
                tmp="${tmp/$ch/}"
            done
        done
        echo $(( ${#str} + extra ))
    }

    local DATE=$(date '+%d/%m/%Y')
    local TIME=$(date '+%H:%M')
    local SESSIONS=$(command tmux ls 2>/dev/null | wc -l | tr -d ' ')
    [[ "$SESSIONS" -eq 0 ]] && SESSIONS="0"

    # degradê real: hora (claro) → data → sessões → versão (escuro)
    local INFO="(つ◉益◉)つ cybersecurty M7"
    local VERSION="🚀 M7 HUB v1.0"
    local POWER_ARROW=$'\ue0b0'
    local TIME_BG=$'\e[48;2;197;12;54m'
    local DATE_BG=$'\e[48;2;154;5;38m'
    local SESS_BG=$'\e[48;2;103;15;34m'
    local VERSION_BG=$'\e[48;2;60;8;20m'
    local TIME_FG=$'\e[38;2;197;12;54m'
    local DATE_FG=$'\e[38;2;154;5;38m'
    local SESS_FG=$'\e[38;2;103;15;34m'
    local VERSION_FG=$'\e[38;2;60;8;20m'

    printf "${RED}╭%s╮${R}\n" "$(printf '─%.0s' $(seq 1 $((WIDTH-2))))"

    # o "chip" do usuário usa o mesmo vermelho claro da hora
    printf "${RED}│${R}${TIME_BG}${CHIP_FG} %s ${R}${TIME_FG}%s${R}" "$INFO" "$POWER_ARROW"
    printf "\e[%dG${RED}│${R}\n" "$WIDTH"

    printf "${RED}├%s┤${R}\n" "$(printf '─%.0s' $(seq 1 $((WIDTH-2))))"

    printf "${RED}│${R}"
    local ICON_TIME=$'\uf017'
    local ICON_DATE=$'\uf073'
    local ICON_SESS=$'\uf108'

    printf "${TIME_BG}${CHIP_FG} ${ICON_TIME} %s " "$TIME"
    printf "${TIME_FG}${DATE_BG}${POWER_ARROW}${R}"
    printf "${DATE_BG}${CHIP_FG} ${ICON_DATE} %s " "$DATE"
    printf "${DATE_FG}${SESS_BG}${POWER_ARROW}${R}"
    printf "${SESS_BG}${CHIP_FG} ${ICON_SESS} %s Session(s) " "$SESSIONS"
    printf "${SESS_FG}${VERSION_BG}${POWER_ARROW}${R}"
    printf "${VERSION_BG}${CHIP_FG} %s " "$VERSION"
    printf "${R}${VERSION_FG}%s${R}" "$POWER_ARROW"
    printf "\e[%dG${RED}│${R}\n" "$WIDTH"

    printf "${RED}╰%s╯${R}\n\n" "$(printf '─%.0s' $(seq 1 $((WIDTH-2))))"

    local ICON_CREATE=$'\uf055'
    local ICON_ATTACH=$'\uf0c1'
    local ICON_RENAME=$'\uf040'
    local ICON_DELETE=$'\uf1f8'
    local ICON_EXIT=$'\uf08b'

    RESULT=$(
    printf "%s\n" \
    "${ICON_CREATE}  Create Session" \
    "${ICON_ATTACH}  Attach Session" \
    "${ICON_RENAME}  Rename Session" \
    "${ICON_DELETE}  Delete Session" \
    "${ICON_EXIT}  Exit" | fzf \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --cycle \
        --pointer="▶" \
        --marker="✓" \
        --prompt="🔍 Search : " \
        --border-label=" ↑↓ navegar • Enter selecionar • Esc voltar " \
        --border-label-pos=bottom \
        --expect=f5
    )
    KEY=$(head -n1 <<< "$RESULT")
    typeset -g M7_REPLY=$(tail -n1 <<< "$RESULT")

    if [[ "$KEY" == "f5" ]]; then
        return 2
    fi

    [[ -z "$M7_REPLY" ]] && return

    return
}

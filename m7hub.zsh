# ============================
# M7 HUB - Funções
# ============================
# Este arquivo é carregado pelo .zshrc via source.
# Todas as funções do hub vivem aqui, fora do .zshrc,
# pra manter o dotfile principal limpo.

check_deps() {

    # roda só uma vez por sessão de terminal
    [[ -n "$M7_DEPS_CHECKED" ]] && return
    export M7_DEPS_CHECKED=1

    local deps=(tmux fzf figlet lolcat fastfetch)
    local missing=()

    for cmd in "${deps[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    if (( ${#missing[@]} > 0 )); then
        echo "[M7 HUB] Aviso: dependência(s) faltando: ${missing[*]}"
        echo "[M7 HUB] Algumas funções podem não funcionar corretamente."
        echo
    fi
}

show_banner() {
    clear
    figlet -f slant "matuto-seven" | lolcat
    fastfetch -c ~/.config/fastfetch/config.json
    figlet -f Bloody "fsociety" | lolcat
    echo -e "\e[1;31mRUN, FIGHT, THINK-EVEN IF IT TAKES TIME-CELEBRATE,\nAND LIVE YOUR LIFE THE WAY YOU SEE FIT\nBEFORE YOUR TIME RUNS OUT.\nOR BEFORE YOUR MIND EXPLODES\e[0m" | lolcat
    echo ""
}

create_session() {

    clear

    echo "========================================"
    echo "         CRIAR NOVA SESSÃO"
    echo "========================================"
    echo

    local name=""
    local key

    printf "Nome da sessão: "

    while true; do
        read -k 1 key

        case "$key" in
            $'\e')
                echo
                return 2
                ;;
            $'\n'|$'\r')
                echo
                break
                ;;
            $'\x7f')
                if [[ -n "$name" ]]; then
                    name="${name%?}"
                    printf '\b \b'
                fi
                ;;
            *)
                name+="$key"
                printf "%s" "$key"
                ;;
        esac
    done

    [[ -z "$name" ]] && name="${PWD##*/}"

    if command tmux has-session -t "$name" 2>/dev/null; then
        echo
        echo "[ERRO] Já existe uma sessão chamada '$name'."
        echo
        read "?Pressione Enter para voltar..."
        return
    fi

    command tmux new-session -s "$name"

}

attach_session() {

    local session
    local fzf_status

    session=$(command tmux list-sessions -F "#{session_name}" 2>/dev/null |         fzf --bind='esc:abort')
    fzf_status=$?

    [[ $fzf_status -ne 0 || -z "$session" ]] && return 2

    command tmux attach-session -t "$session"

}

rename_session() {

    clear

    local old_name
    local new_name

    old_name=$(command tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --prompt="Sessão > ")

    [[ -z "$old_name" ]] && return

    echo
    read "?Novo nome: " new_name

    [[ -z "$new_name" ]] && return

    if command tmux has-session -t "$new_name" 2>/dev/null; then
        echo
        echo "[ERRO] Já existe uma sessão com esse nome."
        read "?Pressione Enter para voltar..."
        return
    fi

    command tmux rename-session -t "$old_name" "$new_name"

}

delete_session() {

    clear

    local session
    local confirm

    session=$(command tmux list-sessions -F "#{session_name}" 2>/dev/null | \
        fzf --prompt="Excluir sessão > ")

    [[ -z "$session" ]] && return

    echo
    read "?Excluir '$session'? [s/N]: " confirm

    case "$confirm" in
        s|S|y|Y)

            command tmux kill-session -t "$session"

            echo
            echo "[OK] Sessão removida."

            sleep 1
            ;;

        *)

            echo
            echo "Operação cancelada."

            sleep 1
            ;;

    esac

}

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

matuto_start() {

[[ -n "$TMUX" ]] && return

    check_deps

    while true; do

        matuto_hub

        if [[ $? -eq 2 ]]; then
            continue

        fi

        case "$M7_REPLY" in

            $'\uf055''  Create Session')
                create_session
                [[ $? -eq 2 ]] && continue
                ;;

            $'\uf0c1''  Attach Session')
                attach_session
                [[ $? -eq 2 ]] && continue
                ;;

            $'\uf040''  Rename Session')
                rename_session
                continue
                ;;

            $'\uf1f8''  Delete Session')
                delete_session
                continue
                ;;

            $'\uf08b''  Exit')
                exit
                ;;

            *)
                continue
                ;;

         esac

        export MATUTO_SHELL=1

        show_banner

        zsh

        unset MATUTO_SHELL

    done
}

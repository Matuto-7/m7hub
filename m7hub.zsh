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

    read "?Nome da sessão: " name

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

    session=$(command tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf)

    [[ -z "$session" ]] && return

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

    local DATE=$(date '+%d/%m/%Y')
    local TIME=$(date '+%H:%M')
    local SESSIONS=$(command tmux ls 2>/dev/null | wc -l | tr -d ' ')
    [[ "$SESSIONS" -eq 0 ]] && SESSIONS="0"

    local INFO="👤 $USER"
    local VERSION="🚀 M7 HUB v1.0"

    printf "${RED}┌%*s┐${R}\n" $((WIDTH-2)) "" | tr ' ' '─'

    local SPACES=$(( WIDTH - ${#INFO} - ${#VERSION} - 8 ))

    printf "${RED}│${R}%s%*s%s${RED}│${R}\n" \
    "$INFO" \
    "$SPACES" "" \
    "$VERSION"
    printf "${RED}├%*s┤${R}\n" $((WIDTH-2)) "" | tr ' ' '─'

    local LEFT="🕒 $TIME"
    local CENTER="📅 $DATE"
    local RIGHT="🖥 $SESSIONS Session(s)"

    local LEFT_PAD=2
    local CENTER_POS=$(( (WIDTH - ${#CENTER}) / 2 ))
    local RIGHT_POS=$(( WIDTH - ${#RIGHT} - 2 ))

    printf "%*s%s%*s%s%*s%s\n\n" \
    "$LEFT_PAD" "" \
    "$LEFT" \
    $((CENTER_POS - LEFT_PAD - ${#LEFT})) "" \
    "$CENTER" \
    $((RIGHT_POS - CENTER_POS - ${#CENTER})) "" \
    "$RIGHT"

    RESULT=$(
    printf "%s\n" \
    "Create Session" \
    "Attach Session" \
    "Rename Session" \
    "Delete Session" \
    "Exit" | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --cycle \
        --pointer="▶" \
        --marker="✓" \
        --prompt="🔍 Search : " \
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

            "Create Session")
                create_session
                ;;

            "Attach Session")
                attach_session
                ;;

            "Rename Session")
                rename_session
                continue
                ;;

            "Delete Session")
                delete_session
                continue
                ;;

            "Exit")
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

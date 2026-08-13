# ============================
# M7 HUB - Dependências
# ============================

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

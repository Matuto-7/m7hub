# ============================
# M7 HUB - Attach Sessions
# ============================

attach_session() {

    local session
    local fzf_status

    session=$(command tmux list-sessions -F "#{session_name}" 2>/dev/null | \
        fzf \
            --bind='esc:abort' \
            --prompt=$'\e[38;2;255;255;255m\e[48;2;197;12;54m M7 HUB \e[38;2;197;12;54m\e[48;2;8;6;12m\e[0m ' \
            --pointer='▸' \
            --marker='●' \
            --separator='─' \
            --scrollbar='│' \
            --gutter='│' \
            --border='rounded' \
            --border-label=' ATTACH.SESSIONS ' \
            --border-label-pos='2' \
            --padding='1,2' \
            --margin='1,2' \
            --no-multi \
            --preview='
                selected={}

                # M7 HUB preview — POSIX shell only.
                # Sem janelas: mostramos apenas a sessão e seus panes.
                RED="\033[38;5;203m"
                MAGENTA="\033[38;5;213m"
                WHITE="\033[38;5;255m"
                DIM="\033[38;5;245m"
                GREEN="\033[38;5;120m"
                RESET="\033[0m"

                printf "\n"
                printf "${RED}  ╭─ SESSION ─────────────────────────╮${RESET}\n"
                printf "${RED}  │${RESET}  ${WHITE}%s${RESET}\n" "$selected"
                printf "${RED}  ╰───────────────────────────────────╯${RESET}\n\n"

                printf "${MAGENTA}  PANES${RESET}\n"
                printf "${DIM}  ───────────────────────────────────${RESET}\n\n"

                count=0
                panes=$(command tmux list-panes -t "$selected" -F "#{pane_index}|#{pane_current_command}|#{pane_current_path}" 2>/dev/null)

                if [ -n "$panes" ]; then
                    while IFS="|" read -r pane_index pane_command pane_path; do
                        printf "${RED}  ├─${RESET} ${WHITE}PANE %s${RESET}\n" "$pane_index"
                        printf "${DIM}  │  shell${RESET}  ${WHITE}%s${RESET}\n" "$pane_command"
                        printf "${DIM}  │  path${RESET}   ${GREEN}%s${RESET}\n" "$pane_path"
                        printf "${DIM}  │${RESET}\n"
                        count=$((count + 1))
                    done <<EOF_PREVIEW
$panes
EOF_PREVIEW
                else
                    printf "${DIM}  │  Nenhum pane disponível.${RESET}\n"
                    printf "${DIM}  │${RESET}\n"
                fi

                printf "${RED}  └─${RESET} ${WHITE}%d pane(s)${RESET}\n" "$count"
                printf "\n"
                printf "${DIM}  ───────────────────────────────────${RESET}\n"
                printf "${DIM}  ↑ ↓${RESET} ${WHITE}Navegar${RESET}   ${DIM}ENTER${RESET} ${WHITE}Anexar${RESET}   ${DIM}ESC${RESET} ${WHITE}Voltar${RESET}\n"
                printf "\n"
            ' \
            --preview-window='right:38%:wrap:border-left' \
            --color='fg:#d8dee9,bg:#08060c,hl:#ff8fa8,fg+:#ffffff,bg+:#52091f,hl+:#ff7b9b,pointer:#ff1744,marker:#ff4d6d,spinner:#ff6b8a,border:#b5163d,info:#d13a67,prompt:#ffffff,header:#ff6b8a,gutter:#4d1b2d,separator:#6f1a31,scrollbar:#ff315f')

    fzf_status=$?

    [[ $fzf_status -ne 0 || -z "$session" ]] && return 2

    command tmux attach-session -t "$session"

}

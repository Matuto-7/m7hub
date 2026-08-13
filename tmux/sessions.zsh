# ============================
# M7 HUB - Sessões tmux
# ============================

create_session() {

    clear

    echo "========================================"
    echo "         CRIAR NOVA SESSÃO"
    echo "========================================"
    echo

    local name=""
    local key
    local seq
    local cursor=0

    printf "Nome da sessão: "

    while true; do
        read -sk 1 key

        case "$key" in
            $'\e')
                # ESC sozinho = cancelar.
                # ESC [ C/D = setas direita/esquerda.
                read -sk 1 -t 0.05 seq || {
                    echo
                    return 2
                }

                if [[ "$seq" == "[" ]]; then
                    read -sk 1 -t 0.05 seq || continue

                    case "$seq" in
                        C)  # seta direita
                            (( cursor < ${#name} )) && (( cursor++ ))
                            ;;
                        D)  # seta esquerda
                            (( cursor > 0 )) && (( cursor-- ))
                            ;;
                        H)  # Home
                            cursor=0
                            ;;
                        F)  # End
                            cursor=${#name}
                            ;;
                        *)
                            ;;
                    esac

                    # Redesenha a linha e reposiciona o cursor.
                    printf "\rNome da sessão: %s\033[K" "$name"
                    if (( cursor < ${#name} )); then
                        printf "\033[%dD" $(( ${#name} - cursor ))
                    fi
                else
                    # ESC não seguido de uma sequência de seta = cancelar.
                    echo
                    return 2
                fi
                ;;

            $'\n'|$'\r')
                echo
                break
                ;;

            $'\x7f'|$'\x08')
                # Backspace: remove o caractere à esquerda do cursor.
                if (( cursor > 0 )); then
                    if (( cursor == ${#name} )); then
                        name="${name[1,$((cursor-1))]}"
                    else
                        name="${name[1,$((cursor-1))]}${name[$((cursor+1)),-1]}"
                    fi

                    (( cursor-- ))

                    printf "\rNome da sessão: %s\033[K" "$name"
                    if (( cursor < ${#name} )); then
                        printf "\033[%dD" $(( ${#name} - cursor ))
                    fi
                fi
                ;;

            *)
                # Insere o caractere na posição atual do cursor.
                if (( cursor == 0 )); then
                    name="$key$name"
                elif (( cursor >= ${#name} )); then
                    name="$name$key"
                else
                    name="${name[1,$cursor]}$key${name[$((cursor+1)),-1]}"
                fi

                (( cursor++ ))

                printf "\rNome da sessão: %s\033[K" "$name"
                if (( cursor < ${#name} )); then
                    printf "\033[%dD" $(( ${#name} - cursor ))
                fi
                ;;
        esac
    done

    [[ -z "$name" ]] && name="${PWD##*/}"

    if command tmux has-session -t "$name" 2>/dev/null; then
        echo
        echo "[ERRO] Já existe uma sessão chamada '$name'."
        echo
        read "?Pressione Enter para voltar..."
        return 2
    fi

    command tmux new-session -s "$name"

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

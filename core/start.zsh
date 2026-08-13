# ============================
# M7 HUB - Inicialização
# ============================

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

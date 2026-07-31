# 👾 M7 HUB

[![Shell](https://img.shields.io/badge/GNU-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Kali Linux](https://img.shields.io/badge/Kali%20Linux-557C94?style=for-the-badge&logo=kali-linux&logoColor=white)](https://www.kali.org/)
[![tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white)](https://github.com/tmux/tmux)
[![Status](https://img.shields.io/badge/status-em%20constru%C3%A7%C3%A3o-red?style=for-the-badge)]()

> *"Se vou usar tmux como túnel pro terminal, não vou usar cru feito todo mundo."*

Um hub pessoal de gerenciamento de sessões `tmux`, construído em Zsh. Sobe sozinho assim que o terminal abre, te dá controle total das sessões por um menu interativo, sem precisar decorar comando nenhum.

Feito 100% pra uso próprio, do meu jeito. Ainda em sprint diário — o que você vê aqui é o estado atual, não a versão final.

---

## 𝕺 𝖖𝖚𝖊 é 𝖎𝖘𝖘𝖔?

Peguei a ideia clássica de tmux como túnel pro terminal principal e não me contentei em usar do jeito básico. Construí uma camada de controle por cima: um menu que aparece automaticamente, onde eu crio, anexo, renomeio e deleto sessões sem sair do fluxo visual.

<p align="center">
  <img src="assets/hub-menu.png" alt="Menu principal do M7 HUB" width="800">
</p>

<p align="center"><i>Menu principal — navegação via <code>fzf</code>, com header dinâmico mostrando usuário, hora, data e sessões ativas em tempo real.</i></p>

---

## ⚙️ 𝕮𝖔𝖒𝖔 𝖋𝖚𝖓𝖈𝖎𝖔𝖓𝖆 𝖓𝖆 𝖕𝖗á𝖙𝖎𝖈𝖆

### Criando uma sessão

<p align="center">
  <img src="assets/create-session.png" alt="Tela de criação de sessão" width="800">
</p>

Escolhendo **Create Session** no menu, você cai numa tela simples pra nomear a sessão nova. Se deixar em branco, ele usa o nome da pasta atual como padrão.

### Abertura com identidade

<p align="center">
  <img src="assets/banner-fastfetch.png" alt="Banner de abertura com fastfetch" width="800">
</p>

Sempre que você entra num shell de trabalho (depois de criar/anexar uma sessão), o hub dispara um banner de abertura com `figlet` + `lolcat` + `fastfetch` — informações do sistema, tema visual, tudo junto.

### Voltando ao fluxo

<p align="center">
  <img src="assets/matuto-shell.png" alt="Shell de trabalho após o banner" width="800">
</p>

Depois do banner, você cai num shell normal pra trabalhar. Ao sair dele (`exit`), o controle volta automaticamente pro menu do hub — sem precisar reabrir nada, sem perder o fluxo.

---

## 📋 𝕮𝖔𝖓𝖈𝖊𝖕çã𝖔 (PRD)

### Problema
Trabalhar com múltiplas sessões `tmux` exige decorar sintaxe de comando (`tmux new -s`, `tmux attach -t`, `tmux rename-session`, etc). Isso cria fricção no dia a dia de quem abre e fecha terminais o tempo todo, e não escala bem quando o número de sessões ativas cresce.

### Objetivo
Eliminar essa fricção com uma camada de controle visual sobre o `tmux`, que:
- Apareça automaticamente ao abrir o terminal, sem exigir comando manual
- Permita executar as operações mais comuns (criar, anexar, renomear, deletar) via seleção, não digitação
- Mantenha o usuário informado do estado atual (quantas sessões ativas, hora, data) sem precisar consultar `tmux ls`
- Devolva o controle ao próprio hub depois de cada operação, mantendo o fluxo contínuo

### Público-alvo
Uso pessoal — desenvolvido para o próprio fluxo de trabalho do autor, sem intenção inicial de distribuição. Prioriza personalização e liberdade de decisão de design em vez de generalização para terceiros.

### Requisitos funcionais
| ID | Requisito |
|----|-----------|
| RF01 | O hub deve subir automaticamente em todo shell interativo, exceto dentro de uma sessão `tmux` já ativa |
| RF02 | O usuário deve conseguir criar uma sessão nomeada, com fallback para o nome da pasta atual |
| RF03 | O usuário deve conseguir anexar a uma sessão existente via seleção em lista |
| RF04 | O usuário deve conseguir renomear uma sessão existente, com validação de nome duplicado |
| RF05 | O usuário deve conseguir deletar uma sessão, com confirmação explícita antes da ação |
| RF06 | O menu deve exibir contagem de sessões ativas, atualizada a cada abertura |
| RF07 | O menu deve suportar atualização manual (refresh) sem fechar e reabrir |

### Requisitos não funcionais
| ID | Requisito |
|----|-----------|
| RNF01 | A lógica do hub deve viver fora do `.zshrc`, isolada em arquivo próprio |
| RNF02 | O layout deve se adaptar dinamicamente à largura do terminal |
| RNF03 | Cores e identidade visual devem ser configuráveis via tema externo |
| RNF04 | Nenhuma ação destrutiva (deletar sessão) deve ocorrer sem confirmação do usuário |

---

## 🔩 𝕰𝖓𝖌𝖊𝖓𝖍𝖆𝖗𝖎𝖆

Cada função do `m7hub.zsh` cobre uma responsabilidade específica. Aqui está o que cada uma faz, com o trecho de código correspondente.

### `show_banner` — identidade visual de abertura

Dispara o banner com `figlet` + `lolcat` + `fastfetch` toda vez que um shell de trabalho é aberto.

```bash
show_banner() {
    clear
    figlet -f slant "matuto-seven" | lolcat
    fastfetch -c ~/.config/fastfetch/config.json
    figlet -f Bloody "fsociety" | lolcat
    echo -e "..." | lolcat
    echo ""
}
```

### `create_session` — criação de sessão

Pede um nome, cai pro nome da pasta atual se vier vazio, e bloqueia criação duplicada.

```bash
create_session() {
    read "?Nome da sessão: " name
    [[ -z "$name" ]] && name="${PWD##*/}"

    if command tmux has-session -t "$name" 2>/dev/null; then
        echo "[ERRO] Já existe uma sessão chamada '$name'."
        return
    fi

    command tmux new-session -s "$name"
}
```

### `attach_session` — seleção e anexação

Lista as sessões ativas via `tmux ls`, filtra o nome com `cut`, e entrega pro `fzf` escolher.

```bash
attach_session() {
    local session
    session=$(command tmux ls 2>/dev/null | cut -d: -f1 | fzf)
    [[ -z "$session" ]] && return
    command tmux attach-session -t "$session"
}
```

### `rename_session` — renomeação com validação

Mesma lógica de seleção via `fzf`, com checagem de nome duplicado antes de aplicar.

```bash
rename_session() {
    old_name=$(command tmux ls 2>/dev/null | cut -d: -f1 | fzf --prompt="Sessão > ")
    [[ -z "$old_name" ]] && return

    read "?Novo nome: " new_name
    [[ -z "$new_name" ]] && return

    if command tmux has-session -t "$new_name" 2>/dev/null; then
        echo "[ERRO] Já existe uma sessão com esse nome."
        return
    fi

    command tmux rename-session -t "$old_name" "$new_name"
}
```

### `delete_session` — remoção com confirmação

Nenhuma sessão é deletada sem o usuário confirmar explicitamente (`s/S/y/Y`).

```bash
delete_session() {
    session=$(command tmux ls 2>/dev/null | cut -d: -f1 | fzf --prompt="Excluir sessão > ")
    [[ -z "$session" ]] && return

    read "?Excluir '$session'? [s/N]: " confirm
    case "$confirm" in
        s|S|y|Y) command tmux kill-session -t "$session" ;;
        *) echo "Operação cancelada." ;;
    esac
}
```

### `matuto_hub` — renderização do menu

Monta o header dinâmico (usuário, hora, data, contagem de sessões) recalculando a largura do terminal a cada chamada, e entrega as opções pro `fzf`.

```bash
matuto_hub() {
    local WIDTH=$(tput cols)
    local SESSIONS=$(command tmux ls 2>/dev/null | wc -l | tr -d ' ')

    RESULT=$(printf "%s\n" "Create Session" "Attach Session" \
        "Rename Session" "Delete Session" "Exit" | fzf --expect=f5)

    KEY=$(head -n1 <<< "$RESULT")
    typeset -g M7_REPLY=$(tail -n1 <<< "$RESULT")

    [[ "$KEY" == "f5" ]] && return 2
}
```

### `matuto_start` — o loop de controle

O coração do hub: mantém o menu em `while true`, direciona pra função certa conforme a escolha, e devolve o controle ao próprio loop depois que o usuário termina de trabalhar.

```bash
matuto_start() {
    [[ -n "$TMUX" ]] && return

    while true; do
        matuto_hub
        [[ $? -eq 2 ]] && continue

        case "$M7_REPLY" in
            "Create Session") create_session ;;
            "Attach Session") attach_session ;;
            "Rename Session") rename_session; continue ;;
            "Delete Session") delete_session; continue ;;
            "Exit") exit ;;
            *) continue ;;
        esac

        export MATUTO_SHELL=1
        show_banner
        zsh
        unset MATUTO_SHELL
    done
}
```

---

## 📅 Diário de bordo

Esse projeto é atualizado com frequência — o registro abaixo acompanha a evolução real, não só o resultado final.

| Data | O que mudou |
|------|-------------|
| 29/07/2026 | Primeira versão funcional: menu, CRUD de sessões, banner de abertura |
| 30/07/2026 | Separação da lógica do hub para fora do `.zshrc`, isolada em `m7hub.zsh` |
| 30/07/2026 | Correção de escopo de variável (`REPLY` → `M7_REPLY`) para evitar conflito com `read` |
| 30/07/2026 | Revisão de arquitetura: identificado e revertido uso de `exec zsh` que quebrava o retorno automático ao menu |

> Esse quadro vai crescendo junto com o projeto — cada sprint novo entra aqui.

---

## 🧩 Funcionalidades

- **Menu interativo** via `fzf`, com busca, navegação por teclado e refresh dedicado (`F5`) sem precisar fechar e reabrir
- **Header dinâmico**: usuário, hora, data e contagem de sessões ativas, recalculado toda vez que o menu abre
- **Layout responsivo**: se adapta à largura do terminal em tempo real (`tput cols`)
- **CRUD completo de sessões tmux**: criar, anexar, renomear, deletar — com confirmação antes de deletar
- **Sistema de temas**: cores carregadas de um arquivo de configuração separado
- **Loop de controle**: sai de uma sessão → volta pro hub automaticamente, sem interrupção do fluxo

---

## 🏗️ Arquitetura

O hub vive isolado do `.zshrc` — o dotfile principal só faz um `source` num arquivo próprio, mantendo a config do terminal limpa e a aplicação isolada:

```
~/.config/m7hub/
├── m7hub.zsh          # todas as funções do hub
├── config             # variáveis de configuração (tema ativo, etc)
└── themes/
    └── *.conf          # arquivos de cor por tema
```

No `.zshrc`, fica só isso:

```bash
[[ -f "$HOME/.config/m7hub/config" ]] && \
    source "$HOME/.config/m7hub/config"

[[ -f "$HOME/.config/m7hub/themes/${M7_THEME}.conf" ]] && \
    source "$HOME/.config/m7hub/themes/${M7_THEME}.conf"

[[ -f "$HOME/.config/m7hub/m7hub.zsh" ]] && \
    source "$HOME/.config/m7hub/m7hub.zsh"

if [[ $- == *i* && -z "$MATUTO_SHELL" ]]; then
    matuto_start
fi
```

---

## 📡 No radar (o que ainda vem por aí)

- [ ] Checagem automática de dependências (`fzf`, `tmux`, `figlet`, `lolcat`, `fastfetch`) antes de subir o hub
- [ ] Parsing de nomes de sessão mais robusto (`tmux list-sessions -F` em vez de `cut`)
- [ ] Mais temas visuais
- [ ] Possível `install.sh` no futuro — sem pressa, isso aqui nasceu pra ser meu, não produto

---

## 🛠️ Stack

Zsh · tmux · fzf · figlet · lolcat · fastfetch

---

<p align="center"><i>Feito por <a href="https://github.com/Matuto-7">Matuto-7</a> — código, estratégia e um terminal que não é igual ao de ninguém.</i></p>

# M7 HUB — Modularização v1

A lógica do HUB foi separada por responsabilidade sem alterar o comportamento das funções.

```text
m7hub.zsh
├── core/
│   ├── deps.zsh       # check_deps
│   └── start.zsh      # matuto_start
├── tmux/
│   └── sessions.zsh   # create/rename/delete
└── ui/
    ├── banner.zsh     # show_banner
    ├── attach.zsh     # attach_session + preview
    └── menu.zsh       # matuto_hub
```

O `m7hub.zsh` passa a ser somente o loader dos módulos.

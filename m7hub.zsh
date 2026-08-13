# ============================
# M7 HUB - Loader
# ============================
# Ponto de entrada do M7 HUB.
# A lógica é dividida por responsabilidade para manter o projeto modular.

M7_ROOT="${${(%):-%x}:A:h}"

source "$M7_ROOT/core/deps.zsh"
source "$M7_ROOT/ui/banner.zsh"
source "$M7_ROOT/tmux/sessions.zsh"
source "$M7_ROOT/ui/attach.zsh"
source "$M7_ROOT/ui/menu.zsh"
source "$M7_ROOT/core/start.zsh"

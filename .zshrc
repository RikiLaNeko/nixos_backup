typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# ⚡ Instant prompt pour Powerlevel10k (doit être en haut)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if ! (( $+functions[instant_prompt_done_callback] )); then
  functions[instant_prompt_done_callback]=${functions[instant_prompt_done_callback]:-instant_prompt_done_callback}
fi


# 📌 Homebrew (si sur macOS)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 🔹 Zinit (Gestion des plugins Zsh)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# 🔥 Thème Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# 🔧 Plugins Zsh
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-history-substring-search
zinit light hlissner/zsh-autopair
zinit light chrissicool/zsh-256color
zinit light MichaelAquilina/zsh-you-should-use
zinit light romkatv/zsh-defer

# 🔹 Plugins OMZ (Oh My Zsh)
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::gradle
zinit snippet OMZP::mvn
zinit snippet OMZP::systemd
zinit snippet OMZP::tmux
zinit snippet OMZL::functions.zsh
zinit snippet OMZP::web-search

# 🚀 Chargement des complétions (accélération)
autoload -Uz compinit
if [[ -z "$ZSH_COMPDUMP" ]]; then
  ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
fi
compinit -d "$ZSH_COMPDUMP"

# ⚡ Chargement des plugins Zinit en différé
zinit cdreplay -q

# 🎨 Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 🏆 Historique optimisé
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt extended_history

# 🏹 Keybindings (navigation dans l'historique avec flèches)
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# 🔍 Completions avancées
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# 🚀 Aliases améliorés
alias ls='exa --icons --color=auto'
alias vim='nvim'
alias c='clear'
alias h='history'
alias e='exit'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias man='tldr'
alias top='btop'
alias systeminfo='fastfetch'
alias history="atuin history list"
alias code="codium ."

# ❄️ Aliases spésifique a NixOS
alias nix-fmt="nixpkgs-fmt"
alias nix-update="nix-channel --update && nix-env -u '*'"
alias nix-gc="nix-collect-garbage -d"

# 🚀 Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# 📌 PATH amélioré (groupé pour éviter les répétitions)
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:/home/dedsec/.bun/bin:$PATH"
export PATH="/nix/store/rq7gna8i0sybj3knxh4zn6hysbsy9xjy-ghostty-1.0.1/bin:$PATH"

# 📌 PKG_CONFIG_PATH amélioré
export PKG_CONFIG_PATH="
  ~/.local/pkgconfig:
  /run/current-system/sw/lib/pkgconfig:
  /nix/store/5a1i753fvf4124d0z96z1gdny54a5pk5-alsa-lib-1.2.12-dev/lib/pkgconfig:
  /nix/store/vvjw3qra3bq198alp4wfbx52g46hvh0b-systemd-257.2-dev/lib/pkgconfig:
  /nix/store/73cqf7hqf4mwc3pbmgkpyl473bahn3s4-openssl-3.3.2-dev/lib/pkgconfig:
  $PKG_CONFIG_PATH"

# 📌 LDFLAGS amélioré
export EDITOR=nvim
export VISUAL=nvim

#⚡ Angular & Kubernetes autocompletion
source <(ng completion script)
source <(kubectl completion zsh)

# 🎯 Ajout du fpath pour les complétions personnalisées
fpath=($HOME/.zsh_completions $fpath)

export ATUIN_CONFIG="$HOME/.config/atuin/config.toml"
eval "$(atuin init zsh)"

exec  /home/dedsec/Code/Bash/fortune_cowsay.sh &!



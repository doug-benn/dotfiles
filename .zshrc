### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Plugins
# Load fzf-tab BEFORE compinit
zinit light Aloxaf/fzf-tab
# should come after fzf-tab
autoload -U compinit; compinit

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
zinit light zsh-users/zsh-completions

# Environment variables
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# fzf configuration - match fish
export FZF_DEFAULT_OPTS='--cycle --layout=default --height=90% --preview-window=wrap --marker="*"'
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window up:3:wrap"



# Ensure mise works (disable command hashing)
setopt NO_HASH_CMDS
setopt NO_HASH_DIRS

export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=32768
SAVEHIST=32768
setopt APPEND_HISTORY           # Append to history file
setopt SHARE_HISTORY            # Share history across sessions
setopt HIST_IGNORE_DUPS         # Ignore duplicate commands
setopt HIST_IGNORE_SPACE        # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS       # Remove unnecessary blanks

# Completion configuration
setopt COMPLETE_IN_WORD         # Complete from both ends of word
setopt ALWAYS_TO_END            # Move cursor to end after completion
setopt AUTO_MENU                # Show completion menu on tab
setopt AUTO_LIST                # List choices on ambiguous completion
setopt NO_MENU_COMPLETE         # Don't autoselect first completion

# Directory navigation
setopt AUTO_CD                  # cd by typing directory name
setopt AUTO_PUSHD               # Push directories onto stack
setopt PUSHD_IGNORE_DUPS        # Don't push duplicates
setopt PUSHD_MINUS              # Exchange + and - for pushd

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completion menu navigation
zstyle ':completion:*:*:*:*:*' menu select

# Don't complete hidden files unless explicitly requested
zstyle ':completion:*' special-dirs false

zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Tool initialization with safety checks
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# fzf integration
if command -v fzf &> /dev/null; then
  # Load fzf keybindings and completion
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi

  # fzf file/directory search widget (Ctrl+Alt+F)
  fzf-file-widget() {
    local fd_cmd=$(command -v fdfind || command -v fd || echo "fd")
    local current_token="${LBUFFER##* }"
    # Remove leading/trailing quotes and expand variables, but don't add -- if empty
    local expanded_token=""
    if [[ -n "$current_token" ]]; then
      expanded_token=$(eval echo "$current_token" 2>/dev/null || echo "$current_token")
    fi
    
    local selected
    if [[ "$expanded_token" == */ ]] && [[ -d "$expanded_token" ]]; then
      # Search within specific directory
      selected=$($fd_cmd --color=always --base-directory="$expanded_token" 2>/dev/null | \
        fzf --multi --ansi --prompt="Directory $expanded_token> " \
          --preview="[[ -d $expanded_token{} ]] && ls -lah $expanded_token{} || bat --color=always --style=numbers $expanded_token{} 2>/dev/null || cat $expanded_token{}")
      [[ -n "$selected" ]] && selected="${expanded_token}${selected}"
    else
      # Search from current directory
      selected=$($fd_cmd --color=always 2>/dev/null | \
        fzf --multi --ansi --prompt="Directory> " --query="$expanded_token" \
          --preview="[[ -d {} ]] && ls -lah {} || bat --color=always --style=numbers {} 2>/dev/null || cat {}")
    fi

    if [[ -n "$selected" ]]; then
      # Escape spaces and special characters
      selected=$(printf '%q' "$selected")
      LBUFFER="${LBUFFER%$current_token}${selected} "
    fi
    zle reset-prompt
  }
  zle -N fzf-file-widget
  bindkey '^[^F' fzf-file-widget  # Ctrl+Alt+F

  # fzf git log search widget (Ctrl+Alt+L)
  fzf-git-log-widget() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
      echo "Not in a git repository." >&2
      return 1
    fi

    local selected
    selected=$(git log --no-show-signature --color=always \
      --format='%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)' \
      --date=short | \
      fzf --ansi --multi --scheme=history --prompt="Git Log> " \
        --preview='git show --color=always --stat --patch {1}' \
        --preview-window=right:50%:wrap | \
      awk '{print $1}' | \
      xargs -I {} git rev-parse {} 2>/dev/null | \
      tr '\n' ' ')

    if [[ -n "$selected" ]]; then
      LBUFFER="${LBUFFER}${selected}"
    fi
    zle reset-prompt
  }
  zle -N fzf-git-log-widget
  bindkey '^[^L' fzf-git-log-widget  # Ctrl+Alt+L

  # fzf variables search widget (Ctrl+V)
  fzf-variables-widget() {
    local current_token="${LBUFFER##* }"
    local cleaned_token="${current_token#\$}"
    
    local selected
    selected=$(typeset -p | awk '{print $1, $2}' | sort -u | awk '{print $2}' | \
      fzf --multi --prompt="Variables> " --preview-window=wrap \
        --preview='echo {} && typeset -p {} 2>/dev/null || echo "No details available"' \
        --query="$cleaned_token")

    if [[ -n "$selected" ]]; then
      # If current token starts with $, keep the $
      if [[ "$current_token" == \$* ]]; then
        selected="\$${selected}"
      fi
      # Replace the current token
      LBUFFER="${LBUFFER%$current_token}${selected} "
    fi
    zle reset-prompt
  }
  zle -N fzf-variables-widget
  bindkey '^V' fzf-variables-widget  # Ctrl+V
fi

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias d='docker'
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

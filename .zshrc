# ----- Znap plugin manager -----
ZNAP_DIR="${HOME}/.zsh/znap"
if [[ ! -f "${ZNAP_DIR}/znap.zsh" ]]; then
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "${ZNAP_DIR}"
fi
source "${ZNAP_DIR}/znap.zsh"

# Plugins
znap source zsh-users/zsh-completions          # extra completions (~700 definitions)
znap source Aloxaf/fzf-tab                     # fzf-powered Tab menu (replaces menu-complete)
znap source zsh-users/zsh-autosuggestions      # ghost-text history suggestions
znap source zsh-users/zsh-syntax-highlighting  # real-time command colorisation (must be last)

# Autosuggestion config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Accept autosuggestion with → or End
bindkey '^[[C' autosuggest-accept   # Right arrow
bindkey '^[OF' autosuggest-accept   # End key


# ----- Tools -----
if [[ -o interactive ]] && [[ ${TERM:-} != "dumb" ]] && command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null; then
  # fzf shell integration (zsh-native, replaces sourcing bash scripts)
  source <(fzf --zsh)
fi


# ----- Settings and Keybinds -----
# Use emacs-style key bindings (default; change to -v for vi mode)
bindkey -e

# History
setopt APPEND_HISTORY          # Equivalent to shopt -s histappend
setopt HIST_IGNORE_DUPS        # Ignore consecutive duplicate commands
setopt HIST_IGNORE_SPACE       # Ignore commands starting with a space
setopt SHARE_HISTORY           # Share history across sessions
setopt HIST_EXPIRE_DUPS_FIRST  # drop duplicates before unique commands when history fills
HISTSIZE=32768
SAVEHIST=${HISTSIZE}
HISTFILE="${HOME}/.zsh_history"

# Autocompletion
# zsh-completions: fpath registered by znap automatically
autoload -Uz compinit && compinit

# fzf-tab: show file previews in completion menu
zstyle ':fzf-tab:complete:*' fzf-preview 'bat --style=numbers --color=always $realpath 2>/dev/null || ls -lh $realpath 2>/dev/null'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -lh --color=always $realpath'

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Show completion menu when there are 2+ candidates
zstyle ':completion:*' menu select

# Show file type indicators (like ls -F)
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Group completions by category with headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Ask before listing more than 200 candidates
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

# Immediately add trailing slash when completing symlinks to directories
setopt AUTO_PARAM_SLASH

# Do not complete hidden files unless pattern starts with a dot
setopt GLOB_DOTS
# Override: don't match hidden by default with normal globs
# (comment the above GLOB_DOTS if you prefer hidden files NOT to appear)

# Arrow key history search matching typed prefix
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # Up arrow
bindkey '^[[B' down-line-or-beginning-search  # Down arrow
# Right arrow: autosuggest-accept (bound in znap block above)
# Forward-char (move cursor right within line): Ctrl+Right
bindkey '^[[1;5C' forward-char
bindkey '^[[D'    backward-char               # Left arrow

# Tab/Shift+Tab: fzf-tab hijacks ^I automatically; this makes Shift+Tab go backward
bindkey '^I'   complete-word   # triggers fzf-tab
bindkey '^[[Z' reverse-menu-complete

# Meta / UTF-8 input (zsh handles this natively; no readline flags needed)
setopt COMBINING_CHARS


# ----- ENV -----
export SUDO_EDITOR="${EDITOR}"
export BAT_THEME=ansi

# Color man pages with bat
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export PATH="${PATH}:${HOME}/.local/bin"


# ----- Aliases -----
# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='${EDITOR} "$(ff)"'

# scp a file chosen via fzf to a remote destination
sff() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: sff <destination> (e.g. sff host:/tmp/)"; return 1
  fi
  local file
  file=$(fd --type f | ff) && [[ -n "$file" ]] && scp "$file" "$1"
}

if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
      printf "\U000F17A9 "
      pwd
    fi
  }
fi

open() (
  xdg-open "$@" >/dev/null 2>&1 &
)

# Directory traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

n() {
  if [[ $# -eq 0 ]]; then
    command nvim .
  else
    command nvim "$@"
  fi
}

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# ----- Tmux auto-start -----
if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
  exec tmux new-session -A -s main
fi
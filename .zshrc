# zsh configuration          
# https://github.com/c0mpile/ 

################################
# Powerlevel10k instant prompt #
################################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#########################
# Environment variables #
#########################
PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH" 
ZDOTDIR="$HOME/.config/zsh"
ZPLUGINDIR="${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}"
ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${ZDOTDIR:-$HOME/.config/zsh}/cache}"
EDITOR="nvim"
VISUAL="nvim"
HISTSIZE='5000'
HISTFILE="$HOME/.zsh_history"
SAVEHIST="$HISTSIZE"
HISTDUP="erase"

#################
# Bootstrapping #
#################
# Create necessary directories
if [[ ! -d "$ZDOTDIR" ]]; then
  print -r "Creating configuration directory: $ZDOTDIR"
  mkdir -p "$ZDOTDIR" || {
    print -ru2 "Error creating configuration directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZPLUGINDIR" ]]; then
  print -r "Creating plugin directory: $ZPLUGINDIR"
  mkdir -p "$ZPLUGINDIR" || {
    print -ru2 "Error creating plugin directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  print -r "Creating cache directory: $ZSH_CACHE_DIR"
  mkdir -p "$ZSH_CACHE_DIR" || {
    print -ru2 "Error creating cache directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZSH_CACHE_DIR/completions" ]]; then
  print -r "Creating completion cache directory: $ZSH_CACHE_DIR/completions"
  mkdir -p "$ZSH_CACHE_DIR/completions" || {
    print -ru2 "Error creating completion cache directory: $?"
    return 1
  }
fi

# Check if chezmoi is in PATH
if ! command -v chezmoi &> /dev/null; then
  print -r "chezmoi not found in PATH. Attempting installation..."

  # Create .local/bin if it doesn't exist
  mkdir -p "$HOME/.local/bin"

  print -r "Installing chezmoi using get.chezmoi.io..."

  # Install chezmoi with the provided command
  if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" &> /dev/null; then
    print -r "chezmoi installed successfully to $HOME/.local/bin"
  else
    print -ru2 "Error installing chezmoi."
    return 1
  fi
fi

# Verify chezmoi installation after potential installation
if ! command -v chezmoi &> /dev/null; then
  print -ru2 "chezmoi installation failed. Not found in PATH after attempt."
  return 1
fi

# Function to generate completions, handling potential errors
generate_completion() {
  local command="$1"
  local output_file="$2"
  local completion_command="$3"

  if [[ ! -f "$output_file" ]]; then
    print -r "Generating completions for $command..."
    eval "$completion_command" > "$output_file" 2>/dev/null || { # Redirect stderr to avoid clutter
      print -ru2 "Error generating completions for $command: $?"
      return 1
    }
  fi
}

# Generate completions
generate_completion "gh" "$ZSH_CACHE_DIR/completions/_gh" "gh completion -s zsh"
generate_completion "docker" "$ZSH_CACHE_DIR/completions/_docker" "docker completion zsh"
generate_completion "docker-compose" "$ZSH_CACHE_DIR/completions/_docker-compose" "curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose > $ZSH_CACHE_DIR/completions/_docker-compose"
generate_completion "podman" "$ZSH_CACHE_DIR/completions/_podman" "podman completion zsh"
generate_completion "rust" "$ZSH_CACHE_DIR/completions/_rust" "rustup completions zsh"
generate_completion "cargo" "$ZSH_CACHE_DIR/completions/_cargo" "rustup completions zsh cargo"
generate_completion "python" "$ZSH_CACHE_DIR/completions/_python" "python -m pip completion --zsh"
generate_completion "chezmoi" "$ZSH_CACHE_DIR/completions/_chezmoi" "chezmoi completion zsh"

#############
# Functions #
#############
# clone plugins
function plugin-clone {
  local repo plugdir initfile initfiles=()
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules \
        https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) && ln -sf $initfiles[1] $initfile
    fi
  done
}

# source plugins
function plugin-source {
  local plugdir
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for plugdir in $@; do
    [[ $plugdir = /* ]] || plugdir=$ZPLUGINDIR/$plugdir
    fpath+=$plugdir
    local initfile=$plugdir/${plugdir:t}.plugin.zsh
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

# update plugins
function plugin-update {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

###########
# Plugins #
###########
# external plugin repos
repos=(
  romkatv/powerlevel10k
  ohmyzsh/ohmyzsh
  peterhurford/up.zsh
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-completions
  zdharma-continuum/fast-syntax-highlighting
  Aloxaf/fzf-tab
  unixorn/fzf-zsh-plugin
  unixorn/git-extra-commands
  c0mpile/zypper.zsh
)

plugin-clone $repos # clone plugin repos

# load completions
fpath=( "$ZSH_CACHE_DIR/completions" $fpath )

autoload -Uz compinit
compinit

# required for oh-my-zsh plugins to work properly
ZSH=$ZPLUGINDIR/ohmyzsh
for _f in $ZSH/lib/*.zsh; do
  source $_f
done
unset _f

# plugins to load
plugins=(
  powerlevel10k
  up.zsh
  fzf-tab
  fzf-zsh-plugin
  git-extra-commands
  zsh-completions
  zsh-autosuggestions
  zsh-history-substring-search
  fast-syntax-highlighting
  zypper.zsh
  ohmyzsh/plugins/archlinux
  ohmyzsh/plugins/command-not-found
  ohmyzsh/plugins/dnf
  ohmyzsh/plugins/encode64
  ohmyzsh/plugins/safe-paste
  ohmyzsh/plugins/sudo
  ohmyzsh/plugins/universalarchive
)

# load remaining plugins
plugin-source $plugins

# load powerlevel10k
if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
else
  [[ ! -f ~/.p10k-ascii-8color.zsh ]] || source ~/.p10k-ascii-8color.zsh
fi

# load zmv
autoload -U zmv

###########
# Options #
###########
setopt auto_cd
setopt glob_dots
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt cdablevars
setopt rcquotes

############
# Keybinds #
############
bindkey '^[s' sudo-command-line

#####################
# Style completions #
#####################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion:*' use-cache on
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --bind=right:accept,ctrl-space:toggle+down,ctrl-a:toggle-all
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

###########
# Aliases #
###########
# editor stuff
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# directory listing
alias l='eza --icons=always -a --group-directories-first --no-quotes'
alias ls='eza --icons=always --group-directories-first --no-quotes'
alias la='eza --icons=always -a --group-directories-first --no-quotes'
alias ll='eza --icons=always -lah --smart-group --group-directories-first --no-quotes'
alias ldot='eza --icons=always -ldh --group-directories-first --no-quotes .*'
alias tree='tree -a -I .git'

# other shit
alias sudo='sudo '
alias mkdir='mkdir -pv'
alias fu='fuck'
alias rsync='rsync -a --info=progress2'
alias arip='rip url'
alias frip='rip file'
alias wgu='sudo wg-quick up'
alias wgd='sudo wg-quick down'

################
# Integrations #
################
eval "$(zoxide init --cmd cd zsh)"
eval "$(thefuck --alias)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

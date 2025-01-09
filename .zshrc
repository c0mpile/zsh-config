# zsh configuration          
# https://github.com/c0mpile/dotfiles 

################################
# Powerlevel10k instant prompt #
################################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#########################
# Environment Variables #
#########################
PATH="$HOME/.local/bin:$HOME/.local/scripts:$HOME/bin:$HOME/.cargo/bin:$PATH" 
ZDOTDIR="$HOME/.config/zsh"
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
ZSH_CACHE_DIR=${ZSH_CACHE_DIR:-${ZDOTDIR:-$HOME/.config/zsh}/cache}
EDITOR="nvim"
VISUAL="nvim"
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

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

dumpload() {
  docker run --rm -v "${PWD}":/data -it vm03/payload_dumper /data/payload.bin --out /data
}

adboptimize() {
  adb shell cmd package compile -m speed-profile -f -a;
  adb shell cmd package bg-dexopt-job
}

###########
# Plugins #
###########
mkdir -p $ZDOTDIR/{plugins,cache} # create plugin and cache directories if they don't exist

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
  robSis/zsh-completion-generator
  c0mpile/zypper.zsh
)

plugin-clone $repos # clone plugin repos

# load completions
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
  ohmyzsh/plugins/chezmoi
  ohmyzsh/plugins/colored-man-pages
  ohmyzsh/plugins/command-not-found
  ohmyzsh/plugins/dnf
  ohmyzsh/plugins/docker
  ohmyzsh/plugins/docker-compose
  ohmyzsh/plugins/encode64
  ohmyzsh/plugins/gh
  ohmyzsh/plugins/git
  ohmyzsh/plugins/github
  ohmyzsh/plugins/kitty
  ohmyzsh/plugins/npm
  ohmyzsh/plugins/nvm
  ohmyzsh/plugins/pip
  ohmyzsh/plugins/pipenv
  ohmyzsh/plugins/podman
  ohmyzsh/plugins/python
  ohmyzsh/plugins/rbw
  ohmyzsh/plugins/rust
  ohmyzsh/plugins/safe-paste
  ohmyzsh/plugins/sudo
  ohmyzsh/plugins/systemd
  ohmyzsh/plugins/tmux
  ohmyzsh/plugins/tmuxinator
  ohmyzsh/plugins/toolbox
  ohmyzsh/plugins/universalarchive
  ohmyzsh/plugins/vscode
  ohmyzsh/plugins/yum
  ohmyzsh/plugins/zoxide
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
#bindkey -M vicmd '^[s' sudo-command-line
#bindkey -M viins '^[s' sudo-command-line

#####################
# Style completions #
#####################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --bind=right:accept


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

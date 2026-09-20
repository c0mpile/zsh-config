# Documentation: https://github.com/c0mpile/zsh-config/blob/main/README.md.
#
# Do not modify this file unless you know exactly what you are doing.
# It is strongly recommended to keep all shell customization and configuration
# (including exported environment variables such as PATH) in
# ~/.config/zsh/.zshrc or in files sourced from it. If you are certain that you must
# export some environment variables in ~/.zshenv, do it where indicated by comments below.

if [ -n "${ZSH_VERSION-}" ]; then
  # If you are certain that you must export some environment variables
  # in ~/.zshenv (see comments at the top!), do it here:
  #
  #   export GOPATH=$HOME/go
  #
  # Do not change anything else in this file.

  : "${ZDOTDIR:=${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
  export ZDOTDIR
  if [ "$ZDOTDIR" != "$HOME" ] && [ ! -e "$ZDOTDIR"/.zshenv ] && [ ! -h "$ZDOTDIR"/.zshenv ]; then
    ln -sf -- "$HOME"/.zshenv "$ZDOTDIR"/.zshenv 2>/dev/null || true
  fi
  setopt no_global_rcs
  [[ -o no_interactive && -z "${ZCONF_BOOTSTRAPPING-}" ]] && return
  setopt no_rcs
  unset ZCONF_BOOTSTRAPPING
fi

ZCONF_URL="https://raw.githubusercontent.com/c0mpile/zsh-config/main"
: "${ZCONF:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

umask o-w

if [ ! -e "$ZCONF"/zconf.zsh ]; then
  mkdir -p -- "$ZCONF" || return
  >&2 printf '\033[33mzconf\033[0m: fetching \033[4mzconf.zsh\033[0m\n'
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -- "$ZCONF_URL"/zconf.zsh >"$ZCONF"/zconf.zsh.$$ || return
  elif command -v wget >/dev/null 2>&1; then
    wget -O-   -- "$ZCONF_URL"/zconf.zsh >"$ZCONF"/zconf.zsh.$$ || return
  else
    >&2 printf '\033[33mzconf\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
    return 1
  fi
  mv -- "$ZCONF"/zconf.zsh.$$ "$ZCONF"/zconf.zsh || return
fi

. "$ZCONF"/zconf.zsh || return

setopt rcs

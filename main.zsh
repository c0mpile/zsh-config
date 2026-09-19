if '[' '-z' "${ZSH_VERSION-}" ']' || ! 'eval' '[[ "$ZSH_VERSION" == (5.<8->*|<6->.*) ]]'; then
  '.' "$ZCONF"/zsh4humans/sc/exec-zsh-i || 'return'
fi

if [[ -x /proc/self/exe ]]; then
  typeset -gr _zconf_exe=${${:-/proc/self/exe}:A}
else
  () {
    emulate zsh -o posix_argzero -c 'local exe=${0#-}'
    if [[ $SHELL == /* && ${SHELL:t} == $exe && -x $SHELL ]]; then
      exe=$SHELL
    elif (( $+commands[$exe] )); then
      exe=$commands[$exe]
    elif [[ -x $exe ]]; then
      exe=${exe:a}
    else
      print -Pru2 -- "%F{3}zconf%f: unable to find path to %F{1}zsh%f"
      return 1
    fi
    typeset -gr _zconf_exe=${exe:A}
  } || return
fi

if ! { zmodload -s zsh/terminfo zsh/zselect && [[ -n $^fpath/compinit(#qN) ]] ||
       [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_zconf_exe == */bin/zsh &&
          -e ${_zconf_exe:h:h}/share/zsh/5.8/scripts/relocate ]] }; then
  builtin source $ZCONF/zsh4humans/sc/exec-zsh-i || return
fi

if [[ ! -o interactive ]]; then
  # print -Pru2 -- "%F{3}zconf%f: starting interactive %F{2}zsh%f"
  # This is caused by ZCONF_BOOTSTRAPPING, so we don't need to consult ZSH_SCRIPT and the like.
  exec -- $_zconf_exe -i || return
fi

typeset -gr _zconf_opt='emulate -L zsh &&
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
  setopt no_prompt_bang no_bg_nice no_aliases'

zmodload zsh/{datetime,langinfo,parameter,system,terminfo,zutil} || return
zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm,zf_rmdir,zf_ln}    || return
zmodload -F zsh/stat b:zstat                                     || return

() {
  if [[ $1 != $ZCONF/zsh4humans/main.zsh ]]; then
    print -Pru2 -- "%F{3}zconf%f: confusing %Umain.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi
  if (( _zconf_zle )); then
    typeset -gr _zconf_param_pat=$'ZDOTDIR=$ZDOTDIR\0ZCONF=$ZCONF\0ZCONF_URL=$ZCONF_URL'
    typeset -gr _zconf_param_sig=${(e)_zconf_param_pat}
    function -zconf-check-core-params() {
      [[ "${(e)_zconf_param_pat}" == "$_zconf_param_sig" ]] || {
        -zconf-error-param-changed
        return 1
      }
    }
  else
    function -zconf-check-core-params() {}
  fi
} ${${(%):-%x}:a} || return

export -T MANPATH=${MANPATH:-:} manpath
export -T INFOPATH=${INFOPATH:-:} infopath
typeset -gaU cdpath fpath mailpath path manpath infopath

function -zconf-init-homebrew() {
  (( ARGC )) || return 0
  local dir=${1:h:h}
  export HOMEBREW_PREFIX=$dir
  export HOMEBREW_CELLAR=$dir/Cellar
  if [[ -e $dir/Homebrew/Library ]]; then
    export HOMEBREW_REPOSITORY=$dir/Homebrew
  else
    export HOMEBREW_REPOSITORY=$dir
  fi
}

if [[ $OSTYPE == darwin* ]]; then
  if [[ ! -e $ZCONF/cache/init-darwin-paths ]] || ! source $ZCONF/cache/init-darwin-paths; then
    autoload -Uz $ZCONF/zsh4humans/fn/-zconf-gen-init-darwin-paths
    -zconf-gen-init-darwin-paths && source $ZCONF/cache/init-darwin-paths
  fi
  [[ -z $HOMEBREW_PREFIX ]] && -zconf-init-homebrew {/opt/homebrew,/usr/local}/bin/brew(N)
elif [[ $OSTYPE == linux* && -z $HOMEBREW_PREFIX ]]; then
  -zconf-init-homebrew {/home/linuxbrew/.linuxbrew,~/.linuxbrew}/bin/brew(N)
fi

fpath=(
  ${^${(M)fpath:#*/$ZSH_VERSION/functions}/%$ZSH_VERSION\/functions/site-functions}(-/N)
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(-/N)
  /opt/homebrew/share/zsh/site-functions(-/N)
  /usr{/local,}/share/zsh/{site-functions,vendor-completions}(-/N)
  $fpath
  $ZCONF/zsh4humans/fn)

autoload -Uz -- $ZCONF/zsh4humans/fn/(|-|_)zconf[^.]#(:t) || return
functions -Ms _zconf_err

() {
  path=(${@:|path} $path /snap/bin(-/N))
} {~/bin,~/.local/bin,~/.cargo/bin,${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin},${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin},/opt/local/sbin,/opt/local/bin,/usr/local/sbin,/usr/local/bin}(-/N)

() {
  manpath=(${@:|manpath} "${manpath[@]}" '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/man},/opt/local/share/man}(-/N)

() {
  infopath=(${@:|infopath} $infopath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/info},/opt/local/share/info}(-/N)

if [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_zconf_exe == */bin/zsh &&
      -e ${_zconf_exe:h:h}/share/zsh/5.8/scripts/relocate ]]; then
  if [[ $TERMINFO != ~/.terminfo && $TERMINFO != ${_zconf_exe:h:h}/share/terminfo &&
        -e ${_zconf_exe:h:h}/share/terminfo/$TERM[1]/$TERM ]]; then
    export TERMINFO=${_zconf_exe:h:h}/share/terminfo
  fi
  if [[ -e ${_zconf_exe:h:h}/share/man ]]; then
    manpath=(${_zconf_exe:h:h}/share/man $manpath '')
  fi
fi

path+=($ZCONF/fzf/bin)
manpath+=($ZCONF/fzf/man)

: ${GITSTATUS_CACHE_DIR=$ZCONF/cache/gitstatus}
: ${ZSH=$ZCONF/ohmyzsh/ohmyzsh}
: ${ZSH_CUSTOM=$ZCONF/ohmyzsh/ohmyzsh/custom}
: ${ZSH_CACHE_DIR=$ZCONF/cache/ohmyzsh}

[[ $terminfo[Tc] == yes && -z $COLORTERM ]] && export COLORTERM=truecolor

if [[ $EUID == 0 && -z ~(#qNU) && $ZCONF == ~/* ]]; then
  typeset -gri _zconf_dangerous_root=1
else
  typeset -gri _zconf_dangerous_root=0
fi

[[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]] || -zconf-fix-locale

function -zconf-cmd-source() {
  local _zconf_file _zconf_compile
  zparseopts -D -F -- c=_zconf_compile -compile=_zconf_compile || return '_zconf_err()'
  emulate zsh -o extended_glob -c 'local _zconf_files=(${^${(M)@:#/*}}(N) $ZCONF/${^${@:#/*}}(N))'
  if (( ${#_zconf_compile} )); then
    builtin set --
    for _zconf_file in "${_zconf_files[@]}"; do
      -zconf-compile "$_zconf_file" || true
      builtin source -- "$_zconf_file"
    done
  else
    emulate zsh -o extended_glob -c 'local _zconf_rm=(${^${(@)_zconf_files:#$ZCONF/*}}.zwc(N))'
    (( ! ${#_zconf_rm} )) || zf_rm -f -- "${_zconf_rm[@]}" || true
    builtin set --
    for _zconf_file in "${_zconf_files[@]}"; do
      builtin source -- "$_zconf_file"
    done
  fi
}

function -zconf-cmd-load() {
  local -a compile
  zparseopts -D -F -- c=compile -compile=compile || return '_zconf_err()'

  local -a files

  () {
    emulate -L zsh -o extended_glob
    local pkgs=(${(M)@:#/*} $ZCONF/${^${@:#/*}})
    pkgs=(${^${(u)pkgs}}(-/FN))
    local dirs=(${^pkgs}/functions(-/FN))
    local funcs=(${^dirs}/^([_.]*|prompt_*_setup|README*|*~|*.zwc)(-.N:t))
    fpath+=($pkgs $dirs)
    (( $#funcs )) && autoload -Uz -- $funcs
    local dir
    for dir in $pkgs; do
      if [[ -s $dir/init.zsh ]]; then
        files+=($dir/init.zsh)
      elif [[ -s $dir/${dir:t}.plugin.zsh ]]; then
        files+=($dir/${dir:t}.plugin.zsh)
      fi
    done
  } "$@"

  -zconf-cmd-source "${compile[@]}" -- "${files[@]}"
}

function -zconf-cmd-init() {
  if (( ARGC )); then
    print -ru2 -- ${(%):-"%F{3}zconf%f: unexpected %F{1}init%f argument"}
    return '_zconf_err()'
  fi
  if (( ${+_zconf_init_called} )); then
    if [[ ${funcfiletrace[-1]} != zsh:0 ]]; then
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' '\033[33mzconf\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshrc\033[0m\n'
      else
        >&2 'printf' '\033[33mzconf\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n'
      fi
      'return' '1'
    fi
    print -ru2 -- ${(%):-"%F{3}zconf%f: %F{1}init%f cannot be called more than once"}
    return '_zconf_err()'
  fi
  -zconf-check-core-params || return
  typeset -gri _zconf_init_called=1

  () {
    eval "$_zconf_opt"

    (( _zconf_dangerous_root || $+ZCONF_SSH ))                                                   ||
      ! zstyle -T :zconf: chsh                                                                 ||
      [[ ${SHELL-} == $_zconf_exe || ${SHELL-} -ef $_zconf_exe || -e $ZCONF/stickycache/no-chsh ]] ||
      -zconf-chsh                                                                              ||
      true

    local -a start_tmux
    local -i install_tmux need_restart
    if [[ -n $MC_TMPDIR ]]; then
      start_tmux=(no)
    else
      # 'integrated', 'isolated', 'system', or 'command' <cmd> [arg]...
      zstyle -a :zconf: start-tmux start_tmux || start_tmux=(isolated)
      if (( $#start_tmux == 1 )); then
        case $start_tmux[1] in
          integrated|isolated) install_tmux=1;;
          system)     start_tmux=(command tmux -u);;
        esac
      fi
    fi

    if [[ -n $_ZCONF_TMUX_TTY && $_ZCONF_TMUX_TTY != $TTY ]]; then
      [[ $TMUX == $_ZCONF_TMUX ]] && unset TMUX TMUX_PANE
      unset _ZCONF_TMUX _ZCONF_TMUX_PANE _ZCONF_TMUX_CMD _ZCONF_TMUX_TTY
    elif [[ -n $_ZCONF_TMUX_CMD ]]; then
      install_tmux=1
    fi

    if ! [[ _zconf_zle -eq 1 && -o zle && -t 0 && -t 1 && -t 2 ]]; then
      unset _ZCONF_TMUX _ZCONF_TMUX_PANE _ZCONF_TMUX_CMD _ZCONF_TMUX_TTY
    else
      local tmux=$ZCONF/tmux/bin/tmux
      local -a match mbegin mend
      if [[ $TMUX == (#b)(/*),(|<->),(|<->) && -w $match[1] ]]; then
        if [[ $TMUX == */zconf-tmux-* ]]; then
          export _ZCONF_TMUX=$TMUX
          export _ZCONF_TMUX_PANE=$TMUX_PANE
          export _ZCONF_TMUX_CMD=$tmux
          export _ZCONF_TMUX_TTY=$TTY
          unset TMUX TMUX_PANE
        elif [[ -x /proc/$match[2]/exe ]]; then
          export _ZCONF_TMUX=$TMUX
          export _ZCONF_TMUX_PANE=$TMUX_PANE
          export _ZCONF_TMUX_CMD=/proc/$match[2]/exe
          export _ZCONF_TMUX_TTY=$TTY
        elif (( $+commands[tmux] )); then
          export _ZCONF_TMUX=$TMUX
          export _ZCONF_TMUX_PANE=$TMUX_PANE
          export _ZCONF_TMUX_CMD=$commands[tmux]
          export _ZCONF_TMUX_TTY=$TTY
        else
          unset _ZCONF_TMUX _ZCONF_TMUX_PANE _ZCONF_TMUX_CMD _ZCONF_TMUX_TTY
        fi
        if [[ -n $_ZCONF_TMUX && -t 1 ]] &&
           zstyle -T :zconf: prompt-at-bottom &&
           ! zselect -t0 -r 0; then
          local cursor_y cursor_x
          -zconf-get-cursor-pos 1 || cursor_y=0
          local -i n='LINES - cursor_y'
          print -rn -- ${(pl:$n::\n:)}
        fi
      elif (( install_tmux )) &&
           [[ -z $TMUX && ! -w ${_ZCONF_TMUX%,(|<->),(|<->)} && -z $ZCONF_SSH ]]; then
        unset _ZCONF_TMUX _ZCONF_TMUX_PANE _ZCONF_TMUX_CMD _ZCONF_TMUX_TTY TMUX TMUX_PANE
        if [[ -x $tmux && -d $ZCONF/terminfo ]]; then
          # We prefer /tmp over $TMPDIR because the latter breaks rendering
          # of wide chars on iTerm2.
          local sock
          if [[ -n $TMUX_TMPDIR && -d $TMUX_TMPDIR && -w $TMUX_TMPDIR ]]; then
            sock=$TMUX_TMPDIR
          elif [[ -d /tmp && -w /tmp ]]; then
            sock=/tmp
          elif [[ -n $TMPDIR && -d $TMPDIR && -w $TMPDIR ]]; then
            sock=$TMPDIR
          fi
          if [[ -n $sock ]]; then
            local tmux_suf
            local -a cmds=()
            sock=${sock%/}/zconf-tmux-$UID
            if (( terminfo[colors] >= 256 )); then
              cmds+=(set -g default-terminal tmux-256color ';')
              if [[ $COLORTERM == (24bit|truecolor) ]]; then
                cmds+=(set -ga terminal-features ',*:RGB:usstyle:overline' ';')
                sock_suf+='-tc'
              fi
            else
              cmds+=(set -g default-terminal screen ';')
            fi
            if zstyle -t :zconf: term-vresize top; then
              cmds+=(set -g history-limit 1024 ';')
              sock_suf+='-h'
            fi
            if [[ $start_tmux[1] == isolated ]]; then
              sock+=-$sysparams[pid]
            else
              sock+=-$TERM$sock_suf
              if [[ -e $ZCONF/tmux/stamp ]]; then
                # Append a unique per-installation number to the socket path to work
                # around a bug in tmux. See https://github.com/c0mpile/zsh-config/issues/71.
                local stamp
                IFS= read -r stamp <$ZCONF/tmux/stamp || return
                sock+=-${stamp%%.*}
              fi
            fi
            if zstyle -t :zconf: propagate-cwd && [[ -n $TTY && $TTY != *(.| )* ]]; then
              if [[ $PWD == /* && $PWD -ef . ]]; then
                local orig_dir=$PWD
              else
                local orig_dir=${${:-.}:a}
              fi
              if [[ -n "$TMPDIR" && ( ( -d "$TMPDIR" && -w "$TMPDIR" ) || ! ( -d /tmp && -w /tmp ) ) ]]; then
                local tmpdir=$TMPDIR
              else
                local tmpdir=/tmp
              fi
              local dir=$tmpdir/zconf-tmux-cwd-$UID-$$-${TTY//\//.}
              {
                zf_mkdir -p -- $dir &&
                  print -r -- "TMUX=${(q)sock} TMUX_PANE= ${(q)tmux} "'"$@"' >$dir/tmux &&
                  builtin cd -q -- $dir
              } 2>/dev/null
              if (( $? )); then
                zf_rm -rf -- "$dir" 2>/dev/null
                local exec=
              else
                export _ZCONF_ORIG_CWD=$orig_dir
                local exec=
              fi
            else
              local exec=exec
            fi
            SHELL=$_zconf_exe _ZCONF_LINES=$LINES _ZCONF_COLUMNS=$COLUMNS \
              builtin $exec - $tmux -u -S $sock -f $ZCONF/zsh4humans/.tmux.conf -- \
              "${cmds[@]}" new >/dev/null || return
            [[ -z $exec ]] || return
            builtin cd /
            zf_rm -rf -- $dir 2>/dev/null
            builtin exit 0
          fi
        else
          need_restart=1
        fi
      elif [[ -z $TMUX && $start_tmux[1] == command ]] && (( $+commands[$start_tmux[2]] )); then
        if [[ -d $ZCONF/terminfo ]]; then
          SHELL=$_zconf_exe exec - ${start_tmux:1} || return
        else
          need_restart=1
        fi
      fi
    fi

    if [[ -x /usr/lib/systemd/systemd || -x /lib/systemd/systemd ]]; then
      _zconf_install_queue+=(systemd)
    fi
    _zconf_install_queue+=(
      zsh-history-substring-search zsh-autosuggestions zsh-completions
      zsh-syntax-highlighting terminfo fzf powerlevel10k)
    (( install_tmux )) && _zconf_install_queue+=(tmux)
    if ! -zconf-install-many; then
      [[ -e $ZCONF/.updating ]] || -zconf-error-command init
      return 1
    fi
    if (( _zconf_installed_something )); then
      if [[ $TERMINFO != ~/.terminfo && -e ~/.terminfo/$TERM[1]/$TERM ]]; then
        export TERMINFO=~/.terminfo
      fi
      if (( need_restart )); then
        print -ru2 ${(%):-"%F{3}zconf%f: restarting %F{2}zsh%f"}
        exec -- $_zconf_exe -i || return
      else
        print -ru2 ${(%):-"%F{3}zconf%f: initializing %F{2}zsh%f"}
        export P9K_TTY=old
      fi
    fi

    if [[ -w $TTY ]]; then
      typeset -gi _zconf_tty_fd
      sysopen -o cloexec -rwu _zconf_tty_fd -- $TTY || return
      typeset -gri _zconf_tty_fd
    elif [[ -w /dev/tty ]]; then
      typeset -gi _zconf_tty_fd
      if sysopen -o cloexec -rwu _zconf_tty_fd -- /dev/tty 2>/dev/null; then
        typeset -gri _zconf_tty_fd
      else
        unset _zconf_tty_fd
      fi
    fi

    if [[ -v _zconf_tty_fd && (-n $ZCONF_SSH && -n $_ZCONF_SSH_MARKER || -n $_ZCONF_TMUX) ]]; then
      typeset -gri _zconf_can_save_restore_screen=1  # this parameter is read by p10k
    else
      typeset -gri _zconf_can_save_restore_screen=0  # this parameter is read by p10k
    fi

    if (( _zconf_zle )) && zstyle -t :zconf:direnv enable && [[ -e $ZCONF/cache/direnv ]]; then
      -zconf-direnv-init 0 || return '_zconf_err()'
    fi

    local rc_zwcs=($ZDOTDIR/{.zshenv,.zprofile,.zshrc,.zlogin,.zlogout}.zwc(N))
    if (( $#rc_zwcs )); then
      -zconf-check-rc-zwcs $rc_zwcs || return '_zconf_err()'
    fi

    typeset -gr _zconf_orig_shell=${SHELL-}
  } || return

  : ${ZLE_RPROMPT_INDENT:=0}

  # Enable Powerlevel10k instant prompt.
  (( ! _zconf_zle )) || zstyle -t :zconf:powerlevel10k channel none || () {
    local user=${(%):-%n}
    local XDG_CACHE_HOME=$ZCONF/cache/powerlevel10k
    [[ -r $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh ]] || return 0
    builtin source $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh
  }

  local -i zconf_no_flock

  {
    () {
      eval "$_zconf_opt"
      -zconf-init && return
      [[ -e $ZCONF/.updating ]] || -zconf-error-command init
      return 1
    }
  } always {
    (( zconf_no_flock )) || setopt hist_fcntl_lock
  }
}

function -zconf-cmd-install() {
  eval "$_zconf_opt"
  -zconf-check-core-params || return

  local -a flush
  zparseopts -D -F -- f=flush -flush=flush || return '_zconf_err()'

  local invalid=("${@:#([^/]##/)##[^/]##}")
  if (( $#invalid )); then
    print -Pru2 -- '%F{3}zconf%f: %Binstall%b: invalid project name(s)'
    print -Pru2 -- ''
    print -Prlu2 -- '  %F{1}'${(q)^invalid//\%/%%}'%f'
    return 1
  fi
  _zconf_install_queue+=("$@")
  (( $#flush && $#_zconf_install_queue )) || return 0
  -zconf-install-many && return
  -zconf-error-command install
  return 1
}

# Main zsh4humans function. Type `zconf help` for usage.
function zconf() {
  if (( ${+functions[-zconf-cmd-${1-}]} )); then
    -zconf-cmd-"$1" "${@:2}"
  else
    -zconf-cmd-help >&2
    return 1
  fi
}

[[ ${ZCONF_SSH-} != <1->:* ]] || -zconf-ssh-maybe-update || return

unset KITTY_SHELL_INTEGRATION ITERM_INJECT_SHELL_INTEGRATION

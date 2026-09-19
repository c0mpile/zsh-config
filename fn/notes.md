Write man pages: `man zconf`, `man zconfssh`, etc.

---

Implement completions for `zconf`.

---

Make `zconf help` more useful.

---

Implement `zconf bindkey`. `zconf bindkey -l` should list bindings in a nice table with sections. All
widgets should have a human-readable description.

`zconf bindkey -L [array]` should list all bindings in `zconf bindkey` command format. If `array` is
specified, it's filled with `zconf bindkey` commands that can be passed through `eval`. `-r escseq`
should allow binding raw escape sequences. By default should warn when something got unbound. Can be
turned off with `-q`.

```zsh
zh4 bindkey emacs,viins 'up','ctrl-p' zconf-up-local-history
```

---

`vicmd` has `^P` bound to `up-history` by default. It should probably use bound to the same thing
but with local history.

`vicmd` has no bindings for global history. It should.

---

Add "Try it locally" to docs. Basically, create a directory and make it `ZDOTDIR`.

---

Add `zconf replicate [-f] [-b dir] [var=val]...`. It should have its own `:zconf:replicate: files`
style. Argument `ZDOTDIR=$HOME` is implied. All zsh startup files that don't exist in the current
`ZDOTDIR` should also not exist in the target. `-b ''` disables backup. The default argument is
something like `$ZDOTDIR/zconf-backup.date-time`. Files should be stored there with subdirectories all
the way from `/`. `-f` causes silent action, including backing up or deleting files. If not set,
`zconf replicate` first prints the whole plan of what it's going to do (move this file here, copy that
file there, etc.) and asks for confirmation.

---

Add `zconf uninstall`.

---

Add `install` script that people can download and run. Should have a wizard inside.

---

Try to make this work:

```zsh
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
```

`man printf<tab>` should show:

```text
1  printf -- general commands
3  printf -- library functions
3p printf -- library functions [POSIX]
```

Maybe this can be done by writing a custom completion function for `man` and enabling it with
`compdef`.

---

Install `bat`.

---

Add options to `zconf chsh`. Perhaps `-v` so that it prints what your login and current shells are
and what it's going to do about it. Also add `-r` or something to prevent the creation of
`no-chsh`. Maybe `-f` to ignore `no-chsh` and to call `chsh` even if it seems unnecessary.
Should return `0` if login shell is current shell or if it successfully changes it. Should return
`1` if user says "no" and `2` on errors.

---

Move `zconf chsh` to `zconf-chsh`.

---

`zcompile` autoloadable files.

---

Create `fn` directory similarly to `bin`. Add it to `fpath`.

---

Add `:zconf:fzf disable yes`. List: `fzf`, `fzf-bin`, `fzf-tab`, `powerlevel10k`, `extra-completions`,
`autosuggestions`, `syntax-highlighting`. This disabled cloning and all usage.

---

Add `:zconf:fzf update no`. The list is the same as for `disable` plus `zconf`.

---

Add `:zconf:fzf git-clone-flags` and `:zconf:fzf git-pull-flags`.

---

Add `-f` to `zconf clone` to force `ZCONF_UPDATE=1` behavior. 

---

Add `zconf download [-f] [-q] [-o file] url` that uses `curl` or `wget`. Respects `ZCONF_UPDATE` unless
`-f` is specified.

---

Add `zconf-recovery-shell`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh. Bind
it to something. Defend against builtins being overridden by functions or disabled.

---

Add `_zconf_intro`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh.

---

Add `_zconf_err`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh.

---

Add this:

```zsh
zstyle :zconf: hidden-files [ignore|show|recurse]
```

If not `ignore`, should set `dotglob`, add `-A` to `ls`, make `alt-down` and `alt-f` show hidden
leaves. `recurse` should make `alt-down` and `alt-f` recurse hidden directories.

Will need to find another example of modifying aliases in `.zshrc` (currently it adds `-A` to `ls`).

---

Make `cd <alt-f>` consistent with `alt-down`.

---

Check if `alt-f` works on alpine (busybox).

---

Add options I like directly to `.zshrc`. They'll also serve as example. (Not sure if there are any
that aren't already set in `zconf.zsh`.)

---

Check what happens when running `sudo zsh`. Consider adding `$USER` to `$ZCONF`.

---

Name all private functions like this: `-zconf-foo-bar`.

---

Make `-zconf-clone` (or rather `-zconf-clone`) autoloadable.

---

Replace `git pull` with `git fetch origin $ref` followed by `git reset --hard origin/$ref`. If the
latter fails, try `git clean -df` and repeat `git reset`. If the whole thing fails, try `git clone`.

---

`-zconf-clone` should print "installing" or "updating" based on the presence of the target directory.
It shouldn't produce additional output on success.

---

Restore "downloading zconf.zsh" message in `.zshrc`.

---

Change the structure of `$ZCONF` to this:

```text
.
├── bin
├── romkatv
│   └── zsh4humans
│       ├── fn
│       │   ├── -zconf-clone
│       │   └── zconf-help
│       ├── main.zsh         # defines and calls _zconf_prelude, defines zconf, etc.
│       └── zconf.zsh          # the same as $ZCONF/zconf.zsh but could be newer version; not used
├── zsh-users
│   └── zsh-autosuggestions
└── zconf.zsh                  # downloaded by zshrc
```

`zconf.zsh` is in fact a pure POSIX sh script. It looks like this:

```sh
if [ -e "$ZCONF"/zsh4humans/main.zsh ]; then
  . "$ZCONF"/zsh4humans/main.zsh
  return
fi

# git clone, curl or wget c0mpile/zsh-config

. "$ZCONF"/zsh4humans/main.zsh
```

`c0mpile/zsh-config` shouldn't be hard-coded but derived from `$ZCONF_URL`.

It's not very important to update this file. The only case where it executes to the end after the
initial installation is when `zconf` self-update gets aborted in the very short time window where
`c0mpile/zsh-config` is renamed. So it's OK to never update the root `zconf.zsh`. But updating it
is also OK (`cp` + `mv` should be easy enough).

---

Use src branch of powerlevel10k. When updating, use the following algorithm:

- if there is more than one `gitstatus/usrbin/gitstatusd-*`, nuke them all
- rename `gitstatus/usrbin/gitstatusd-*`
- `git pull`
- rename `gitstatus/usrbin/gitstatusd-*` back
- run `gitstatus/install`

When initializing, check if there is exactly one `gitstatus/usrbin/gitstatusd-*`. If not, nuke
all and run `gitstatus/install`.

This way `gitstatus/install` is called only when installing or updating, so it's ok if it runs
`uname` (by the way, change `gitstatus` to use `uname -sm`). We also avoid downloading `gitstatusd`
when it doesn't change.

---

Try harder when looking for zsh. Check `command zsh`, `$SHELL`, `/usr/local/bin/zsh`,
`/usr/bin/zsh`, `/bin/zsh` and `~/.zsh-bin/bin/zsh`, in this order.

---

Add `-zconf-restart` (or `zconf restart`?) and use it instead of plain `exec $_zconf_exe`. This function
should check whether `$_zconf_exe` is good before execing it.

```zsh
$_zconf_exe -fc '[[ $ZSH_VERSION == (5.<4->*|<6->.*) ]]'
```

Maybe also check that `zmodload zsh/zselect` and `autoload add-zsh-hook` work.

If `$_zconf_exe` is not good, try to find a good one. If there aren't any, install zsh-bin. If
everything fails, keep current prompt. Basically the same thing as `_zconf_prelude`.

---

Use some kind of counter to detect exec loop during initialization.

---

Figure out how to allow customization of zsh-bin installation location. This should be defined with
`zstyle`, so it won't be available when we actually need to install zsh-bin. Install it to `$ZCONF`,
`exec` into zsh, and then move zsh-bin to its intended location.

Should it be allowed to put zsh-bin in `$ZCONF`? One problem with this is that `chsh` becomes very
dangerous. OK in ssh though? Probably better to disallow putting zsh-bin under `$XDG_CACHE_HOME`
or `~/.cache`.

```zsh
zstyle :zconf:    zsh-installation-dir /usr/local ~/.local
zstyle :zconf:ssh zsh-installation-dir /usr/local ~/.local
```

If there is more than one option, ask the user to choose. Mark options that would require `sudo`.

---

Make `persist=1` option in `zstyle :zconf:ssh files` the default and remove support for `persist`.

---

Make `LS_COLORS` less obnoxious on NTFS.

---

When `main.zsh` is being sourced, traverse the stack to find `.zshrc` and export `ZDOTDIR` pointing
to its directory.

---

Remove all uses of `$TTY` before `zconf init`. Instead, check `[[ -t 0 && -t 1 ]]`.

---

Add this:

```zsh
zstyle :zconf:locale lang  'c' 'en_us' 'en_gb' 'en_*' '*'
zstyle :zconf:locale force no  # if 'no', locale is changed only when encoding is not UTF-8
```

Set locale early in `zconf install`.

---

Add this:

```zsh
zstyle :zconf:fzf-tab             channel stable
zstyle :zconf:syntax-highlighting channel dev
zstyle :zconf:powerlevel10k       git-ref src

zstyle :zconf:fzf-tab:channel     stable fca05e66d1c397cb5e72e8b185b1c3d1a0fc063d
zstyle :zconf:fzf-tab:channel     dev    master
```

If `git-ref` is set, it wins. Otherwise commit is derived from `channel`.

---

Remove `~/.zshrc` from master branch.

---

Add this:

```zsh
zconf add-hook --after '*' --before 'foo*' --after 'foobar' preinit powerlevel10k _zconf-powerlevel10k-init arg1 arg2

zconf run-hooks preinit arg3 arg4

zconf preinit
```

- Ordering constraints are applied in the order they are specified.
- `zconf preinit` runs `zconf run-hooks preinit`. It complains if executed for the second time.
- The precmd hook runs `zconf postinit` if it hasn't run yet. This allows users to run it manually.
- If `_zconf_powerlevel10k_init arg1 arg2` is not specified, it defaults to `powerlevel10k`.
- It's OK to use `-a` and `-b` instead of `--after` and `--before`.

`.zshrc` will look like this:

```zsh
. "$ZCONF"/zconf.zsh || return

zconf use zsh-syntax-highlighting
zconf use powerlevel10k

zconf install  # installs and/or updates everything
zconf preinit  # enables instant prompt, sources most things, sets parameters, etc.
zconf postinit # runs compinit and sources zsh-syntax-highlighting; called from precmd if not called called explicitly
```

`zconf use foo` calls `zconf-use-foo`, which in turn calls `zconf add-hook` a few times and nothing else.

---

Add this:

```zsh
if zconf use -t powerlevel10k; then  # is powerlevel10k used?
  ...
fi
```

---

Add config presets:

```zsh
. "$ZCONF"/zconf.zsh || return

zstyle :zconf: config-version 1.0.0  # <==

zconf use zsh-syntax-highlighting
zconf use powerlevel10k
...

```

`config-version` can be used by the core code to do things differently but its primary purpose is
to set default values of various parameters, styles, options, bindings, etc.

All `zconf use` directives should be in `.zshrc`. `zconf install` and `zconf preinit` should also be in
`.zshrc`. Everything else should be in preset.

---

Make `zconf ssh` use the same directories (`ZDOTDIR`, `ZCONF`, etc.) as local.

Make setup and teardown configurable through `zstyle`.

```zsh
zstyle ':zconf:ssh:*' setup my-ssh-setup

function my-ssh-setup() {
  local ssh_args=("$@")
  zconf ssh-send-env FOO $foo
  zconf ssh-send-env BAR
  zconf ssh-eval 'baz=qux'
  zconf ssh-send-file -f /foo/bar '$FOO/baz'
}
```

All these commands must be applied in the order they are listed. Remote code must be interpreted
by zsh (hence `$FOO/baz` is OK without quotes).

`ssh-send-file` should be able to send directories. The meaning of trailing slash in source and
`destination` should be the same as in `rsync`.

---

`zconf ssh` should be able to send history and then to retrieve it. For retrieving there needs to
be `teardown` hook similar to `setup`.

---

`zconf ssh` should perform setup and interactive connection with these SSH options:

```
-o 'ControlMaster auto' -o 'ControlPath ~/.ssh/control-master-%r@%h:%p' -o 'ControlPersist 10'
```

These can be overridden via zstyle.

---

Create `zle-experimental-save-restore-cursor` branch in `zsh`. Sync it to 5.8 and add `fix-sigwinch`
code on top. Guard the new code with `ZLE_EXPERIMENTAL_SAVE_RESTORE_CURSOR`.

Create a patch from this commit and store it in `zsh-bin`. Modify `build` to apply the patch.
Set patchlevel to the commit hash from `zle-experimental-save-restore-cursor`.

Add `ZLE_EXPERIMENTAL_SAVE_RESTORE_CURSOR=1` to zsh4humans.

---

Add an option to specify the minimum required zsh version. It should also allow specifying that you
really want zsh from zsh-bin and not some other zsh 5.8.

---

Add these straight to `.zshrc`?

```zsh
zstyle ':completion:*' sort false
zstyle ':completion:*' list-dirs-first true
```

It would be nice to add `--group-directories-first` to `ls` for consistency but it's tricky because
it's not POSIX.

---

Figure out if `_approximate` matcher works and whether it's worth it.

---

Implement syntax highlighting of preview in `zconf-fzf-history` with `zsh-syntax-highlighting`. To do
this, start a companion `zsh` (like in gitstatus), load `zsh-syntax-highlighting` there (make sure
to disable widget wrapping as it's very slow) and communicate with it over pipes.

---

Replace this status message from `zconf reset`:

```text
zconf: cloning zsh4humans/powerlevel10k
```

With this:

```text
zconf: cloning romkatv/powerlevel10k
```

---

Revamp vi bindings. See https://github.com/zsh-vi-more/vi-motions and
https://github.com/softmoth/zsh-vim-mode.

Cursor shape changes should go to p10k?

---

When looking for zsh, check `/etc/shells`.

If there are several zsh versions installed, pick the one from `PATH`. If it's too old, pick
the latest latest from the rest.

---

When zsh-bin installs zsh, it should ask whether to add it to /etc/shells. By default it should
do this only when the installation directory is world-readable.

---

If `ZDOTDIR` is set and doesn't point to `$HOME` when `install` starts, ask whether to install to
`$HOME` or `$ZDOTDIR`. Backups should go under the same directory.

---

Create `~/.zshenv` with just `setopt no_global_rcs` in it.

---

Add `zconf use [-d] [-f] [module]...` where `module` is one of the built-in things:
`zsh-users/zsh-autosuggestions`, `bindkey`, `term-title`, etc.

Without `-d` modules are added to `_zconf_use_queue`. With `-d` they are added to
`_zconf_use_queue_d[-1]`. The latter is an array with nul separated lists as its elements.

On `-f` it should install a `precmd` hook called `-zconf-precmd-$#_zconf_install_queue_d` that calls
`${(0)_zconf_install_queue_d[${0#-zconf-precmd-}]}`, and call `-zconf-use-rigi $_zconf_use_queue`.

`-zconf-use-rigi` should be the same as the current `-zconf-init` with a bunch of conditions added in:

```zsh
if (( ${@[(Ie)zsh-users/zsh-autosuggestions]} )); then
  ...
fi
```

It should issue warnings (but not fail) for arguments it doesn't recognize.

---

Add this:

```zsh
zstyle ':zconf:' preset rigi
```

Could support multiple values for preset "addons". Presets can be used by the core code to do things
differently but its primary purpose is to set default values of various parameters, styles, options,
bindings, etc.

`zconf init` will simply call the preset function -- `-zconf-init-rigi`. The latter will do this:

```zsh
local -a mods=()
zstyle -T :zconf:zsh-users/zsh-autosuggestion install && mods+=zsh-autosuggestion
...
zconf install -f -- $mods

local -a mods=()
zstyle -T :zconf:compinit use && mods+=compinit
...
zconf use -d -- $mods

local -a mods=()
zstyle -T :zconf:zsh-users/zsh-autosuggestion use && mods+=zsh-autosuggestion
...
zconf use -f -- $mods
```

---

Use `fc` to write history in `zconf-stash-buffer`. Might need `fc -p`.

---

Support this for local development:

```
zstyle ':zconf:romkatv/powerlevel10k' channel command ln -s ~/powerlevel10k
```

The command is called with an extra argument designating target directory.

---

Move the top of `~/.zshrc` to `~/.zshenv`. To make it work, `zconf ssh` will need to start
interactive sh.

---

Move `$ZDOTDIR` to `~/.zsh`, leave just `~/.zshenv` in the home directory. Also leave a symlink
form `~/.zshrc` to `~/.zsh/.zshrc` so that users and bad tools don't get confused.

---

When retrieving files in `zconf ssh` and there is no base64 either on local or remote host, use this
for encoding:

```zsh
od -t x1 -An -v | tr -d '[:space:]'
```

Decode with `sysread`, followed by `print -n -- ${buf//(#m)??/'\x'$MATCH}`. This can be done
while reading from the network to speed things up.

This encoding has 50% overhead compared to base64.

---

Make history over ssh more robust so that it never gets overwritten.

---

Protect scripts against rogue aliases as functions as described in the EXAMPLES section of
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html. Use `unset -f` on
all builtins, too.

```zsh
IFS=' 	
'
'unset' '-f' 'unalias' '[' 'cat' ...
'unalias' '-a'
PATH="$(command -p getconf PATH):$PATH"
...
```

This can be broken only by function `unset`.

There is a similar but different example at
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/env.html.

---

Add `zconf pack` that produces `install-zconf` file. It should be similar to the bootstrap script
created by `zconf ssh`. It should be all ASCII. It should respect `:zconf:pack:tag extra-files` and
similar. `tag` is the value passed via optional `-t tag`. Defaults to emty. This allows one to
define different file sets for different packs. By default the same set of files as sent by ssh
should be packed, plus all history files.

---

Support `fzf` customization via `zstyle`. Add nice support for bindings (including continuous
completion and query insertion via fake actions like `zconf-accept-and-repeat` and
`zconf-accept-query`). Also allow for low level overrides.

```zsh
zstyle :zconf:expand-or-complete:fzf command  my-fzf
zstyle :zconf:expand-or-complete:fzf bindings ctrl-u:kill-line
zstyle :zconf:expand-or-complete:fzf flags    --no-exact
```

`flags` and `bindings` have the semantics of *extra* flags and bindings.

Extra flags should be added at the front of standard flags because the first flag wins.
All flags should be passed to the command (`my-fzf` above) where users can munge them any way they
like. Use `--foo=bar` syntax to make it easier to remove flags (one argument -- one flag).

Extra bindings could be added at the end of standard bindings because the last binding wins.
However, in order to handle fake actions such as `zconf-accept-and-repeat` it'll probably be necessary
to resolve binding conflicts within zconf. The goal is to allow this syntax for disabling continuous
completion:

```zsh
zstyle :zconf:expand-or-complete:fzf extra-bindings tab:ignore
```

`ignore` could be any other legit action. The point is that by default `tab` is bound to
`zconf-accept-and-repeat` but we rebind it.

---

Support preview customization in fzf. At the very least allow changing the size (down to 0) of
preview in history.

---

<kbd>Ctrl+/</kbd> is a bad binding on some keyboard layouts. See #35.

---

`run-help` has some issues with aliases. See
https://github.com/c0mpile/zsh-config/issues/35#issuecomment-657515701.

---

Currently `find` for recursive completions is called with `-xdev`. This should be customizable.
See https://github.com/c0mpile/zsh-config/issues/35#issuecomment-660477146.

---

Define `command_not_found_handler` for more operating systems (similarly to how it's done for
Homebrew and Debian).

---

`command_not_found_handler` should simultaneously use Homebrew and `/usr/lib/command-not-found` if
both are available.

---

Make `Alt+{Up,Left,Right}` work within `fzf`. See [this comment](
  https://github.com/c0mpile/zsh-config/issues/35#issuecomment-674357739).

---

Colorize files in git completions the same way they are shown in `git status`.

---

Propagate arguments of `zsh -ic "..."` trhough `exec` when switching to a different zsh.

---

Make `run-help zconf source` work.

---

`zconf ssh` should start login shell.

---

When doing `exec $_zconf_exe`, preserve `-l`.

---

Document binding syntax in `zconf help bindkey`.

---

Make it safe to continue using an old shell after zconf has been updated in another shell.

Assuming that flock works, it can be done as follows. Rename `ZCONF` to `ZCONF_CACHE_DIR` in
`~/.zshenv`. Within `$ZCONF_CACHE_DIR` store:

- `zconf.zsh`
- `last-update-ts`
- `no-chsh`
- `snapshot-00000000` through `snapshot-ffffffff`

`zconf.zsh` should point `ZCONF` to the latest snapshot. If there are none, it should create a unique
temporary snapshot which would later be transformed into a regular snapshot by `main.zsh`.
Preferably this should be the same code path as in `zconf update`.

`ZCONF_CACHE_DIR` should not propagate through `zsh` the way `ZCONF` currently propagates. `ZCONF` should
still propagate. It seems like there shouldn't be a requirement that `ZCONF_CACHE_DIR` gets set to
the same value in the child shell created by `zconf update` as in the parent.

`main.zsh` should reader-flock its snapshot. If that fails due to the directory being deleted (see
below), it should `exec zsh`.

Whenever `main.zsh` creates a new snapshot, it should do this while holding a writer-flock on
`$ZCONF_CACHE_DIR`.

`main.zsh` should scan the existing snapshots while holding a writer-flock on `$ZCONF_CACHE_DIR` and
delete all that can be writer-flocked.

On a system where flock always succeeds (WSL1, see https://github.com/Microsoft/WSL/issues/1927),
this would make matters much worse than currently thanks to `main.zsh` thinking that all snapshots
are unused and deleting them. Special code is required in this case.

---

Make this:

```zsh
% ls foo/..<TAB>
```

Complete to this:

```zsh
% ls foo/../
```

However, `..` should never appear in the listing. In addition, this should work as before:

```zsh
touch ..x
ls ..<TAB>
```

It should complete to `ls ..x `.

---

The three minor issues with the integrated tmux that I've mentioned in
https://github.com/c0mpile/zsh-config/issues/35#issuecomment-719639084 are here:

```text
3a8eb6f08fb26ffdad79dae6f00c9a80ba30ecc0f0ee0a142322005f1d28710a */home/romka/notes/zconf-tmuw-issues.md
```

---

See if it's feasible to fix
https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window by patching
tmux.

---

`kitty @ launch cat` doesn't work. See
https://github.com/c0mpile/zsh-config/issues/35#issuecomment-720134760.

---

`new_os_window_with_cwd` doesn't work in Kitty. See
https://github.com/c0mpile/zsh-config/issues/35#issuecomment-720134760.

---

Make `zconf ssh` work when the target machine doesn't have internet.

Implement `zconf fetch` that on a local machine would be a wrapper around `curl`/`wget` and on a
remote machine would send a request via the marker to the local. Local machine would fetch the
file (via `zconf fetch`, naturally) and upload it via `ssh host 'cat >$dst.$$ && mv $dst.$$ $dst`.
The file should have error code, stderr and finally the file.

There is `curl` in `~/.zshenv`. In order to deal with that, add one more condition to `~/.zshenv`:

```zsh
if command -v zconf >/dev/null 2>&1; then
  zconf fetch "$ZCONF_URL"/zconf.zsh >"$ZCONF"/zconf.zsh.$$
elif ...
fi
```

`zconf` will be a function that can handle nothing but this command.

`zconf fetch` should have a whitelist of URLs it can handle (for security).

---

Implement `zconf clipboard-{cut,copy,paste}` that can work over ssh. Add this to `.zshrc`:

```zsh
# Should clipboard-related zconf commands on the local host use
# the OS clipboard ('system') or a file ('file')?
zstyle :zconf: clipboard system

# Allow remote hosts access to the clipboard of the client? If set to 'no',
# clipboard-related zconf functions on the remote host will use a file.
zstyle ':zconf:ssh:*' client-clipboard no

# Copy the current command line to clipboard.
zconf bindkey zconf-copy-bufer-to-clipboard Ctrl+X

alias x='zconf clipboard-copy'   # write stdin to clipboard
alias c='zconf clipboard-copy'   # write stdin to clipboard and to stdout
alias v='zconf clipboard-paste'  # write clipboard to stdout
```

---

Add `zconf {slurp,barf}` similar to `zconf clipboard-{cut,copy,paste}`.

---

Make <kbd>Ctrl+R</kbd> display the preview right on the command line. Before opening it, set
`BUFFER` to `$'..\n\n\n'` so that it scrolls a bit.

---

Set `TERM=screen-256color` by default. Make it easy to override it per-app and the default as well.

```zsh
zstyle :zconf:terminfo:     term screen-256color
zstyle :zconf:terminfo:ssh  term screen-256color
zstyle :zconf:terminfo:sudo term screen-256color
```

These styles should be consulted only when using tmux with 256 colors.

Hm, those styles won't work because we need to define functions for all apps (`ssh`, `sudo`, etc.).
This, then?

```zsh
zstyle :zconf:tmux term                  screen-256color
zstyle :zconf:tmux force-screen-256color ssh sudo
zstyle :zconf:tmux force-tmux-256color   kak vi
```

Or maybe hook `TRAPDEBUG` and use the first syntax?

Or do it like this:

```zsh
zstyle :zconf: term-spec {ssh,sudo,docker}:{tmux-256color:screen-256color,alacritty:xterm-256color}
```

This isn't good. Figure out how to make it possible to add commands without wiping the default ones.

---

Profile tmux when printing a ton of data to the terminal and see if there is an easy way to speed
it up (likely not).

---

`$TTY` is not writable when doing something like this:

```zsh
% sudo useradd -ms =zsh test
% sudo -iu test
% [[ -w $TTY ]] || echo 'not writable'
```

This breaks a bunch of things. For example, <kbd>Tab</kbd> doesn't work. To fix this, `dup` one of
the standard file descriptors into `_zconf_tty_fd` on startup and use it through the code instead of
`$TTY`.

---

Change the way <kbd>Up</kbd>/<kbd>Down</kbd> work with multi-line commands. Pressing <kbd>Up</kbd>
twice should always have the effect of fetching from history twice, whether the command line was
empty or not to begin with.

---

Consider changing <kbd>Up</kbd>/<kbd>Down</kbd> so that it searches for individual words. There
is `HISTORY_SUBSTRING_SEARCH_FUZZY=1` for it.

---

Add a banner to `~/.zshrc` that requires confirmation. Add the same banner to `install`. When
the user consents during the installation, remove the banner from `~/.zshrc`.

The banner should say that this is bleeding edge, blah, blah.

---

Do not install zsh-bin if the only thing missing from the stock is terminfo. Also remove the
requirement for `zsh/pcre`. Better yet, add a `zstyle` for required modules.

The goal here is to avoid installing zsh-bin when using macOS Big Sur or having zsh from brew.

---

Make zsh-bin work like `tmux -u`. That is, assume UTF-8 always. If there is no UTF-8 locale on the
machine (or maybe if the current locale is not UTF-8) require zsh-bin.

---

Make integrated tmux work with `TERM=xterm-256color`.

---

Remove client-server architecture from the integrated tmux. Would be nice to put it in the same
process as zsh but it might make it more difficult to update tmux. For starters it's probably a good
idea to have zsh in one process and everything else in another (`zconfd`).

Actually, maybe this is a bad idea. Maybe it's better to run `zconfd` the way `tmux` currently runs.
Just add `version` to the socket name. The latter can be done right now, without any architectural
changes.

---

Add a special escape code to the integrated tmux that would allow identifying via a roundtrip to
the TTY. Since other terminals won't reply, the logic should be like this:

1. Write "are you integrated tmux".
2. Write "where is cursor".
3. Read the cursor positions. If a special response preceeds it, this is integrated tmux.

---

Add `zconf [-r] output` that prints the output of the last command. With `-r` the output is printed
without styling (no colors, etc.). Print a warning if the output has more than `N` bytes (or
terminal lines?). `N` should be configurable.

Implement this by printing a marker in preexec and another in precmd.

---

Complain if users override `TERM` when using integrated tmux.

---

Figure out better key bindings for macOS.

---

If using iTerm2 with the default color scheme, change it to Tango Dark with dark-grey for black.
Do it in `p10k configure` for now.

---

`zconf ssh` should backup remote files to `~/zsh-backup/ssh`. Each file/directory just once. When
backing up, write a message to the tty saying so. Have a `zstyle` to control this.

---

List `~/.tmux.conf` in `~/.zshrc` among the files to send over ssh.

---

Make it possible for users to tell which commit their zsh4humans is synced to.

---

Implement a benchmark that measures the startup time.

```zsh
print 'print foo""bar; exit' | script -E never -qec "script -E never -f -T /tmp/timing -qe /tmp/script" /dev/null >/dev/null
```

---

Add a `zstyle` to disable VTE integration.

---

Run recovery code from `zconf.zsh` on `precmd` to lower startup lag (perhaps by defining
`-zconf-post-init` and later redefining it). This should also solve the problem with custom `HISTFILE`
-- just `fc -R` it on recovery.

---

When using `su blah -` with the source and the target users both having zconf with integrated tmux,
screen gets cleared unnecessarily. See https://github.com/c0mpile/zsh-config/issues/159. This can
be fixed by creating world-writable directory `/tmp/zconf-tty` with world-writabable files in it.
The names of the files would be derived from `$TTY` of tmux (both integrated and real) and the
content would have `$TTY`, `$_ZCONF_TMUX`, etc. Note that `$_ZCONF_TMUX_CMD` may be unaccessible, so
some fallback would be needed. If `$_ZCONF_TMUX_CMD` is integrated tmux, then it should be OK to use
the integrated tmux from the target user provided that it's compatible. So some version would need
to be included in the file.

---

Disable builtin `log` in v6.

---

Add an ability to set `ZDOTDIR` for remote machines:

```zsh
zstyle :zconf:ssh:some-host zdotdir '~/.config/zsh'
```

Consider setting the default value to something other than `$HOME`. A naive solution will break
this:

```zsh
sudo -su $USER
```

No one's gonna do *that* but there might be other ways of losing `ZDOTDIR` even when it's exported.

---

Make the list of traversed directories in `zconf-cd-down` configurable.

```zsh
zstyle ':zconf:cd-down' dirs history descendants:. descendants:~ children:/
```

Could use better naming.

Make sure that the `find` command that corresponds to `descendants:~` prunes `.`. Entries from
history can be filtered out at the end.

---

Add `undo-repeat` action (or a better name) to fzf widgets. It should completely undo `repeat`.
Great to bind on <kbd>Shift+Tab</kbd>.

---

Delete (uninstall) stuff that was installed with `zconf install` and no longer has the corresponding
directive.

---

When generating a config in p10k under zconf, create trampoline files for more powerful terminals.
E.g., when generating `.p10k-ascii-8color.zsh`, create all the other variants that don't exist yet.

Adjust the welcome message about tmux.

---

Add every `.p10k*.zsh` variant that doesn't exist locally to `zconf_ssh_receive_files`. The idea is to
pull configs that get generated remotely.

---

If there is no correct `.p10k*.zsh` variant for the TTY but there are variants for less powerful
terminals, automatically create trampoline files.

---

If there is no correct `.p10k*.zsh` variant for the TTY but there are variants for more powerful
terminals, print a message explaning why the configuration wizard is about to start. Maybe also
ask for other options? Maybe use a predefined simple config and print a message?

---

Create `.tmux.conf` in the installer if there is no existing config and the user chooses
"always tmux".

---

Find a better solution w.r.t. functions `docker` and `sudo`.

---

Change the default values of `:zconf:term-title:ssh` in v6 to these:

```zsh
zstyle ':zconf:term-title:ssh' precmd  ${${${ZCONF_SSH##*:}//\%/%%}:-%m}': %~'
zstyle ':zconf:term-title:ssh' preexec ${${${ZCONF_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
```

---

Make p10k display `${${${ZCONF_SSH##*:}//\%/%%}:-%m}` instead of `%m` in `context`. Not sure how to
achieve this without making the default p10k configs more complex.

---

When replacing instant prompt with the real thing, it's not necessary to print `ed`. Zsh will do it
on its own. Removing this `ed` might reduce the magnitude of blinking. It also might make it
possible to get rid of the function call in `PS1`.

---

Implement rzw (Roman's Zsh Widgets) in a separate repo.

```zsh
# zwords has an even number of elements, all of which are indices into $PREBUFFER$BUFFER.
# All odd words (one-based) are whitespace.
# $zwords[2*izword-1] is the start position of the word the cursor is pointing to.
# $zwords[2*izword] is the end position.
# $zword is the actual word. It is technically redundant.
rzw-parse-buffer -a zwords -i izword -w zword

# Returns 1 if there are no non-whitespace words in $PREBUFFER$BUFFER.
# Otherwise returns 0 and sets the specified parameters to the current word, or
# the one before it if the current word is whitespace, or the one after it if
# there is no previous word.
rzw-get-prev-zword -s istart -e iend -w zword

# Finds the difference between two strings using Levenshtein distance.
#
#   % rzw-string-diff -a parts -- 'sunday!' 'saturday'
#   % printf '%-5s => %s\n' ${(qq)parts}
#   's'   => 's'
#   ''    => 'at'
#   'u'   => 'u'
#   'n'   => 'r'
#   'day' => 'day'
#   '!'   => ''
#
# The default values of -m and -M are set like this:
#
#   zstyle :rzw:WIDGET: string-diff-max-complexity 10000 1000000
#
# If only one value is set, the second defaults to it. If neither is set, the
# values default to 10000 and 1000000. TODO: verify that the second value is
# adequate.
#
# If -c is not specified, it is fetched like this:
#
#   zstyle :rzw:WIDGET: string-diff-cache-file
#
# Which in turn defaults to this:
#
#   ${XDG_CACHE_HOME:-$HOME/.cache}/rzw-string-diff-$OSTYPE-$CPUTYPE
rzw-string-diff -m 10000 -M 1000000 -c CACHE -a parts -- s1 s2

# Compile a C implementation of rzw-string-diff into CACHE (a file).
# Does nothing if CACHE is a readable and executable file.
#
# Refuses to create directories whose parent isn't owned by $USER.
# If -c is not specified, its value is resolved as described above.
rzw-string-diff -C -c CACHE

# Does nothing if istart lies outside of $BUFFER. Otherwise replaces the
# specified range with the specified content while keeping the cursor
# pointing to the same content as before.
rzw-replace-buffer -- istart iend content

# Returns 0 if the script is a valid body of a function with the current
# options, aliases, etc. Otherwise returns 1.
rzw-is-valid-script -- script

# Quotes the shell word to the left of the cursor with double or single quotes.
# Prefers quotes with the shorter result or double quotes if there is no
# difference. If already quoted, changes quotes. If there is an unterminated
# quote, terminates it and quotes the resulting word with the same kind of
# quotes. Keeps the cursor on the content it was pointing to before the widget
# was invoked.

# Replaces the shell word to the left of the cursor with the result of the
# specified transformation. Keeps the cursor on the content it was pointing to
# before the widget was invoked.
#
# Prior to the transformation the shell word is unquoted. Afterwards it is
# quoted while preferring the same kind of quoting that already existed prior
# to the transformation.
#
#   bar       => /foo/bar
#   'bar'     => '/foo/bar'
#   'bar      => '/foo/bar'
#   $'b\x20r' => $'/foo/b r'
#   $'b\141r' => $'/foo/bar'
#
# Note: Pass the original unquoted word as $2?
rzw-transform-prev-zword -- 'REPLY=${1:a}'

# Example

function convert-prev-zword-to-abolute-path() {
  rzw-transform-prev-zword -- 'REPLY=${1:a}'
}

zle -N convert-prev-zword-to-abolute-path
bindkey '^A' convert-prev-zword-to-abolute-path
```

The buffer is always `$PREBUFFER$BUFFER` and all buffer indices are within it.

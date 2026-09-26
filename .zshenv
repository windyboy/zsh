# Re-entry point for shells that inherit ZDOTDIR.
#
# zshenv exports ZDOTDIR (zshenv:17), so every nested zsh starts with
# ZDOTDIR=$ZSH_CONFIG_DIR and looks for $ZDOTDIR/.zshenv — this file. Without
# it those shells (child shells of an interactive zsh, exec zsh, ssh sessions)
# would silently skip zshenv entirely and zshrc would re-source it on every
# startup. The first shell of a login chain instead reads ~/.zshenv, the
# symlink install.sh creates, which points at the real zshenv.
. "$ZDOTDIR/zshenv"

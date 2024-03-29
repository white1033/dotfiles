#!/usr/bin/env python3
"""\
Dotfiles setup script. Inspired by concise.

Update the symlink_setting string as the following format:

Destination         Source under $PWD
-----------         -----------------
~/.gitconfig        gitconfig


Unexisted folder will be created (but may fail).
"""
import os.path as op
from pathlib import Path

symlink_settings = '''\
~/.gitconfig                    gitconfig
~/.gitignore_global             gitignore_global
~/.tmux.conf                    tmux.conf
~/.zshrc                        zshrc
~/.yabairc                      yabairc
~/.skhdrc                       skhdrc
'''


def main():
    for setting_line in symlink_settings.splitlines():
        dest_pth, src_pth = setting_line.rstrip().split(maxsplit=1)
        dest = Path(op.expanduser(dest_pth))
        src = Path(src_pth).resolve()
        print('Linking', dest, '->', src)
        if dest.exists():
            print('... symlink existed ->', dest.resolve(), '(removed)')
            dest.unlink()
        if not dest.parent.exists():
            dest.parent.mkdir(mode=0o755, parents=True)
        dest.symlink_to(src)


if __name__ == '__main__':
    main()

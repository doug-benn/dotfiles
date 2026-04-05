## WSL (Arch)

Install Archlinux in WSL by following this guide - [Install Arch Linux on WSL - ArchWiki](https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL)

Add a user and change the passwords as required, links on the help page

Set it as the default `wsl --set-default archlinux`

Install sudo:

1. Sign in to root as required: `su`

2. Install sudo: `pacman -S sudo`

   Add user to the group `sudo usermod -aG wheel <username>`

   `EDITOR=nano visudo`

Install other packages

```shell
sudo pacman -S nano git less \
    github-cli make openssh stow \
    clang zoxide starship neovim lazygit \
    wget fd ripgrep eza fzf
```

`sudo nano /etc/locale.gen`

Find and uncomment this line (remove the `#`): `en_GB.UTF-8 UTF-8`

`sudo locale-gen`

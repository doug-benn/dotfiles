## Powershell

Install a nerd font:
Nerd Font: CaskaydiaMono (Like Cascadia Code without any ligatures)

Install Powershell 7:
`winget install --id Microsoft.PowerShell --source winget`

Install Powershell Modules:
`Install-Module -Name Terminal-Icons -Repository PSGallery`
`Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force`

Install Extras:
zoxide: `winget install ajeetdsouza.zoxide`
fzf: `winget install fzf`

Install starship prompt
Install alacritty

## WSL Arch: (https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL)

Update: `wsl --update`
Install Arch: `wsl --install archlinux`

Add a user and change the default user in WSL
Install sudo and configure

Terminal theme: (this matches the alacritty Kanagawa theme)

```{
            "background": "#1f1f28",
            "black": "#090618",
            "blue": "#7e9cd8",
            "brightBlack": "#727169",
            "brightBlue": "#7fb4ca",
            "brightCyan": "#7aa89f",
            "brightGreen": "#98bb6c",
            "brightPurple": "#938aa9",
            "brightRed": "#e82424",
            "brightWhite": "#dcd7ba",
            "brightYellow": "#e6c384",
            "cursorColor": "#DCD7BA",
            "cyan": "#6a9589",
            "foreground": "#dcd7ba",
            "green": "#76946a",
            "name": "Kanagawa",
            "purple": "#957fb8",
            "red": "#c34043",
            "selectionBackground": "#2d4f67",
            "white": "#c8c093",
            "yellow": "#c0a36e"
        }
```

Make symlinks (admin CMD)
PowerShell config: `mklink /d PowerShell .\dotfiles\PowerShell`
Starship config: `mklink starship.toml ..\Documents\dotfiles\starship.toml` (assuming cloned to Documents/dotfiles)
Alacritty: `mklink /d alacritty ..\..\Documents\dotfiles\alacritty`

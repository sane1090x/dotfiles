#!/usr/bin/env bash

### date written: 14-11-2023

# colors
col_reset='\033[0m'

# bold
b_red='\033[1;31m'
b_yellow='\033[1;33m'
b_blue='\033[1;34m'

# config vars
zshrc="$HOME/.zshrc"
zshenv="$HOME/.zshenv"
zprofile="$HOME/.zprofile"
p10kzsh="$HOME/.p10k.zsh"
config_dir="$HOME/.config"

if command -v git &>/dev/null; then
    echo "git exists" &>/dev/null
else
    echo "${b_red}Install git!${col_reset}"
fi

install_dotfiles() {
    echo
    echo -e "${b_blue}Cloning repositories...${col_reset}"
    echo

    sleep 0.5

    if [[ -d "/tmp/dotfiles" ]]; then
        cd /tmp/dotfiles || exit
    else
        git clone --depth 1 --quiet https://github.com/sane1090x/dotfiles /tmp/dotfiles
        cd /tmp/dotfiles || exit
    fi

    # if these files exist, ask the user for permission to overwrite
    if [ -e "$zshrc" ] && [ -e "$zshenv" ] && [ -e "$zprofile" ] && [ -e "$p10kzsh" ]; then
        echo -en "${b_yellow}Conflicts found! Overwrite one or more files '.zshrc .zshenv .zprofile .p10k.zsh'? [y/N] ${col_reset}"
        read -r res
        echo

        if [[ $res =~ ^[Yy]$ ]]; then
            cp -f .zshrc .zshenv .zprofile .p10k.zsh "$HOME" || {
                echo
                echo -e "${b_red}Error copying files.${col_reset}"
                return 2
            }
        else
            echo -e "${b_red}Aborting!${col_reset}"
        fi
    fi

    # check if the last command left an empty line in the prompt
    if [[ -z "$PROMPT_EOL" ]]; then
        echo -en "${b_yellow}Overwrite one or more directories 'alacritty cava fontconfig hypr lvim spicetify waybar'? [y/N] ${col_reset}"
        read -r res2
    else
        echo -en "${b_yellow}Overwrite one or more directories 'alacritty cava fontconfig hypr lvim spicetify waybar'? [y/N] ${col_reset}"
        read -r res2
        echo
    fi

    # overwrite the dirs with permission
    if [[ "$res2" =~ ^[Yy]$ ]]; then
        cp -rf .config/* "$config_dir" || {
            echo
            echo -e "${b_red}Error copying files.${col_reset}"
            return 2
        }
    else
        echo -e "${b_red}Aborting!${col_reset}"
    fi
}

main() {
    # script interruption and termination
    exit_on_signal_SIGINT() {

        # check if the last command left an empty line in the prompt
        if [[ -z "$PROMPT_EOL" ]]; then
            {
                printf "${b_red}\n\n%s\n${col_reset}" "Script interrupted." 2>&1
            }
        fi

        exit 0
    }

    exit_on_signal_SIGTERM() {

        # check if the last command left an empty line in the prompt
        if [[ -z "$PROMPT_EOL" ]]; then
            {
                printf "${b_red}\n\n%s\n${col_reset}" "Script terminated." 2>&1
            }
        fi

        exit 0
    }

    trap exit_on_signal_SIGINT SIGINT
    trap exit_on_signal_SIGTERM SIGTERM

    echo
    echo -en "${b_blue}This script is tested only on Arch Linux; it might fail on other systems. Do you want to continue? [y/N] ${col_reset}"
    read -r start_confirmation

    if [[ ! $start_confirmation =~ ^[Yy]$ ]]; then
        echo -e "${b_red}Installation aborted.${col_reset}"
        exit 0
    fi

    install_dotfiles
}

main

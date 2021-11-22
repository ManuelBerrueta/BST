#!/bin/bash -e

#          BST ENUM
#          v.1 Alpha
#   by @ManuelBerrueta (revx0r)
# Linux Enumeration script to be ran on the target host shell

BANNER="
██████╗ ███████╗████████╗    ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝████╗  ██║██║   ██║████╗ ████║
██████╔╝███████╗   ██║       █████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
██╔══██╗╚════██║   ██║       ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
██████╔╝███████║   ██║       ███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
╚═════╝ ╚══════╝   ╚═╝       ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
"
printf '%s' "$BANNER"

# If '-b ' is passed as an argument, then the content of the script
#  will be base64 encoded so you can copy and paste to the machine
# Simply do an echo " paste the base64 payload and close quote
if [ "$1" == "-b" ]; then 
    cat ./bst_enum.sh | base64
    exit 0
fi

if [ -e /tmp/.bst_enum.out ]; then
    rm /tmp/.bst_enum.out
fi

echo "=]☼[ Collecting hostname ]☼[="
LHOST=$(hostname)
printf '%s\n\n' "$LHOST"
echo 

echo "=]☼[ Collecting OS + Kernel Version ]☼[="
OS=$(lsb_release -a)
POPCORN=$(uname -a)
printf '%s\n\n' "$OS"
printf '%s\n\n' "$POPCORN"
echo 

echo "=]☼[ Collecting passwd ]☼[="
PASSWD=$(cat /etc/passwd)
printf '%s\n\n' "$PASSWD"
echo 

printf '        ==[ hostname ]==\n%s\n
        ==[ OS + Kerenel Info ]==\n%s\n%s\n\n
        ==[ PASSWD ]==\n%s\n%s\n\n' \
        "$LHOST" \
        "$OS" \
        "$POPCORN" \
        "$PASSWD" \
        >> /tmp/.bst_enum.out


echo "=]☼[ Collecting Groups user '${USER}' belongs to ]☼[="
USR_GROUPS=$(groups)
printf '%s\n\n' "$USR_GROUPS"
echo 

echo "=]☼[ Collecting PATH Env Var ]☼[="
SYS_PATH=$(echo $PATH)
printf '%s\n\n' "$SYS_PATH"
echo

echo "=]☼[ Collecting SU Privs ]☼[="
SU_PRIVS=$(sudo -l)
printf '%s\n\n' "$SU_PRIVS"
echo

echo "=]☼[ Collecting Shares ]☼[="
SHARES=$(mount)
printf '%s\n\n' "$SHARES"
echo

printf '        ==[ User Groups ]==\n%s\n
        ==[ PATH ]==\n%s\n\n
        ==[ SHARES ]==\n%s\n\n
        ==[ SU Privs ]==\n%s\n\n' \
        "$USR_GROUPS" \
        "$SYS_PATH" \
        "$SHARES" \
        "$SU_PRIVS" \
        >> /tmp/.bst_enum.out

echo "=]☼[ Collecting History ]☼[="
SOCIALSTUDIES=$(cat ~/.bash_history)
echo

printf '        ==[ History ]==\n%s\n' \
        "$SOCIALSTUDIES" \
        >> /tmp/.bst_enum-history.out


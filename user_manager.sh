#!/bin/bash
# ============================================
# User Management Tool v2.0
# Author: Mouez
# Description: Manage a simple user database
# ============================================

USERFILE="./users.txt"
LOGFILE="./user_manager.log"
BACKUP_DIR="./backups"

# Create needed files/directories
touch "$USERFILE" "$LOGFILE"
mkdir -p "$BACKUP_DIR"

# --- Colors ---
RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; BLUE="\033[34m"; NC="\033[0m"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

backup_users() {
    backup_file="$BACKUP_DIR/users_$(date +%F_%H-%M-%S).txt"
    cp "$USERFILE" "$backup_file"
    echo -e "${BLUE}Backup saved to $backup_file${NC}"
    log_action "Backup created: $backup_file"
}

validate_username() {
    [[ -z "$1" || "$1" =~ [^a-zA-Z0-9_-] ]] && return 1 || return 0
}

add_user() {
    read -p "Enter new username: " username
    if ! validate_username "$username"; then
        echo -e "${RED}Invalid username! Use only letters, numbers, underscores, or hyphens.${NC}"
        return
    fi
    if grep -q "^$username$" "$USERFILE"; then
        echo -e "${YELLOW}User '$username' already exists.${NC}"
    else
        echo "$username" >> "$USERFILE"
        echo -e "${GREEN}User '$username' added.${NC}"
        log_action "Added user: $username"
    fi
}

delete_user() {
    read -p "Enter username to delete: " username
    if grep -q "^$username$" "$USERFILE"; then
        grep -v "^$username$" "$USERFILE" > temp.txt && mv temp.txt "$USERFILE"
        echo -e "${GREEN}User '$username' deleted.${NC}"
        log_action "Deleted user: $username"
    else
        echo -e "${RED}User '$username' not found.${NC}"
    fi
}

list_users() {
    if [ -s "$USERFILE" ]; then
        echo -e "${BLUE}Registered Users:${NC}"
        nl -w2 -s". " "$USERFILE"
    else
        echo -e "${YELLOW}No users registered yet.${NC}"
    fi
    log_action "Listed users"
}

search_user() {
    read -p "Enter username to search: " username
    if grep -q "^$username$" "$USERFILE"; then
        echo -e "${GREEN}User '$username' exists.${NC}"
    else
        echo -e "${RED}User '$username' not found.${NC}"
    fi
    log_action "Searched user: $username"
}

show_help() {
    echo "Usage: ./user_manager.sh"
    echo "Manage users stored in a local file."
    echo "Options:"
    echo "  -h       Show this help message"
    echo "Run without options to open the interactive menu."
}

# --- Handle Arguments ---
if [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# --- Main Menu Loop ---
while true; do
    echo "============================="
    echo "   User Management Menu"
    echo "============================="
    echo "1) Add User"
    echo "2) Delete User"
    echo "3) List Users"
    echo "4) Search User"
    echo "5) Backup Users"
    echo "6) View Logs"
    echo "7) Exit"
    read -p "Choose an option [1-7]: " choice

    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) search_user ;;
        5) backup_users ;;
        6) less "$LOGFILE" ;;
        7) echo -e "${BLUE}Goodbye!${NC}"; break ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac

    echo
    read -p "Press Enter to continue..."
    clear
done


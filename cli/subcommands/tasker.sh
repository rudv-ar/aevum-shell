#!/bin/bash

#  TASKER - a taskwarrior wrapper

subcommand=${1:-"help"}

# Colors and Styles
BOLD="\e[1m"
DIM="\e[2m"
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
MAGENTA="\e[35m"
RESET="\e[0m"

# helper functions
print-help() {
    # a beautiful header from figlet
    echo -e "
${BOLD}${CYAN}  ████████╗ █████╗ ███████╗██╗  ██╗███████╗██████╗ ${RESET}
${BOLD}${CYAN}     ██╔══╝██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗${RESET}
${BOLD}${CYAN}     ██║   ███████║███████╗█████╔╝ █████╗  ██████╔╝${RESET}
${BOLD}${CYAN}     ██║   ██╔══██║╚════██║██╔═██╗ ██╔══╝  ██╔══██╗${RESET}
${BOLD}${CYAN}     ██║   ██║  ██║███████║██║  ██╗███████╗██║  ██║${RESET}
${BOLD}${CYAN}     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝${RESET}

${BOLD}usage${RESET}  : tasker <subcommand> <flags>

${BOLD}${YELLOW}subcommands:${RESET}
  ${BOLD}add${RESET}   - add a task
          ${DIM}-i${RESET}  : interactive mode

  ${BOLD}help${RESET}  - show this help section

${DIM}-----------------------------------------------------------------------------------${RESET}
"
}

invalid-attempt() {
    echo -e "\n${RED}${BOLD} Unknown subcommand:${RESET} '${subcommand}'"
    echo -e "${DIM}  Run 'tasker help' for usage.${RESET}\n"
}

# Prompt helper
prompt() {
    # usage: prompt "Label" "default"  → stores in $REPLY
    local label="$1"
    local default="$2"
    if [[ -n "$default" ]]; then
        echo -ne "  ${BOLD}${CYAN}${label}${RESET} ${DIM}[${default}]${RESET}: "
    else
        echo -ne "  ${BOLD}${CYAN}${label}${RESET}: "
    fi
    read -r input
    if [[ -z "$input" && -n "$default" ]]; then
        REPLY="$default"
    else
        REPLY="$input"
    fi
}

# Interactive add task ; just enter everything and leave blank to configure for defaults
init-add-interactive() {
    echo -e "\n${BOLD}${MAGENTA}  ┌─────────────────────────────────┐${RESET}"
    echo -e "${BOLD}${MAGENTA}  │        ADD A NEW TASK           │${RESET}"
    echo -e "${BOLD}${MAGENTA}  └─────────────────────────────────┘${RESET}\n"

    # Name (required)
    while true; do
        prompt "Task name" ""
        TASK_NAME="$REPLY"
        [[ -n "$TASK_NAME" ]] && break
        echo -e "  ${RED}Task name cannot be empty.${RESET}"
    done

    # Description (optional, appended to name in this format - Name : description of the task, like a one liner btw)
    prompt "Description" ""
    TASK_DESC="$REPLY"

    # Project (default: Default)
    prompt "Project" "Default"
    TASK_PROJECT="$REPLY"

    # Subproject (default: Misc)
    prompt "Subproject" "Misc"
    TASK_SUBPROJECT="$REPLY"

    # Combined project string
    FULL_PROJECT="${TASK_PROJECT}.${TASK_SUBPROJECT}"

    # Due date : default due date is today
    prompt "Due date (YYYY-MM-DD)" "$(date +%Y-%m-%d)"
    TASK_DUE="$REPLY"

    # Deadline : default deadline is tomorrow
    prompt "Deadline (YYYY-MM-DD)" $(date -d "+1 days" +%Y-%m-%d)
    TASK_DEADLINE="$REPLY"

    # Score (UDA - must be configured in taskrc): default score for all projects is 10
    prompt "Score" "10"
    TASK_SCORE="$REPLY"

    # Tags (space-separated tags, easy to access later)
    prompt "Tags (space-separated)" ""
    TASK_TAGS="$REPLY"

    # build the task command : just string formatting.
    echo -e "\n${DIM}-----------------------------------------------------------------------------------${RESET}"

    # Build full description
    if [[ -n "$TASK_DESC" ]]; then
        FULL_DESC="${TASK_NAME} : ${TASK_DESC}"
    else
        FULL_DESC="${TASK_NAME}"
    fi

    CMD="task add"
    CMD+=" project:${FULL_PROJECT}"
    CMD+=" \"${FULL_DESC}\""
    [[ -n "$TASK_DUE" ]] && CMD+=" due:${TASK_DUE}"
    [[ -n "$TASK_DEADLINE" ]] && CMD+=" deadline:${TASK_DEADLINE}"
    [[ -n "$TASK_SCORE" ]] && CMD+=" score:${TASK_SCORE}"

    # Add tags with + prefix
    if [[ -n "$TASK_TAGS" ]]; then
        for tag in $TASK_TAGS; do
            CMD+=" +${tag}"
        done
    fi

    # Preview the task
    echo -e "\n${BOLD}  Preview:${RESET}"
    echo -e "  ${DIM}${CMD}${RESET}\n"

    echo -ne "  ${BOLD}${GREEN}Confirm and add? (y/N):${RESET} "
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        eval "$CMD"
        echo -e "\n  ${GREEN}${BOLD}✓ Task added successfully!${RESET}\n"
    else
        echo -e "\n  ${YELLOW}  Cancelled.${RESET}\n"
    fi
}

# init add : dispactch the subcommands of add
init-add() {
    local flag="${1}"
    case "$flag" in
    -i)
        init-add-interactive
        ;;
    "")
        echo -e "\n${YELLOW}  Hint:${RESET} Use ${BOLD}tasker add -i${RESET} for interactive mode.\n"
        ;;
    *)
        echo -e "\n${RED}  Unknown flag:${RESET} '${flag}'\n"
        ;;
    esac
}

# The main command case switcher
case "$subcommand" in
help)
    print-help
    ;;
add)
    init-add "$2"
    ;;
*)
    invalid-attempt
    ;;
esac

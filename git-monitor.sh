#!/bin/bash

## --- Variables --- ##

# Number of commits to be skipped
n_skip=0
# Number of commits to be displayed
n_commits=0

## --- Methods --- ##

# Prints the current working directory status
show_status()
{
    git status --short
}
# Prints the selected git commit history
show_log()
{
    # Number of commits to be displayed
    n_commits=20

    git --no-pager log -n $n_commits --oneline --skip=$n_skip
}

# Prints a horizontal line
draw_hline()
{
    cols=$(tput cols)
    counter=0
    while (( $counter < $cols )) ; do
        printf "-"
        counter=$(( $counter + 1 ))
    done
    printf "\n"
}

# Auxiliary output method
align()
{
    for cmd in $@ ; do
        draw_hline
        eval "$cmd"
    done
    draw_hline
}

# Hexdumps a string
to_hex()
{
    hex=$(xxd -ps -u <<< "$1")

    # Cut off '0A'
    echo "${hex:0:-2}"
}

# Waits for control characters
wait_for_control()
{
    while true ; do
        read -sn 1 char
        char_hex=$(to_hex "$char")

        if [[ $char == ":" ]] ; then
            printf "$char "
            return 0
        fi

        input_hex=$input_hex$char_hex

        case ${input_hex:(-6)} in
            "1B5B41" ) return 1 ;; # [Arrow Up]
            "1B5B42" ) return 2 ;; # [Arrow Down]
        esac
        case ${input_hex:(-8)} in
            "1B5B357E" ) return 3 ;; # [Page Up]
            "1B5B367E" ) return 4 ;; # [Page Down]
        esac
    done
}

# Waits for a requested display change
update_page()
{
    while true ; do
        wait_for_control

        # Handle a pressed paging-related key accordingly
        case $? in

            # Git command line
            0 ) read git_cmd
                eval "git $git_cmd" ;;

            # [Arrow Up]
            1 ) if (( $n_skip > 0 )) ; then
                    n_skip=$(( $n_skip - 1 ))
                else
                    continue
                fi ;;

            # [Arrow Down]
            2 ) n_skip=$(( $n_skip + 1 )) ;;

            # [Page Up]
            3 ) if (( $n_skip > $n_commits )) ; then
                    n_skip=$(( $n_skip - $n_commits ))
                elif (( $n_skip > 0 )) ; then
                    n_skip=0
                else
                    continue
                fi ;;

            # [Page Down]
            4 ) n_skip=$(( $n_skip + $n_commits )) ;;

            # Unknown key, do not handle
            * ) continue ;;

        esac

        # Break the loop if a pressed key has been handled
        break
    done
}

## --- Program --- ##

while true ; do
    tput reset

    align show_status show_log

    # Wait (and catch input) for 50ms to prevent too much flickering
    read -st 0.05

    update_page
done


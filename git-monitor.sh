#!/bin/bash

# --- Variables ---

# Number of commits to be skipped
n_skip=0
# Number of commits to be displayed
n_commits=0

# --- Methods ---

show_status()
{
    git status --short
}

# Prints the selected git commit history
show_log()
{
    # Number of commits to be displayed
    n_commits=$(( $(tput lines) - 25 ))

    echo "----------------------------------------------------"

    # Invoke the 'git log' command
    git --no-pager log --graph -n $n_commits --oneline --skip=$n_skip

    echo "----------------------------------------------------"
}

# Waits for paging-related keys to be pressed and returns an ID number
wait_for_paging_keys()
{
    while true ; do
        read -sn 1 character
        sequence+=$character
        hex=$(xxd -ps -u <<< "$sequence")
        case ${hex:(-8)} in
            1B5B410A ) return 0 ;; # [Arrow Up]
            1B5B420A ) return 1 ;; # [Arrow Down]
        esac
        case ${hex:(-10)} in
            1B5B357E0A ) return 2 ;; # [Page Up]
            1B5B367E0A ) return 3 ;; # [Page Down]
        esac
    done
}

# Waits for a requested display change
update_page()
{
    while true ; do
        wait_for_paging_keys

        # Handle a pressed paging-related key accordingly
        case $? in

            # [Arrow Up]
            0 ) if (( $n_skip > 0 )) ; then
                    n_skip=$(( $n_skip - 1 ))
                else
                    continue
                fi ;;

            # [Arrow Down]
            1 ) n_skip=$(( $n_skip + 1 )) ;;

            # [Page Up]
            2 ) if (( $n_skip > $n_commits )) ; then
                    n_skip=$(( $n_skip - $n_commits ))
                elif (( $n_skip > 0 )) ; then
                    n_skip=0
                else
                    continue
                fi ;;

            # [Page Down]
            3 ) n_skip=$(( $n_skip + $n_commits )) ;;

            # Unknown key, do not handle
            * ) continue ;;

        esac

        # Break the loop if a pressed key has been handled
        break
    done
}

# --- Program ---

while true ; do
    clear

    show_status
    show_log

    # Wait (and catch input) for 50ms to prevent too much flickering
    read -st 0.05

    update_page
done


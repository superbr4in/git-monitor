#!/bin/bash

wait_for_arrow()
{
    while true ; do
        read -sn 1 character
        sequence+=$character
        hex=$(xxd -ps -u <<< "$sequence")
        case ${hex:(-8)} in
            1B5B410A ) return 0 ;; # up
            1B5B420A ) return 1 ;; # down
            1B5B430A ) return 2 ;; # right
            1B5B440A ) return 3 ;; # left
        esac
    done
}

n=10
skip=0

while true ; do
#clear
#git --no-pager log --graph -n $n --oneline --skip=$skip

    echo "clear: $skip"

    while true ; do
        wait_for_arrow
        case $? in
            0 ) ((skip++)) ;;
            1 ) ((skip--)) ;;
            * ) continue
        esac
        break
    done
done

